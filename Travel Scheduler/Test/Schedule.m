//
//  Schedule.m
//  Travel Scheduler
//
//  Created by gilemos on 7/19/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Schedule.h"

@implementation Schedule

- (instancetype)initWithArrayOfPlaces:(NSArray *)completeArrayOfPlaces withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate {
    self = [super init];
    [self initAllArrays];
    for(Place *place in completeArrayOfPlaces) {
//        if([place.specificType isEqualToString:@"restaurant"]) {
//            [self.arrayOfRestaurants addObject:place];
//        }
//        else {
//            [self.arrayOfAttractions addObject:place];
//        }
        
    }
    
    
    
    return self;
}

- (void)initAllArrays {
    self.arrayOfAttractions = [[NSMutableArray alloc] init];
    self.morningAttractions = [[NSMutableArray alloc] init];
    self.afternoonAttractions = [[NSMutableArray alloc] init];
    self.eveningAttractions = [[NSMutableArray alloc] init];
    self.breakfastRestaurants = [[NSMutableArray alloc] init];
    self.lunchRestaurants = [[NSMutableArray alloc] init];
    self.dinnerRestaurants = [[NSMutableArray alloc] init];
    self.arrayOfRestaurants = [[NSMutableArray alloc] init];
}

- (void)segmentArrayOfAttractionsByDayPeriod {
    for(Place *attraction in self.arrayOfAttractions) {
//        if(
//        
   }
}
@end
