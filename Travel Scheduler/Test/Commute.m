//
//  Commute.m
//  Travel Scheduler
//
//  Created by gilemos on 7/20/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Commute.h"
#import "APIManager.h"
#import "Step.h"

@implementation Commute

#pragma mark - Initialization methods
- (instancetype)initWithOrigin:(NSString *)originId toDestination:(NSString *)destinationId withDepartureTime:(int)departureTime
{
    self = [super init];
    //TESTING
//    self.departureTimeInSecondsSince1970 = departureTime;
    self.departureTimeInSecondsSince1970 = 1261000000;
    dispatch_semaphore_t getCommute = dispatch_semaphore_create(0);
    [[APIManager shared]getCommuteDetailsFromOrigin:originId toDestination:destinationId withDepartureTime:departureTime withCompletion:^(NSArray *commuteInfoArray, NSError *error) {
        if(commuteInfoArray) {
            [self createAllProperties];
            [self buildCommuteWithDictionary:commuteInfoArray[0]];
            [self makeArrayOfStepsWithRootDictionary:commuteInfoArray[0]];
        } else {
            NSLog(@"did not work snif");
        }
        dispatch_semaphore_signal(getCommute);
    }];
    dispatch_semaphore_wait(getCommute, DISPATCH_TIME_FOREVER);
    return self;
}

- (void)buildCommuteWithDictionary:(NSDictionary *)rootDictionary
{
    if ([[rootDictionary allKeys] containsObject:@"fare"]) {
        self.fare = rootDictionary[@"fare"];
    }
    self.distance = rootDictionary[@"legs"][0][@"distance"][@"value"];
    self.duration = rootDictionary[@"legs"][0][@"duration"][@"text"];
    self.durationInSeconds = rootDictionary[@"legs"][0][@"duration"][@"value"];
    self.arrivalTimeText = rootDictionary[@"legs"][0][@"arrival_time"][@"text"];
    self.arrivalTimeNSDate = rootDictionary[@"legs"][0][@"arrival_time"][@"value"];
}

#pragma mark - Helper methods for initialization
- (void)createAllProperties
{
    self.arrayOfSteps = [[NSMutableArray alloc] init];
    self.fare = [[NSDictionary alloc] init];
}

- (void)makeArrayOfStepsWithRootDictionary:(NSDictionary *)dictionary
{
    self.arrayOfSteps = [Step makeArrayOfStepsWithArrayOfDictionaries:dictionary[@"legs"][0][@"steps"]];
}

@end
