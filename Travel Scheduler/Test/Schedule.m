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

//DELETE AFTER PULLED FROM MASTER
static NSDate* getNextDate(NSDate *date, int offset) {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    NSInteger theDay = [todayComponents day];
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:offset];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    return nextDate;
}
//MOVE TO HELPER FILE LATER
static NSDate* removeTime(NSDate *date) {
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}



#pragma mark - Algorithm helper methods

static int getNextTimeBlock(int timeBlock) {
    if (timeBlock == dinner) {
        return 0;
    }
    return timeBlock + 1;
}

static int getDayOfWeekAsInt(NSDate *date) {
    
    //Use the helper to get this later
    //NSString *dayString = getDayOfWeek(date);
    NSDateFormatter* day = [[NSDateFormatter alloc] init];
    [day setDateFormat: @"EEEE"];
    NSString *dayString = [day stringFromDate:date];
    
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
    [self initAllProperties];
    [self.arrayOfAllPlaces arrayByAddingObjectsFromArray:completeArrayOfPlaces];
    //self.home = [self.arrayOfAllPlaces objectAtIndex:0];
    //[self createAvaliabilityDictionary];
    self.startDate = startDate;
    self.endDate = endDate;
    self.indefiniteTime = (self.startDate == nil || self.endDate == nil);

    //self.numberOfDays = (int)[Schedule daysBetweenDate:startDate andDate:endDate];
    
    
    //TESTING
    self.startDate = [NSDate date];
    self.endDate = getNextDate(self.startDate, 10);
    [self generateSchedule];
    
    
    
    return self;
}

#pragma mark - algorithm that generates schedule

- (NSDictionary *)generateSchedule {
    self.finalScheduleDictionary = [[NSMutableDictionary alloc] init];
    NSDate *currDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:self.startDate];
    NSMutableArray *dayPath = [[NSMutableArray alloc] initWithCapacity:6];
    Place *currPlace = self.home;
    int currTimeBlock = breakfast;
    /*if (!self.indefiniteTime) {
        [self createEmptyScheduleDictionary]; //I'll do this later...
    }*/
    BOOL scheduleNotFull = ![self finalScheduleIsFull];
    BOOL allPlacesVisited = [self visitedAllPlaces];
    while (scheduleNotFull || (self.indefiniteTime && !allPlacesVisited)) {
        NSMutableArray *availablePlaces = self.availabilityDictionary[@(currTimeBlock)][@(getDayOfWeekAsInt(currDate))];
        //TODO:the priority thing... idk where it is???
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [self getClosestAvailablePlace:currPlace atTime:currTimeBlock onDate:currDate withCompletion:^(Place *destination, NSError *error) {
            dispatch_semaphore_signal(sema);
        }];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
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

- (void *)getClosestAvailablePlace:(Place *)origin atTime:(int)timeBlock onDate:(NSDate *)date withCompletion:(void(^)(Place *place, NSError *error))completion {
    NSMutableArray *availablePlaces = self.availabilityDictionary[@(timeBlock)][@(getDayOfWeekAsInt(date))];
    //TODO:the priority thing... idk where it is???
    self.currClosestPlace = nil;
    self.currClosestTravelDistance = @(-1);
    for (Place *destination in availablePlaces) {
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
        }];
    }
    completion(self.currClosestPlace, nil);
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

- (void)initAllProperties {
    self.availabilityDictionary = [[NSMutableDictionary alloc] init];
    self.arrayOfAllPlaces = [[NSMutableArray alloc] init];
}

- (void)createAvaliabilityDictionary {
    for(int dayInt = 0; dayInt <= 6; ++dayInt) {
        NSNumber *day = [[NSNumber alloc]initWithInt:dayInt];
        [self initAllArraysAtDay:day];
        
        for(Place *place in self.arrayOfAllPlaces) {
            if([place.openingTimesDictionary[day][@"periods"] containsObject:@(1)]) {
                [self.availabilityDictionary[@(morning)][day] addObject:place];
            }
            else if([place.openingTimesDictionary[day][@"periods"] containsObject:@(2)]) {
                [self.availabilityDictionary[@(lunch)][day] addObject:place];
            }
            else if([place.openingTimesDictionary[day][@"periods"] containsObject:@(3)]) {
               [self.availabilityDictionary[@(afternoon)][day] addObject:place];
            }
            else if([place.openingTimesDictionary[day][@"periods"] containsObject:@(4)]) {
                [self.availabilityDictionary[@(dinner)][day] addObject:place];
            }
            else if([place.openingTimesDictionary[day][@"periods"] containsObject:@(5)]) {
                [self.availabilityDictionary[@(evening)][day] addObject:place];
            }
            else if([place.openingTimesDictionary[day][@"periods"] containsObject:@(0)]) {
                [self.availabilityDictionary[@(breakfast)][day] addObject:place];
            }
        }
    }
}

-(void)initAllArraysAtDay:(NSNumber *)day {
    self.availabilityDictionary[@"breakfast"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"morning"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"lunch"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"afternoon"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"dinner"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"evening"][day] = [NSMutableArray init];
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
