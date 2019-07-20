//
//  Step.m
//  Travel Scheduler
//
//  Created by gilemos on 7/20/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Step.h"
#import "APIManager.h"

@implementation Step

-(instancetype)initWithDictionary:(NSDictionary *)rootDictionary {
    self = [super init];
    [self initAllProperties];
    self.distance = rootDictionary[@"distance"][@"value"];
    self.durationInSeconds = rootDictionary[@"duration"][@"value"];
    self.departureStop = rootDictionary[@"transit_details"][@"departure_stop"][@"name"];
    self.arrivalStop = rootDictionary[@"transit_details"][@"arrival_stop"][@"name"];
    self.departureTime = rootDictionary[@"transit_details"][@"departure_time"][@"text"];
    self.arrivalTime = rootDictionary[@"transit_details"][@"arrival_time"][@"text"];
    self.directionToGo = rootDictionary[@"transit_details"][@"headsign"];
    self.numberOfStops = rootDictionary[@"transit_details"][@"num_stops"];
    self.vehicle = rootDictionary[@"transit_details"][@"line"][@"vehicle"];
    self.line = rootDictionary[@"transit_details"][@"line"];
    
    if ([[rootDictionary[@"transit_details"] allKeys] containsObject:@"headway"]) {
        self.secondsBetweenTwoDepartures = rootDictionary[@"transit_details"][@"headway"];
    }
    else {
        self.secondsBetweenTwoDepartures = [[NSNumber alloc]initWithInt:-1];
    }
    
    return self;
}

-(void)initAllProperties {
    self.line = [[NSDictionary alloc] init];
    self.vehicle = [[NSDictionary alloc] init];
}

+(NSMutableArray *)makeArrayOfStepsWithArrayOfDictionaries:(NSArray *)arrayOfDictionaries {
    NSMutableArray *arrayOfSteps = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dictionary in arrayOfDictionaries) {
        Step *step = [[Step alloc]initWithDictionary:dictionary];
        [arrayOfSteps addObject:step];
    }
    return arrayOfSteps;
}
@end
