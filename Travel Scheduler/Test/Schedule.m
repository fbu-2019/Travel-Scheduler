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
#import "Commute.h"

#pragma mark - Algorithm helper methods

static void getDistanceToHome(Place *place, Place *home)
{
    dispatch_semaphore_t gotDistance = dispatch_semaphore_create(0);
    [[APIManager shared] getDistanceFromOrigin:place.placeId toDestination:home.placeId withCompletion:^(NSDictionary *distanceDurationDictionary, NSError *error) {
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

static NSArray *getAvailableFilteredArray(NSMutableArray *availablePlaces)
{
    NSMutableArray *priorityItems = [[NSMutableArray alloc] init];
    if (availablePlaces.count) {
        [availablePlaces sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]]];
        int smallestPriority = ((Place *)availablePlaces[0]).priority;
        for (Place *place in availablePlaces) {
            if (place.priority == smallestPriority) {
                [priorityItems addObject:place];
            } else {
                break;
            }
        }
    }
    return priorityItems;
}

@implementation Schedule

#pragma mark - initialization methods

- (instancetype)initWithArrayOfPlaces:(NSArray *)completeArrayOfPlaces withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate withHome:home
{
    self = [super init];
    [self createAllProperties];
    self.startDate = removeTime(startDate);
    self.endDate = removeTime(endDate);
    self.indefiniteTime = (self.endDate == nil);
    if (self.indefiniteTime && self.startDate == nil) {
        self.startDate = [NSDate date];
    }
    self.home = home;
    self.numberOfDays = (int)[Date daysBetweenDate:startDate andDate:endDate];
    self.arrayOfAllPlaces = [[NSMutableArray alloc] init];
    self.arrayOfAllPlaces = completeArrayOfPlaces;
    [self createAvailabilityDictionary];
    return self;
}

#pragma mark - algorithm that generates schedule

- (NSDictionary *)generateSchedule
{
    self.finalScheduleDictionary = [[NSMutableDictionary alloc] init];
    self.currDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:self.startDate];
    NSMutableArray *dayPath = [[NSMutableArray alloc] initWithCapacity:6];
    Place *currPlace = self.home;
    self.currTimeBlock = TimeBlockBreakfast;
    BOOL allPlacesVisited = [self visitedAllPlaces];
    BOOL withinDateRange = [self checkEndDate:self.startDate];
    while ((withinDateRange || self.indefiniteTime) && !allPlacesVisited) {
        //NSLog([NSString stringWithFormat:@"Current Place: %@", currPlace.name]);  //TESTING only
        BOOL lockedPlaceAtCurrentTimeBlock = [self findAndSetLockedPlaceForDate:self.currDate time:self.currTimeBlock];
        if (lockedPlaceAtCurrentTimeBlock) {
            NSNumber *cached = [currPlace.cachedTimeDistances objectForKey:self.currClosestPlace.placeId];
            if (cached) {
                self.currClosestPlace.travelTimeToPlace = cached;
            } else {
                [self setTravelTimeFromOrigin:currPlace toPlace:self.currClosestPlace];
            }
        } else {
            [self getClosestAvailablePlace:currPlace atTime:self.currTimeBlock onDate:self.currDate];
        }
        self.currClosestPlace.scheduledTimeBlock = self.currTimeBlock;
        if (self.currClosestPlace) {
            if (self.currClosestPlace.scheduledTimeBlock == getNextTimeBlock(currPlace.scheduledTimeBlock)) {
                self.currClosestPlace.prevPlace = currPlace;
            }
            BOOL placeFitsInSchedule = [self.currClosestPlace setArrivalDeparture:self.currTimeBlock];
            if (placeFitsInSchedule) {
                currPlace = self.currClosestPlace;
                self.currClosestPlace.date = self.currDate;
                self.currClosestPlace.tempDate = self.currDate;
            } else {
                if (self.currClosestPlace.locked) {
                    self.currClosestPlace.locked = false;
                    [self.delegate handleErrorAlert:self.currClosestPlace];
                }
                self.currClosestPlace.scheduledTimeBlock = -1;
                self.currClosestPlace.prevPlace = nil;
                self.currClosestPlace = nil;
            }
        }
        [self addAndUpdatePlace:dayPath atTime:self.currTimeBlock];

        self.currClosestPlace = nil;
        self.currTimeBlock = getNextTimeBlock(self.currTimeBlock);
        if (self.currTimeBlock == 0) {
            [self.finalScheduleDictionary setObject:dayPath forKey:self.currDate];
            self.currDate = getNextDate(self.currDate, 1);
            dayPath = [[NSMutableArray alloc] init];
            currPlace = self.home;
        }
        allPlacesVisited = [self visitedAllPlaces];
        withinDateRange = [self checkEndDate:self.currDate];
    }
    if (dayPath.count > 0) {
        [self.finalScheduleDictionary setObject:dayPath forKey:self.currDate];
    }
    return self.finalScheduleDictionary;
}

- (void)addAndUpdatePlace:(NSMutableArray *)dayPath atTime:(TimeBlock)currTimeBlock
{
    if (self.currClosestPlace) {
        [dayPath insertObject:self.currClosestPlace atIndex:self.currTimeBlock];
        self.currClosestPlace.hasAlreadyGone = true;
        self.currClosestPlace.scheduledTimeBlock = self.currTimeBlock;
        self.currClosestPlace.tempBlock = self.currTimeBlock;
    } else {
        [dayPath insertObject:self.home atIndex:self.currTimeBlock]; //putting self.home means empty
    }
}

- (void)getClosestAvailablePlace:(Place *)origin atTime:(TimeBlock)timeBlock onDate:(NSDate *)date
{
    NSArray *availablePlaces = getAvailableFilteredArray(self.availabilityDictionary[@(timeBlock)][@(getDayOfWeekAsInt(date))]);
    self.currClosestPlace = nil;
    self.currClosestTravelDistance = @(-1);
    float originLat = [origin.coordinates[@"lat"] floatValue];
    float originLng = [origin.coordinates[@"lng"] floatValue];
    for (Place *place in availablePlaces) {
        NSNumber *cachedDistance = [origin.cachedDistances valueForKey:place.placeId];
        float distance;
        if (cachedDistance) {
            distance = [cachedDistance floatValue];
        } else {
            float placeLat = [place.coordinates[@"lat"] floatValue];
            float placeLng = [place.coordinates[@"lng"] floatValue];
            float xDiff = originLat - placeLat;
            float yDiff = originLng - placeLng;
            distance = sqrtf(xDiff * xDiff + yDiff * yDiff);
            [origin.cachedDistances setValue:@(distance) forKey:place.placeId];
        }
        //NSLog([NSString stringWithFormat:@"Distance from %@ to %@ is %f", origin.name, place.name, distance]); //TESTING
        BOOL destinationCloser = distance < [self.currClosestTravelDistance floatValue];
        BOOL firstPlace = [self.currClosestTravelDistance floatValue] < 0;
        if ((destinationCloser || firstPlace) && !place.hasAlreadyGone && !place.locked) {
            self.currClosestTravelDistance = @(distance);
            self.currClosestPlace = place;
        }
    }
    if (self.currClosestPlace) {
        [self setTravelTimeFromOrigin:origin toPlace:self.currClosestPlace];
    }
}

- (BOOL)findAndSetLockedPlaceForDate:(NSDate *)date time:(TimeBlock)time
{
    if (!self.lockedDatePlaces) {
        return false;
    }
    NSDictionary *dayDict = [self.lockedDatePlaces valueForKey:getDateAsString(date)];
    if (dayDict) {
        Place *lockedPlace = [dayDict valueForKey:[NSString stringWithFormat: @"%ld", (long)time]];
        if (lockedPlace) {
            self.currClosestPlace = lockedPlace;
            return true;
        }
    }
    return false;
}

- (void)setTravelTimeFromOrigin:(Place *)origin toPlace:(Place *)place
{
//    if (origin == self.hub || place == self.hub) {
//        __block Place *startPlace = origin;
//        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//        [[APIManager shared] getDistanceFromOrigin:origin.placeId toDestination:place.placeId withCompletion:^(NSDictionary *distanceDurationDictionary, NSError *error) {
//            if (distanceDurationDictionary) {
//                NSNumber *timeDistance = [distanceDurationDictionary valueForKey:@"value"][0][0];
//                if (self.currClosestPlace) {
//                    self.currClosestPlace.travelTimeToPlace = timeDistance;
//                    [startPlace.cachedTimeDistances setValue:timeDistance forKey:self.currClosestPlace.placeId];
//                }
//            } else {
//                NSLog(@"Error getting closest place: %@", error.localizedDescription);
//            }
//            dispatch_semaphore_signal(sema);
//        }];
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//    }
    Commute *commuteInfo = [[Commute alloc] initWithOrigin:origin.placeId toDestination:place.placeId withDepartureTime:0];
    commuteInfo.origin = origin;
    commuteInfo.destination = place;
    if (origin != self.home) {
        origin.commuteFrom = commuteInfo;
    }
    place.commuteTo = commuteInfo;
    place.travelTimeToPlace = commuteInfo.durationInSeconds;
    [origin.cachedTimeDistances setValue:commuteInfo.durationInSeconds forKey:place.placeId];
}


- (BOOL)visitedAllPlaces
{
    for (Place *place in self.arrayOfAllPlaces) {
        if (!place.hasAlreadyGone) {
            return false;
        }
    }
    return true;
}

- (BOOL)checkEndDate:(NSDate *)date
{
    return !self.indefiniteTime && ([self.endDate compare:date] != NSOrderedAscending);
}

#pragma mark - helper methods for initialization

- (void)createAvailabilityDictionary
{
    for(int dayInt = DayOfWeekSunday; dayInt <= DayOfWeekSaturday; ++dayInt) {
        NSNumber *day = [[NSNumber alloc]initWithInt:dayInt];
        for(Place *attraction in self.arrayOfAllPlaces) {
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockMorning)]) {
                [self.availabilityDictionary[@(TimeBlockMorning)][day] addObject:attraction];
            }
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockLunch)]) {
                [self.availabilityDictionary[@(TimeBlockLunch)][day] addObject:attraction];
            }
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockAfternoon)]) {
                [self.availabilityDictionary[@(TimeBlockAfternoon)][day] addObject:attraction];
            }
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockDinner)]) {
                [self.availabilityDictionary[@(TimeBlockDinner)][day] addObject:attraction];
            }
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockEvening)]) {
                [self.availabilityDictionary[@(TimeBlockEvening)][day] addObject:attraction];
            }
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(TimeBlockBreakfast)]) {
                [self.availabilityDictionary[@(TimeBlockBreakfast)][day] addObject:attraction];
            }
        }
    }
}

- (void)createAllProperties
{
    self.availabilityDictionary = [[NSMutableDictionary alloc] init];
    for (TimeBlock i = TimeBlockBreakfast; i <= TimeBlockEvening; i++) {
        NSMutableDictionary *dayDict = [[NSMutableDictionary alloc] init];
        for (int j = DayOfWeekSunday; j <= DayOfWeekSaturday; j++) {
            [dayDict setObject:[[NSMutableArray alloc] init] forKey:@(j)];
        }
        [self.availabilityDictionary setObject:dayDict forKey:@(i)];
    }
    self.lockedDatePlaces = [[NSMutableDictionary alloc] init];
}

@end
