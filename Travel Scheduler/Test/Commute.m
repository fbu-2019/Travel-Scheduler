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

-(instancetype)initWithOrigin:(NSString *)originId toDestination:(NSString *)destinationId withDepartureTime:(int)departureTime{
    self = [super init];
    self.departureTimeInSecondsSince1970 = departureTime;
    [[APIManager shared]getCommuteDetailsFromOrigin:originId toDestination:destinationId withDepartureTime:departureTime withCompletion:^(NSArray *commuteInfoArray, NSError *error) {
        if(commuteInfoArray) {
            [self createAllProperties];
            [self buildCommuteWithDictionary:commuteInfoArray[0]];
            [self makeArrayOfStepsWithRootDictionary:commuteInfoArray[0]];
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
    return self;
}

-(void)createAllProperties {
    self.arrayOfSteps = [[NSMutableArray alloc] init];
    self.fare = [[NSDictionary alloc] init];
}

-(void)buildCommuteWithDictionary:(NSDictionary *)rootDictionary {
    if ([[rootDictionary allKeys] containsObject:@"fare"]) {
        self.fare = rootDictionary[@"fare"];
    }
    self.distance = rootDictionary[@"legs"][0][@"distance"][@"value"];
    self.duration = rootDictionary[@"legs"][0][@"duration"][@"text"];
    self.durationInSeconds = rootDictionary[@"legs"][0][@"duration"][@"value"];
    self.arrivalTimeText = rootDictionary[@"legs"][0][@"arrival_time"][@"text"];
    self.arrivalTimeNSDate = rootDictionary[@"legs"][0][@"arrival_time"][@"value"];
}

-(void)makeArrayOfStepsWithRootDictionary:(NSDictionary *)dictionary {
    self.arrayOfSteps = [Step makeArrayOfStepsWithArrayOfDictionaries:dictionary[@"legs"][0][@"steps"]];
}

@end
