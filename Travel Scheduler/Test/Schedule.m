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

#pragma mark - Algorithm helper methods

static int getNextTimeBlock(int timeBlock) {
    if (timeBlock == dinner) {
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
    [self.arrayOfAllPlaces arrayByAddingObjectsFromArray:completeArrayOfPlaces];
    [self createAvaliabilityDictionary];
    self.startDate = startDate;
    self.endDate = endDate;
    self.indefiniteTime = (self.startDate == nil || self.endDate == nil);
    self.numberOfDays = (int)[Date daysBetweenDate:startDate andDate:endDate];

    
    //[self.arrayOfAllPlaces arrayByAddingObjectsFromArray:completeArrayOfPlaces];
    [self testing];
    //self.home = [self.arrayOfAllPlaces objectAtIndex:0];
    //[self createAvaliabilityDictionary];
    
    //self.numberOfDays = (int)[Schedule daysBetweenDate:startDate andDate:endDate];
    
    return self;
}

- (void)testing {
    self.startDate = [NSDate date];
    self.endDate = nil;
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    [[APIManager shared]getPlacesCloseToLatitude:@"37.7749" andLongitude:@"-122.4194" ofType:@"museum" withCompletion:^(NSArray *arrayOfPlaces, NSError *error) {
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
    
    [self generateSchedule];
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
    Place *currPlace = [self.arrayOfAllPlaces objectAtIndex:0];
    self.arrayOfAllPlaces = [self.arrayOfAllPlaces subarrayWithRange:NSMakeRange(1, self.arrayOfAllPlaces.count - 1)];
    [self createAvaliabilityDictionary];
    int currTimeBlock = breakfast;
    /*if (!self.indefiniteTime) {
     [self createEmptyScheduleDictionary]; //I'll do this later...
     }*/
    BOOL scheduleNotFull = ![self finalScheduleIsFull];
    BOOL allPlacesVisited = [self visitedAllPlaces];
    while (scheduleNotFull || (self.indefiniteTime && !allPlacesVisited)) {
        NSMutableArray *availablePlaces = self.availabilityDictionary[@(currTimeBlock)][@(getDayOfWeekAsInt(currDate))];
        //TODO:the priority thing... idk where it is???
        
        //dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [self getClosestAvailablePlace:currPlace atTime:currTimeBlock onDate:currDate //withCompletion:^(Place *destination, NSError *error) {
         /*if (destination) {
          NSLog([NSString stringWithFormat:@"closest place is: %@", destination.name]);
          } else {
          
          NSLog(@"No closest place");
          }
          dispatch_semaphore_signal(sema);*/
         //}
         ];
        //dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        [self addAndUpdatePlace:dayPath atTime:currTimeBlock];
        currTimeBlock = getNextTimeBlock(currTimeBlock);
        if (currTimeBlock == 0) {
            [self.finalScheduleDictionary setObject:dayPath forKey:currDate];
            currDate = getNextDate(currDate, 1);
        }
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
        [dayPath insertObject:@"empty" atIndex:currTimeBlock];
    }
}

- (void *)getClosestAvailablePlace:(Place *)origin atTime:(int)timeBlock onDate:(NSDate *)date //withCompletion:(void(^)(Place *place, NSError *error))completion {
{
    NSMutableArray *availablePlaces = self.availabilityDictionary[@(timeBlock)][@(getDayOfWeekAsInt(date))];
    //TODO:the priority thing... idk where it is???
    self.currClosestPlace = nil;
    self.currClosestTravelDistance = @(-1);
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
    return nil;
}

- (BOOL)visitedAllPlaces {
    for (Place *place in self.arrayOfAllPlaces) {
        if (!place.hasAlreadyGone) {
            return false;
        }
    }
    return true;
}

- (BOOL)finalScheduleIsFull {
    for (NSDate *date in self.finalScheduleDictionary) {
        NSMutableArray *dayArray = [self.finalScheduleDictionary objectForKey:date];
        for (int i = 0; i < dayArray.count; i++) {
            if (dayArray[i] == nil) {
                return false;
            }
        }
    }
    return true;
}

- (void)createEmptyScheduleDictionary {
    NSDate *tempDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:self.startDate];
    tempDate = removeTime(tempDate);
    while ([tempDate compare:self.endDate] != NSOrderedDescending) {
        [self.finalScheduleDictionary setObject:[NSMutableArray arrayWithCapacity:6] forKey:tempDate];
        tempDate = getNextDate(tempDate, 1);
    }
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
        for(Place *place in self.arrayOfAllPlaces) {
            if([place.openingTimesDictionary[day][@"periods"] containsObject:@(1)]) {
                [self.availabilityDictionary[@(morning)][day] addObject:place];
            }
            if([place.openingTimesDictionary[day][@"periods"] containsObject:@(2)]) {
                [self.availabilityDictionary[@(lunch)][day] addObject:place];
            }
            if([place.openingTimesDictionary[day][@"periods"] containsObject:@(3)]) {
                [self.availabilityDictionary[@(afternoon)][day] addObject:place];
            }
            if([place.openingTimesDictionary[day][@"periods"] containsObject:@(4)]) {
                [self.availabilityDictionary[@(dinner)][day] addObject:place];
            }
            if([place.openingTimesDictionary[day][@"periods"] containsObject:@(5)]) {
                [self.availabilityDictionary[@(evening)][day] addObject:place];
            }
            if([place.openingTimesDictionary[day][@"periods"] containsObject:@(0)]) {
                [self.availabilityDictionary[@(breakfast)][day] addObject:place];
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
