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
    self.distance = rootDictionary[@"distance"];
    self.duration = rootDictionary[@"duration"];
    self.departureStop = rootDictionary[@"transit_details"][@"departure_stop"][@"name"];
    self.arrivalStop = rootDictionary[@"transit_details"][@"arrival_stop"][@"name"];
    self.departureTime = rootDictionary[@"transit_details"][@"departure_time"][@"text"];
    self.arrivalTime = rootDictionary[@"transit_details"][@"arrival_time"][@"text"];
    self.directionToGo = rootDictionary[@"transit_details"][@"headsign"];
    self.numberOfStops = rootDictionary[@"transit_details"][@"num_stops"];
    self.secondsBetweenTwoDepartures = rootDictionary[@"transit_details"][@"headway"];
    self.vehicle = rootDictionary[@"transit_details"][@"line"][@"vehicle"];
    self.line = rootDictionary[@"transit_details"][@"line"];
    
    return self;
}

@end
