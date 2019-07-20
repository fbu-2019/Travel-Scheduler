//
//  Step.h
//  Travel Scheduler
//
//  Created by gilemos on 7/20/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Step : NSObject

@property(strong, nonatomic)NSString *distance;
@property(strong, nonatomic)NSString *duration;
@property(strong, nonatomic)NSString *departureStop;
@property(strong, nonatomic)NSString *departureTime;
@property(strong, nonatomic)NSString *arrivalStop;
@property(strong, nonatomic)NSString *arrivalTime;
@property(strong, nonatomic)NSString *numberOfStops;
@property(strong, nonatomic)NSDictionary *line;
@property(strong, nonatomic)NSDictionary *vehicle;
@property(strong, nonatomic)NSString *directionToGo;
@property(strong, nonatomic)NSString *secondsBetweenTwoDepartures;

@end

NS_ASSUME_NONNULL_END
