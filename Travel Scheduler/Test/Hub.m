////
////  Hub.m
////  Travel Scheduler
////
////  Created by gilemos on 7/18/19.
////  Copyright © 2019 aliu18. All rights reserved.
////
//
//#import "Hub.h"
//#import "APIManager.h"
//#import "NSArray+Map.h"
//
//@implementation Hub
//
//#pragma mark - Initialization
//- (instancetype)initHubWithDictionary:(NSDictionary *)dictionary {
//    self = [super initWithDictionary:dictionary];
//    [self createAllProperties];
//    return self;
//}
//
////-(instancetype)initHubWithName:(NSString *)name withCompletion:(void (^)(bool sucess, NSError *error))completion {
////    //dispatch_semaphore_t didCreateThehub = dispatch_semaphore_create(0);
////    self = [Hub alloc];
////    self = (Hub *)[super initWithName:name];
////    [self createAllProperties];
////    [self createDictionaryOfArrays];
//////            completion(YES, nil);
//////            dispatch_semaphore_signal(didCreateThehub);
//////        }
//////        else {
//////            completion(NO, error);
//////            dispatch_semaphore_signal(didCreateThehub);
//////        }
//////    }];
////    //dispatch_semaphore_wait(didCreateThehub, DISPATCH_TIME_FOREVER);
////    return self;
////}
//
//#pragma mark - Helper methods for initizalization
//-(void)createAllProperties {
//    self.imageView = [[UIImageView alloc] init];
//    self.dictionaryOfArrayOfPlaces = [[NSMutableDictionary alloc] init];
//}
//
//-(void)createDictionaryOfArrays{
//    NSArray *arrayOfTypes = [[NSArray alloc]initWithObjects:@"lodging", @"restaurant", @"museum", @"park", nil];
//
//    for(NSString *type in arrayOfTypes){
//        dispatch_semaphore_t createdTheArray = dispatch_semaphore_create(0);
//        [self makeArrayOfNearbyPlacesWithType:type withCompletion:^(bool success, NSError * _Nonnull error) {
//            if(success) {
//                NSLog(@"so far so good");
//                 dispatch_semaphore_signal(createdTheArray);
//            }
//            else {
//                NSLog(@"error getting arrays");
//                 dispatch_semaphore_signal(createdTheArray);
//            }
//        }];
//        dispatch_semaphore_wait(createdTheArray, DISPATCH_TIME_FOREVER);
//    }
//}
////#pragma mark - Methods to get the array of nearby places
////- (void)makeArrayOfNearbyPlacesWithType:(NSString *)type withCompletion:(void (^)(bool success, NSError *error))completion {
////    [[APIManager shared]getPlacesCloseToLatitude:self.coordinates[@"lat"] andLongitude:self.coordinates[@"lng"] ofType:type withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
////        if(arrayOfPlacesDictionary) {
////            NSLog(@"Array of places dictionary worked");
////            [self placesWithArray:arrayOfPlacesDictionary withType:type];
////            completion(YES, nil);
////        }
////        else {
////            NSLog(@"did not work snif");
////            completion(nil, getPlacesError);
////        }
////    }];
////}
//
////- (void)placesWithArray:(NSArray *)arrayOfPlaceDictionaries withType:(NSString *)type{
////    NSArray* newArray = [arrayOfPlaceDictionaries mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
////        Place *place = [[Place alloc] initWithDictionary:obj];
////        dispatch_semaphore_t setUpCompleted = dispatch_semaphore_create(0);
////        [[Place alloc] setImageViewOfPlace:place withPriority:YES withDispatch:setUpCompleted withCompletion:^(UIImage *image, NSError * _Nonnull error) {
////            if(image) {
////                place.imageView.image = image;
////            }
////            else {
////                NSLog(@"did not work snif");
////            }
////        }];
////        dispatch_semaphore_wait(setUpCompleted, DISPATCH_TIME_FOREVER);
////        //dispatch_release(setUpCompleted);
////        return place;
////    }];
////    self.dictionaryOfArrayOfPlaces[type] = newArray;
////}
//
//
//@end
