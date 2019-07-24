//
//  Schedule.m
//  Travel Scheduler
//
//  Created by gilemos on 7/19/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Schedule.h"
#import "TravelSchedulerHelper.h"
#import "APIManager.h"
#import "Place.h"
#import "Date.h"
#import "NSArray+Map.h"
#import "placeObjectTesting.h"

#pragma mark - Algorithm helper methods

static int getNextTimeBlock(TimeBlock timeBlock) {
    if (timeBlock == TimeBlockEvening) {
        return 0;
    }
    return timeBlock + 1;
}

static void getDistanceToHome(Place *place, Place *home) {
    dispatch_semaphore_t gotDistance = dispatch_semaphore_create(0);
    [[APIManager shared] getDistanceFromOrigin:place.name toDestination:home.name withCompletion:^(NSDictionary *distanceDurationDictionary, NSError *error) {
        if (distanceDurationDictionary) {
            NSNumber *time = [distanceDurationDictionary valueForKey:@"value"][0][0];
            place.travelTimeFromPlace = time;
        } else {
            NSLog(@"Error getting closest place: %@", error.localizedDescription);
        }
        dispatch_semaphore_signal(gotDistance);
    }];
    dispatch_semaphore_wait(gotDistance, DISPATCH_TIME_FOREVER);
}

@implementation Schedule

#pragma mark - initialization methods

- (instancetype)initWithArrayOfPlaces:(NSArray *)completeArrayOfPlaces withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate {
    self = [super init];
    [self createAllProperties];
    self.startDate = startDate;
    self.endDate = endDate;
    self.numberOfDays = (int)[Date daysBetweenDate:startDate andDate:endDate];
    
    

    self.arrayOfAllPlaces = testGetPlaces();
    self.startDate = removeTime([NSDate date]);
    self.endDate = removeTime(getNextDate(self.startDate, 2));
    //TODO: do it with real arrays.
    //[self.arrayOfAllPlaces arrayByAddingObjectsFromArray:completeArrayOfPlaces];
    //self.home = [self.arrayOfAllPlaces objectAtIndex:0];
    //[self createAvaliabilityDictionary];
    
    //self.numberOfDays = (int)[Schedule daysBetweenDate:startDate andDate:endDate];
    
    return self;
}

#pragma mark - algorithm that generates schedule

- (NSDictionary *)generateSchedule {
    self.finalScheduleDictionary = [[NSMutableDictionary alloc] init];
    NSDate *currDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:self.startDate];
    NSMutableArray *dayPath = [[NSMutableArray alloc] initWithCapacity:6];
    
    //TESTING
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.arrayOfAllPlaces) {
        Place *place = [[Place alloc] initWithDictionary:dict];
        [temp addObject:place];
    }
    self.arrayOfAllPlaces = temp;
    self.home = [self.arrayOfAllPlaces objectAtIndex:0];
    self.arrayOfAllPlaces = [self.arrayOfAllPlaces subarrayWithRange:NSMakeRange(1, self.arrayOfAllPlaces.count - 1)];
    
    
    
    Place *currPlace = self.home;
    [self createAvaliabilityDictionary];
    TimeBlock currTimeBlock = TimeBlockBreakfast;
    BOOL allPlacesVisited = [self visitedAllPlaces];
    BOOL withinDateRange = [self checkEndDate:self.startDate];
    while ((withinDateRange || self.indefiniteTime) && !allPlacesVisited) {
        //NSLog([NSString stringWithFormat:@"Current Place: %@", currPlace.name]);
        [self getClosestAvailablePlace:currPlace atTime:currTimeBlock onDate:currDate];
        [self addAndUpdatePlace:dayPath atTime:currTimeBlock];
        self.currClosestPlace.prevPlace = currPlace;
        currPlace = self.currClosestPlace;
        self.currClosestPlace = nil;
        [currPlace setArrivalDeparture:currTimeBlock];
        currTimeBlock = getNextTimeBlock(currTimeBlock);
        if (currTimeBlock == 0) {
            getDistanceToHome(currPlace, self.home);
            [self.finalScheduleDictionary setObject:dayPath forKey:currDate];
            currDate = getNextDate(currDate, 1);
            dayPath = [[NSMutableArray alloc] init];
            currPlace = self.home;
        }
        allPlacesVisited = [self visitedAllPlaces];
        withinDateRange = [self checkEndDate:currDate];
    }
    return self.finalScheduleDictionary;
}

- (void)addAndUpdatePlace:(NSMutableArray *)dayPath atTime:(TimeBlock)currTimeBlock {
    if (self.currClosestPlace) {
        [dayPath insertObject:self.currClosestPlace atIndex:currTimeBlock];
        self.currClosestPlace.hasAlreadyGone = true;
        self.currClosestPlace.scheduledTimeBlock = currTimeBlock;
        self.currClosestPlace.travelTimeToPlace = self.currClosestTravelDistance;
        
    } else {
        [dayPath insertObject:self.home atIndex:currTimeBlock]; //putting self.home means empty
    }
}

- (void)getClosestAvailablePlace:(Place *)origin atTime:(TimeBlock)timeBlock onDate:(NSDate *)date {
    NSArray *availablePlaces = self.availabilityDictionary[@(timeBlock)][@(getDayOfWeekAsInt(date))];
    
    
    
    
    //TESTING: Not sure how the availability thing is working because of the hotel hours, so...
    availablePlaces = self.arrayOfAllPlaces;
    
    
    
    //TODO:the priority thing...
    
    self.currClosestPlace = nil;
    self.currClosestTravelDistance = @(-1);
    NSArray* newArray = [availablePlaces mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
        Place *place = obj;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [[APIManager shared] getDistanceFromOrigin:origin.name toDestination:place.name withCompletion:^(NSDictionary *distanceDurationDictionary, NSError *error) {
            if (distanceDurationDictionary) {
                self.currTimeDistance = [distanceDurationDictionary valueForKey:@"value"][0][0];
                BOOL destinationCloser = [self.currTimeDistance doubleValue] < [self.currClosestTravelDistance doubleValue];
                BOOL firstPlace = [self.currClosestTravelDistance doubleValue] < 0;
                //NSLog([NSString stringWithFormat:@"Place: %@", place.name]);
                //NSLog([NSString stringWithFormat:@"TimeDistance: %@", timeDistance]);
                if ((destinationCloser || firstPlace) && !place.hasAlreadyGone && !place.locked) {
                    self.currClosestTravelDistance = self.currTimeDistance;
                    self.currClosestPlace = place;
                }
            } else {
                NSLog(@"Error getting closest place: %@", error.localizedDescription);
            }
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        [origin.cachedDistances setValue:self.currTimeDistance forKey:place.name];
        return place;
    }];
}

- (BOOL)visitedAllPlaces {
    for (Place *place in self.arrayOfAllPlaces) {
        if (!place.hasAlreadyGone) {
            return false;
        }
    }
    return true;
}

- (BOOL)checkEndDate:(NSDate *)date {
    return !self.indefiniteTime && ([self.endDate compare:date] != NSOrderedAscending);
}

#pragma mark - helper methods for initialization

- (void)createAvaliabilityDictionary {
    //[self createAllProperties];
    for(int dayInt = 0; dayInt <= 6; ++dayInt) {
        NSNumber *day = [[NSNumber alloc]initWithInt:dayInt];
        for(Place *attraction in self.arrayOfAllPlaces) {
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockMorning)]) {
                [self.availabilityDictionary[@(TimeBlockMorning)][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockLunch)]) {
                [self.availabilityDictionary[@(TimeBlockLunch)][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockAfternoon)]) {
               [self.availabilityDictionary[@(TimeBlockAfternoon)][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockDinner)]) {
                [self.availabilityDictionary[@(TimeBlockDinner)][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockEvening)]) {
                [self.availabilityDictionary[@(TimeBlockEvening)][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockBreakfast)]) {
                [self.availabilityDictionary[@(TimeBlockBreakfast)][day] addObject:attraction];
            }
        }
    }
}

- (void)createAllProperties {
    for (TimeBlock i = TimeBlockBreakfast; i <= TimeBlockEvening; i++) {
        NSMutableDictionary *dayDict = [[NSMutableDictionary alloc] init];
        for (int j = 0; j < 7; j++) {
            [dayDict setObject:[[NSMutableArray alloc] init] forKey:@(j)];
        }
        [self.availabilityDictionary setObject:dayDict forKey:@(i)];
    }
}

@end
