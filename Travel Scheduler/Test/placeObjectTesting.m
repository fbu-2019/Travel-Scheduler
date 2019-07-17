//
//  placeObjectTesting.m
//  Travel Scheduler
//
//  Created by gilemos on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "placeObjectTesting.h"

@implementation placeObjectTesting

+ (void)initWithNameTest{
    [[Place alloc] initWithName:@"MPK" withCompletion:^(Place *place, NSError *error) {
        if(place) {
            NSLog(@"I WORKED");
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
    
}

+ (void)testGetClosebyLocations {
    [[Place alloc] getListOfPlacesCloseToPlaceWithName:@"MPK" withCompletion:^(NSMutableArray *array, NSError *error) {
        if(array) {
            NSLog(@"I WORKED");
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
    
}

@end
