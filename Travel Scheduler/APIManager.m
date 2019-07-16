//
//  APIManager.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "APIManager.h"

static NSString * const baseURLString = @"https://maps.googleapis.com/maps/api/";
static NSString * const consumerKey = @"AIzaSyC8Iz7AYw5g6mx1oq7bsVjbvLEPPKtrxik";// Enter your consumer key here

@implementation APIManager

#pragma mark - APIManager Creation

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSString *key = consumerKey;
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"]) {
        key = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"];
    }
    self = [super initWithBaseURL:baseURL consumerKey:key consumerSecret:nil];
    return self;
}

//Gi


- (void)getLocationAdressWithName:(NSString *)locationName withCompletion:(void(^)(NSDictionary *location, NSError *error))completion{
    
    NSString *apiRequestString = @"place/findplacefromtext/jason?parameters";
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:consumerKey,@"key", locationName, @"input", @"textquery", @"inputtype", nil];
    
    [self GET:apiRequestString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable locationDictionary) {
       
        NSDictionary *location  = locationDictionary;
       completion(location, nil);
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       // There was a problem
       NSLog(@"There was a problem nooo");
       completion(nil, error);
   }];
}

-(void)getLocation:(NSString *)locationName {
    

}




//Franklin
/*
- (void)getLocationPhotos:(NSString *)locationName withCompletion:(void(^)(NSString *photoURL, NSError *error))completion{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:<#(id  _Nonnull const __unsafe_unretained * _Nullable)#> forKeys:<#(id<NSCopying>  _Nonnull const __unsafe_unretained * _Nullable)#> count:<#(NSUInteger)#>];
    [self GET:@"maps.googleapis.com/maps/api/place/photo?parameters
     "
   parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable photosDictionaries) {
       completion(photos, nil);
   } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
       completion(nil, error);
   }];
}
*/
//Angela
                          
- (void)getDirectionsWithStartPlace: (NSString *) start WithEndPlace: (NSString *) end WithCompletion:(void(^)(NSNumber *timeDistance, NSError *error))completion {
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:@"origin", start, @"destination", end, @"key", consumerKey, nil];
    [self GET:@"directions/json?" parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable mapsDictionary) {
        NSDictionary *routeInfo = mapsDictionary[@"routes"][0];
        NSNumber *timeDistance = routeInfo[@"duration"][@"value"];
        completion(timeDistance, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];

}

@end
