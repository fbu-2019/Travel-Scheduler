//
//  APITesting.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "APITesting.h"
#import "APIManager.h"
#import "Step.h"
#import "Commute.h"

@implementation APITesting

+ (void)testCompleteInfo
{
    
    [[APIManager shared]getCompleteInfoOfLocationWithId:@"ChIJH4-m9D6uEmsRy7hgF2btwT0" withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            NSLog(@"I WORKED");
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
}

+ (void)testGetId
{
    [[APIManager shared]getIdOfLocationWithName:@"MPK" withCompletion:^(NSString *placeId, NSError *error) {
        if(placeId) {
            NSLog(@"I WORKED");
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
    
}

+ (void)testCompleteInfoWithName
{
    [[APIManager shared]getCompleteInfoOfLocationWithName:@"MPK" withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            NSLog(@"I WORKED");
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
    
}

+ (void)commuteDetailsTest
{
    [[APIManager shared]getCommuteDetailsFromOrigin:@"ChIJzd7xXsm6j4ARUp8sFUMNrWs" toDestination:@"ChIJ59OJRxq7j4ARx5SvEGmwmJg" withDepartureTime:1563658173 withCompletion:^(NSArray *commuteInfoDictionary, NSError *error) {
        if(commuteInfoDictionary) {
            NSLog(@"I WORKED");
            Step *step = [[Step alloc]initWithDictionary:commuteInfoDictionary[0][@"legs"][0][@"steps"][0]];
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
    
}

+ (void)commuteObjectTest
{
    Commute *commute = [[Commute alloc]initWithOrigin:@"ChIJzd7xXsm6j4ARUp8sFUMNrWs" toDestination:@"ChIJ59OJRxq7j4ARx5SvEGmwmJg" withDepartureTime:1563658173];
}

//+(void)photoTest {
//    [[APIManager shared]getPhotoFromReference:@"mRaAAAAdHhe3GAadL3klZ1S8_S5dgsf-aGOefYp20QVtxxkXwNOLqen8f8P9IwyNZVS9Zj0HGT2ZtsR8eanHeZ0bNzAVpMoxHest3yJh_-LiApVKr0wFvqJFKNCumFOVUCRbKdnEhA4eiJdijeFOxsgdXk_0HJaGhSnki-Eq2yCr5Dho4TCYSYPAvp67A" withCompletion:^(UIImage *photo, NSError *error) {
//        if(photo) {
//            NSLog(@"I reWORKED");
//        }
//        else {
//            NSLog(@"did not work snif");
//        }
//    }];
//    
//}
@end
