//
//  APITesting.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "APITesting.h"
#import "APIManager.h"

@implementation APITesting

+(void)testCompleteInfo {
    
    [[APIManager shared]getCompleteInfoOfLocationWithId:@"ChIJR_oXUZa8j4ARk7FaWcK71KA" withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            NSLog(@"I WORKED");
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
}

+(void)testGetId {
    [[APIManager shared]getIdOfLocationWithName:@"MPK" withCompletion:^(NSString *placeId, NSError *error) {
        if(placeId) {
            NSLog(@"I WORKED");
        }
        else {
            NSLog(@"did not work snif");
        }
    }];

}
@end
