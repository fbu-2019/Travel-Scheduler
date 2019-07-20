//
//  Commute.h
//  Travel Scheduler
//
//  Created by gilemos on 7/20/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface Commute : NSObject
@property(nonatomic, strong)Place *origin;
@property(nonatomic, strong)Place *destination;
@property(nonatomic, strong)NSDictionary *fare;
@property(nonatomic, strong)NSMutableArray *arrayOfSteps;
@property(strong, nonatomic)NSString *distance;
@property(strong, nonatomic)NSString *duration;
@property(strong, nonatomic)NSString *durationInSeconds;
@property(strong, nonatomic)NSDate *arrivalTimeNSDate;
@property(strong, nonatomic)NSString *arrivalTimeText;
@property(nonatomic)int departureTimeInSecondsSince1970;


@end

NS_ASSUME_NONNULL_END
