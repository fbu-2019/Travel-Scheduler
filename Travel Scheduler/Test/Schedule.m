//
//  Schedule.m
//  Travel Scheduler
//
//  Created by gilemos on 7/19/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Schedule.h"

@implementation Schedule

#pragma mark - initialization methods
- (instancetype)initWithArrayOfPlaces:(NSArray *)completeArrayOfPlaces withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate {
    self = [super init];
    [self initAllProperties];
    [self.arrayOfAllPlaces arrayByAddingObjectsFromArray:completeArrayOfPlaces];
    [self createAvaliabilityDictionary];
    self.startDate = startDate;
    self.endDate = endDate;
    self.numberOfDays = (int)[Schedule daysBetweenDate:startDate andDate:endDate];
    return self;
}

#pragma mark - helper methods for initialization
- (void)initAllProperties {
    self.availabilityDictionary = [[NSMutableDictionary alloc] init];
    self.arrayOfAllPlaces = [[NSMutableArray alloc] init];
}

- (void)createAvaliabilityDictionary {
    for(int dayInt = 0; dayInt <= 5; ++dayInt) {
        NSNumber *day = [[NSNumber alloc]initWithInt:dayInt];
        
        for(Place *attraction in self.arrayOfAllPlaces) {
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(1)]) {
                self.availabilityDictionary[@"morning"][day] = attraction;
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(2)]) {
                self.availabilityDictionary[@"lunch"][day] = attraction;
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(3)]) {
                self.availabilityDictionary[@"afternoon"][day] = attraction;
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(4)]) {
                self.availabilityDictionary[@"dinner"][day] = attraction;
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(5)]) {
                self.availabilityDictionary[@"evening"][day] = attraction;
            }
            else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(0)]) {
                self.availabilityDictionary[@"breakfast"][day] = attraction;
            }
        }
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
