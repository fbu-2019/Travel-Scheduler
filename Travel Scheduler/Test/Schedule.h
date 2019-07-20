//
//  Schedule.h
//  Travel Scheduler
//
//  Created by gilemos on 7/19/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface Schedule : NSObject

@property (strong, nonatomic) NSMutableArray *arrayOfAllPlaces;
@property (strong, nonatomic) NSMutableDictionary *availabilityDictionary;
@property (strong, nonatomic) NSMutableDictionary *finalScheduleDictionary;
@property (strong, nonatomic) Place *home;
@property (nonatomic) int numberOfDays;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) Place *currClosestPlace;
@property (strong, nonatomic) NSNumber *currClosestTravelDistance;

@property (nonatomic) BOOL indefiniteTime;

- (instancetype)initWithArrayOfPlaces:(NSArray *)completeArrayOfPlaces withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate;

@end

NS_ASSUME_NONNULL_END
