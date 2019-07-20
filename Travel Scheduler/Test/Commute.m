//
//  Commute.m
//  Travel Scheduler
//
//  Created by gilemos on 7/20/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Commute.h"
#import "APIManager.h"

@implementation Commute

-(instancetype)initWithOrigin:(NSString *)originId toDestination:(NSString *)destinationId {
    self = [self init];
    [[APIManager shared]getCommuteDetailsFromOrigin:originId toDestination:destinationId withCompletion:^(NSDictionary *commuteInfoDictionary, NSError *error) {
        if(commuteInfoDictionary) {
            [self initAllProperties];
            [self buildCommuteWithDictionary:commuteInfoDictionary];
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
    return self;
}

-(void)initAllProperties {
    self.arrayOfSteps = [[NSMutableArray alloc] init];
    self.fare = [[NSDictionary alloc] init];
}

-(void)buildCommuteWithDictionary:(NSDictionary *)rootDictionary {
    if ([[rootDictionary allKeys] containsObject:@"fare"]) {
        self.fare = rootDictionary[@"fare"];
    }
    self.distance = rootDictionary[@"legs"][@"distance"][@"value"];
    self.duration = rootDictionary[@"legs"][@"duration"][@"text"];
    self.durationInSeconds = rootDictionary[@"legs"][@"duration"][@"value"];
    self.arrivalTimeText = rootDictionary[@"legs"][@"arrival_time"][@"text"];
    self.arrivalTimeNSDate = rootDictionary[@"legs"][@"arrival_time"][@"value"];
}

@end
