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
    
    NSString *apiRequestString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=%@&inputtype=textquery&fields=photos,formatted_address,name,rating,opening_hours,geometry&key=%@", locationName, consumerKey];
    
    [self GET:apiRequestString parameters:dictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
       // Manually cache the tweets. If the request fails, restore from cache if possible.
       NSMutableArray *tweets  = [Tweet tweetsWithArray:tweetDictionaries];
       completion(tweets, nil);
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       // There was a problem
       completion(nil, error);
   }];
}
-(void)getLocation:(NSString *)locationName {
    

}




//Franklin

-(void)getLocationPhotos:((void(^)(NSArray *photos, NSError *error))completion
{
}
                          
//Angela
                          
-

@end
