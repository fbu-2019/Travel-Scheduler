//
//  APIManager.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "APIManager.h"
#import <Foundation/NSObject.h>

static NSString * const baseURLString = @"https://maps.googleapis.com/maps/api/";
static NSString * const consumerKey = @"AIzaSyC8Iz7AYw5g6mx1oq7bsVjbvLEPPKtrxik";// Enter your consumer key here

@interface APIManager()

@end

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


- (void)getBasicInfoOfLocationWithName:(NSString *)locationName withCompletion:(void (^)(NSMutableDictionary *locationInfo, NSError *error))completion {
    
    if (!locationName) {
        return;
    }
    
    locationName = locationName.lowercaseString;
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&inputtype=textquery&fields=photos,icon,place_id,types,formatted_address,name,rating,opening_hours,geometry&key=%@",locationName,consumerKey];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
            if (!error){
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                completion(nil, newError);
                return;
            }
            completion(nil, error);
            return;
        }
        else {
            
            NSArray *results = [jSONresult valueForKey:@"predictions"];
            
            NSMutableDictionary *locationInfo = [[NSMutableDictionary alloc] init];
            
            locationInfo[@"place"] = results[0][@"structured_formatting"];
            locationInfo[@"place_id"] = results[0][@"place_id"];
            locationInfo[@"types"] = results[0][@"types"];
            
            completion(locationInfo, nil);
        }
    }];
    [task resume];
}

-(void)getCompleteInfoOfLocationWithId:(NSString *)locationId withCompletion:(void (^)(NSDictionary *placeInfoDictionary, NSError *error))completion {
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&fields=formatted_address,icon,name,photo,geometry,place_id,type,international_phone_number,opening_hours,website,price_level,rating,review&key=%@",locationId,consumerKey];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
            if (!error){
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                completion(nil, newError);
                return;
            }
            completion(nil, error);
            return;
        }
        else {
            NSDictionary *placeInfoDictionary = [jSONresult valueForKey:@"results"];
            completion(placeInfoDictionary, nil);
        }
    }];
    [task resume];
}

-(void)getPlacesCloseToLatitude:(NSString *)latitude andLongitude:(NSString *)longitude withCompletion:(void (^)(NSArray *arrayOfPlaces, NSError *error))completion {
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=50000&type=point_of_interest&key=%@",latitude,longitude,consumerKey];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
            if (!error){
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                completion(nil, newError);
                return;
            }
            completion(nil, error);
            return;
        }
        else {
            NSArray *results = [jSONresult valueForKey:@"results"];
            completion(results, nil);
        }
    }];
    [task resume];
}
@end
