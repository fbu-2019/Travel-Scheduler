//
//  Schedule.m
//  Travel Scheduler
//
//  Created by gilemos on 7/19/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Schedule.h"
#import "Date.h"

@implementation Schedule

#pragma mark - initialization methods
- (instancetype)initWithArrayOfPlaces:(NSArray *)completeArrayOfPlaces withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate
{
    self = [super init];
    [self createAllProperties];
    [self.arrayOfAllPlaces arrayByAddingObjectsFromArray:completeArrayOfPlaces];
    [self createAvaliabilityDictionary];
    self.startDate = startDate;
    self.endDate = endDate;
    self.numberOfDays = (int)[Date daysBetweenDate:startDate andDate:endDate];
    return self;
}

#pragma mark - helper methods for initialization
- (void)createAllProperties
{
    self.availabilityDictionary = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"breakfast"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"morning"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"lunch"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"afternoon"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"dinner"] = [[NSMutableDictionary alloc] init];
    self.availabilityDictionary[@"evening"] = [[NSMutableDictionary alloc] init];
    self.arrayOfAllPlaces = [[NSMutableArray alloc] init];
}

-(void)createAllArraysAtDay:(NSNumber *)day
{
    self.availabilityDictionary[@"breakfast"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"morning"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"lunch"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"afternoon"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"dinner"][day] = [NSMutableArray init];
    self.availabilityDictionary[@"evening"][day] = [NSMutableArray init];
}

- (void)createAvaliabilityDictionary
{
    for(int dayInt = 0; dayInt <= 6; ++dayInt) {
        NSNumber *day = [[NSNumber alloc]initWithInt:dayInt];
        [self createAllArraysAtDay:day];
        
        for(Place *attraction in self.arrayOfAllPlaces) {
            if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(1)]) {
                [self.availabilityDictionary[@"morning"][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(2)]) {
                [self.availabilityDictionary[@"lunch"][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(3)]) {
               [self.availabilityDictionary[@"afternoon"][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(4)]) {
                [self.availabilityDictionary[@"dinner"][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(5)]) {
                [self.availabilityDictionary[@"evening"][day] addObject:attraction];
            } else if([attraction.openingTimesDictionary[day][@"periods"] containsObject:@(0)]) {
                [self.availabilityDictionary[@"breakfast"][day] addObject:attraction];
            }
        }
    }
}


@end
