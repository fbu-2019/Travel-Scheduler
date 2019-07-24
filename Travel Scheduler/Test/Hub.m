//
//  Hub.m
//  Travel Scheduler
//
//  Created by gilemos on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Hub.h"
#import "APIManager.h"
#import "NSArray+Map.h"

@implementation Hub

#pragma mark - Initialization
- (instancetype)initHubWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    [self createAllProperties];
    return self;
}

-(instancetype)initHubWithName:(NSString *)name withCompletion:(void (^)(bool sucess, NSError *error))completion {
    self = [super init];
    self = [super initWithName:name withCompletion:^(bool sucess, NSError *error){
        if(sucess) {
            completion(YES, nil);
            [self createAllProperties];
        }
        else {
            completion(NO, error);
        }
    }];
    return self;
}

#pragma mark - Helper methods for initizalization
-(void)createAllProperties {
    self.imageView = [[UIImageView alloc] init];
    self.dictionaryOfArrayOfPlaces = [[NSMutableDictionary alloc] init];
}

#pragma mark - Methods to get the array of nearby places
/*
- (void)makeArrayOfNearbyPlacesWithType:(NSString *)type withCompletion:(void (^)(bool success, NSError *error))completion {
    [[APIManager shared]getPlacesCloseToLatitude:self.coordinates[@"lat"] andLongitude:self.coordinates[@"lng"] ofType:type withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
        if(arrayOfPlacesDictionary) {
            NSLog(@"Array of places dictionary worked");
            [self placesWithArray:arrayOfPlacesDictionary withType:type];
            completion(YES, nil);
        }
        else {
            NSLog(@"did not work snif");
            completion(nil, getPlacesError);
        }
    }];
}*/

- (void)placesWithArray:(NSArray *)arrayOfPlaceDictionaries withType:(NSString *)type{
    NSArray* newArray = [arrayOfPlaceDictionaries mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
        Place *place = [[Place alloc] initWithDictionary:obj];
        dispatch_semaphore_t setUpCompleted = dispatch_semaphore_create(0);
        [[Place alloc] setImageViewOfPlace:place withPriority:YES withDispatch:setUpCompleted withCompletion:^(UIImage *image, NSError * _Nonnull error) {
            if(image) {
                place.imageView.image = image;
            }
            else {
                NSLog(@"did not work snif");
            }
        }];
        dispatch_semaphore_wait(setUpCompleted, DISPATCH_TIME_FOREVER);
        //dispatch_release(setUpCompleted);
        return place;
    }];
    self.dictionaryOfArrayOfPlaces[type] = newArray;
}


@end
