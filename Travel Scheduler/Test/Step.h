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

@property (strong, nonatomic) NSNumber *distance;
@property (strong, nonatomic) NSNumber *durationInSeconds;
@property (strong, nonatomic) NSString *departureStop;
@property (strong, nonatomic) NSString *departureTime;
@property (strong, nonatomic) NSString *arrivalStop;
@property (strong, nonatomic) NSString *arrivalTime;
@property (strong, nonatomic) NSNumber *numberOfStops;
@property (strong, nonatomic) NSDictionary *line;
@property (strong, nonatomic) NSString *vehicle;
@property (strong, nonatomic) NSString *directionToGo;
@property (strong, nonatomic) NSNumber *secondsBetweenTwoDepartures;

- (instancetype)initWithDictionary:(NSDictionary *)rootDictionary;
+ (NSMutableArray *)makeArrayOfStepsWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries;

@end

NS_ASSUME_NONNULL_END
