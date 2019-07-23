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

#pragma mark - Algorithm helper methods

static int getNextTimeBlock(int timeBlock) {
    if (timeBlock == evening) {
        return 0;
    }
    return timeBlock + 1;
}

static int getDayOfWeekAsInt(NSDate *date) {
    
    NSString *dayString = getDayOfWeek(date);
    
    if ([dayString isEqualToString:@"Monday"]) {
        return 1;
    } else if ([dayString isEqualToString:@"Tuesday"]) {
        return 2;
    } else if ([dayString isEqualToString:@"Wednesday"]) {
        return 3;
    } else if ([dayString isEqualToString:@"Thursday"]) {
        return 4;
    } else if ([dayString isEqualToString:@"Friday"]) {
        return 5;
    } else if ([dayString isEqualToString:@"Saturday"]) {
        return 6;
    } else if ([dayString isEqualToString:@"Sunday"]) {
        return 0;
    }
    return -1;
}

@implementation Schedule

#pragma mark - initialization methods
- (instancetype)initWithArrayOfPlaces:(NSArray *)completeArrayOfPlaces withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate {
    self = [super init];
    [self createAllProperties];

    self.startDate = startDate;
    self.endDate = endDate;
    self.numberOfDays = (int)[Date daysBetweenDate:startDate andDate:endDate];
    
    
    //[self.arrayOfAllPlaces arrayByAddingObjectsFromArray:completeArrayOfPlaces];
    [self testing];
    self.startDate = removeTime([NSDate date]);
    self.endDate = removeTime(getNextDate(self.startDate, 2));
    //self.home = [self.arrayOfAllPlaces objectAtIndex:0];
    //[self createAvaliabilityDictionary];
    
    //self.numberOfDays = (int)[Schedule daysBetweenDate:startDate andDate:endDate];
    
    [self generateSchedule];
    
    return self;
}

- (void)testing {
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [[APIManager shared]getPlacesCloseToLatitude:@"37.4471" andLongitude:@"-122.161" withType:@"museum" withCompletion:^(NSArray *arrayOfPlaces, NSError *error) {
        if(arrayOfPlaces) {
            NSLog(@"Array of places dictionary worked");
            self.arrayOfAllPlaces = arrayOfPlaces;
        }
        else {
            NSLog(@"did not work snif");
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
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
    int currTimeBlock = breakfast;
    BOOL allPlacesVisited = [self visitedAllPlaces];
    BOOL withinDateRange = [self checkEndDate:self.startDate];
    while ((withinDateRange || self.indefiniteTime) && !allPlacesVisited) {
        NSLog([NSString stringWithFormat:@"Current Place: %@", currPlace.name]);
        [self getClosestAvailablePlace:currPlace atTime:currTimeBlock onDate:currDate];
        [self addAndUpdatePlace:dayPath atTime:currTimeBlock];
        currTimeBlock = getNextTimeBlock(currTimeBlock);
        currPlace = self.currClosestPlace;
        self.currClosestPlace = nil;
        if (currTimeBlock == 0) {
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

- (void)addAndUpdatePlace:(NSMutableArray *)dayPath atTime:(int)currTimeBlock {
    if (self.currClosestPlace) {
        [dayPath insertObject:self.currClosestPlace atIndex:currTimeBlock];
        self.currClosestPlace.hasAlreadyGone = true;
        self.currClosestPlace.scheduledTimeBlock = currTimeBlock;
        self.currClosestPlace.travelTimeToPlace = [self.currClosestTravelDistance intValue];
    } else {
        [dayPath insertObject:self.home atIndex:currTimeBlock]; //putting self.home means empty
    }
}

- (void)getClosestAvailablePlace:(Place *)origin atTime:(int)timeBlock onDate:(NSDate *)date {
    NSArray *availablePlaces = self.availabilityDictionary[@(timeBlock)][@(getDayOfWeekAsInt(date))];
    
    
    
    
    //TESTING: Not sure how the availability thing is working because of the hotel hours, so...
    availablePlaces = self.arrayOfAllPlaces;
    
    
    
    //TODO:the priority thing... idk where it is???
    self.currClosestPlace = nil;
    self.currClosestTravelDistance = @(-1);
    NSArray* newArray = [availablePlaces mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
        Place *place = obj;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [[APIManager shared] getDistanceFromOrigin:origin.name toDestination:place.name withCompletion:^(NSDictionary *distanceDurationDictionary, NSError *error) {
            if (distanceDurationDictionary) {
                NSNumber *timeDistance = [distanceDurationDictionary valueForKey:@"value"][0][0];
                BOOL destinationCloser = [timeDistance doubleValue] < [self.currClosestTravelDistance doubleValue];
                BOOL firstPlace = [self.currClosestTravelDistance doubleValue] < 0;
                NSLog([NSString stringWithFormat:@"Place: %@", place.name]);
                NSLog([NSString stringWithFormat:@"TimeDistance: %@", timeDistance]);
                if ((destinationCloser || firstPlace) && !place.hasAlreadyGone && !place.locked) {
                    self.currClosestTravelDistance = timeDistance;
                    self.currClosestPlace = place;
                }
            } else {
                NSLog(@"Error getting closest place: %@", error.localizedDescription);
            }
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        return place;
    }];
    
    
    
    /*
    for (Place *destination in availablePlaces) {
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [[APIManager shared] getDistanceFromOrigin:origin.name toDestination:destination.name withCompletion:^(NSDictionary *distanceDurationDictionary, NSError *error) {
            if (distanceDurationDictionary) {
                NSNumber *timeDistance = distanceDurationDictionary[@"value"];
                BOOL destinationCloser = [timeDistance doubleValue] < [self.currClosestTravelDistance doubleValue];
                BOOL firstPlace = [self.currClosestTravelDistance doubleValue] < 0;
                if ((destinationCloser || firstPlace) && !destination.hasAlreadyGone && !destination.locked) {
                    self.currClosestTravelDistance = timeDistance;
                    self.currClosestPlace = destination;
                }
            } else {
                NSLog(@"Error getting closest place: %@", error.localizedDescription);
            }
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    //completion(self.currClosestPlace, nil);
    return nil;*/
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
- (void)createAllProperties {
    self.availabilityDictionary = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"breakfast"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"morning"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"lunch"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"afternoon"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"dinner"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"evening"] = [[NSMutableDictionary alloc] init];
    self.arrayOfAllPlaces = [[NSMutableArray alloc] init];
}

-(void)createAllArraysAtDay:(NSNumber *)day {
    self.availabilityDictionary[@"breakfast"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"morning"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"lunch"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"afternoon"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"dinner"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"evening"][day] = [NSMutableArray init];
}

- (void)createAvaliabilityDictionary {
    [self initAllArrays];
    for(int dayInt = 0; dayInt <= 6; ++dayInt) {
        NSNumber *day = [[NSNumber alloc]initWithInt:dayInt];
        for(Place *attraction in self.arrayOfAllPlaces) {
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(1)]) {
                [self.availabilityDictionary[@"morning"][day] addObject:attraction];
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(2)]) {
                [self.availabilityDictionary[@"lunch"][day] addObject:attraction];
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(3)]) {
               [self.availabilityDictionary[@"afternoon"][day] addObject:attraction];
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(4)]) {
                [self.availabilityDictionary[@"dinner"][day] addObject:attraction];
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(5)]) {
                [self.availabilityDictionary[@"evening"][day] addObject:attraction];
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(0)]) {
                [self.availabilityDictionary[@"breakfast"][day] addObject:attraction];
            }
        }
    }
}

- (void)initAllArrays {
    for (int i = breakfast; i <= evening; i++) {
        NSMutableDictionary *dayDict = [[NSMutableDictionary alloc] init];
        for (int j = 0; j < 7; j++) {
            [dayDict setObject:[[NSMutableArray alloc] init] forKey:@(j)];
        }
        [self.availabilityDictionary setObject:dayDict forKey:@(i)];
    }
}

#pragma mark - general helper methods

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}


@end
