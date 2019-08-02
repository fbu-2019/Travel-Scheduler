//
//  APIManager.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "APIManager.h"
#import <Foundation/NSObject.h>

@import GooglePlaces;

static NSString * const baseURLString = @"https://maps.googleapis.com/maps/api/";
static NSString * const consumerKey = @"AIzaSyBgacZ-FJamhQHLWZVQvyIiPnKltOH61H8";
static NSMutableDictionary *nearbySearchPlaceTokenDictionary;

@interface APIManager()

@end


@implementation APIManager

#pragma mark - APIManager initialization methods

+ (instancetype)shared
{
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSString *key = consumerKey;
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"]) {
        key = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"];
    }
    self = [super initWithBaseURL:baseURL consumerKey:key consumerSecret:nil];
    return self;
}

#pragma mark - methods to initiate places

- (void)getIdOfLocationWithName:(NSString *)locationName withCompletion:(void (^)(NSString *locationId, NSError *error))completion
{
    if (!locationName) {
        return;
    }
    
    locationName = locationName.lowercaseString;
    NSString *parameters = [NSString stringWithFormat:@"input=%@&inputtype=textquery&fields=photos,icon,place_id,types,formatted_address,name,rating,opening_hours,geometry",locationName];
    NSURLRequest *request = [self makeNSURLRequestWithType:@"place/autocomplete" andParameters:parameters];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]) {
            if (!error) {
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                completion(nil, newError);
                return;
            }
            completion(nil, error);
            return;
        } else {
            NSArray *results = [jSONresult valueForKey:@"predictions"];
            NSString *locationId = results[0][@"place_id"];
            completion(locationId, nil);
        }
    }];
    [task resume];
}

- (void)getCompleteInfoOfLocationWithId:(NSString *)locationId withCompletion:(void (^)(NSDictionary *placeInfoDictionary, NSError *error))completion
{
    NSString *parameters = [NSString stringWithFormat:@"placeid=%@&fields=formatted_address,icon,name,photo,geometry,place_id,type,international_phone_number,opening_hours,website,price_level,rating,review",locationId];
    NSURLRequest *request = [self makeNSURLRequestWithType:@"place/details" andParameters:parameters];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]) {
            if (!error) {
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                completion(nil, newError);
                return;
            }
            completion(nil, error);
            return;
        } else {
            NSDictionary *placeInfoDictionary = [jSONresult valueForKey:@"result"];
            completion(placeInfoDictionary, nil);
        }
    }];
    [task resume];
}

- (void)getCompleteInfoOfLocationWithName:(NSString *)locationName withCompletion:(void (^)(NSDictionary *placeInfoDictionary, NSError *error))completion
{
    [self getIdOfLocationWithName:locationName withCompletion:^(NSString *placeId, NSError *getIdError) {
        if(placeId) {
            [self getCompleteInfoOfLocationWithId:placeId withCompletion:^(NSDictionary *locationInfoDictionary, NSError *completeInfoError) {
                if(locationInfoDictionary) {
                    NSDictionary *placeInfoDictionary = locationInfoDictionary;
                    completion(placeInfoDictionary, nil);
                } else {
                    NSLog(@"complete info did not work");
                    completion(nil, completeInfoError);
                }
            }];
        } else {
            NSLog(@"id did not work");
            completion(nil, getIdError);
        }
    }];
}

#pragma mark - Methods to get nearby places

- (void)getPlacesCloseToLatitude:(NSString *)latitude andLongitude:(NSString *)longitude ofType:(NSString *)type withCompletion:(void (^)(NSArray *arrayOfPlaces, NSError *error))completion
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *parameters = [NSString stringWithFormat:@"location=%@,%@&radius=50000&type=%@",latitude,longitude,type];
        NSURLRequest *request = [self makeNSURLRequestWithType:@"place/nearbysearch" andParameters:parameters];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]) {
                if (!error) {
                    NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                    NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                    completion(nil, newError);
                    return;
                }
                completion(nil, error);
                return;
            } else {
                NSArray *results = [jSONresult valueForKey:@"results"];
                if(nearbySearchPlaceTokenDictionary == nil) {
                    nearbySearchPlaceTokenDictionary = [[NSMutableDictionary alloc] init];
                }
                if([jSONresult objectForKey:@"next_page_token"] != nil) {
                    nearbySearchPlaceTokenDictionary[type] = [jSONresult valueForKey:@"next_page_token"];
                } else {
                    nearbySearchPlaceTokenDictionary[type] = @"END";
                }
                completion(results, nil);
            }
        }];
        [task resume];
    });
}

- (void)getNextSetOfPlacesCloseToLatitude:(NSString *)latitude andLongitude:(NSString *)longitude ofType:(NSString *)type withCompletion:(void (^)(NSArray *arrayOfPlaces, NSError *error))completion
{
    NSString *curPageToken = nearbySearchPlaceTokenDictionary[type];
    if([curPageToken isEqualToString:@"END"]) {
        completion(nil, nil);
    } else {
        NSString *parameters = [NSString stringWithFormat:@"type=%@&pagetoken=%@",type,curPageToken];
        NSURLRequest *request = [self makeNSURLRequestWithType:@"place/nearbysearch" andParameters:parameters];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]) {
                if (!error) {
                    NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                    NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                    completion(nil, newError);
                    return;
                }
                completion(nil, error);
                return;
            } else {
                NSArray *results = [jSONresult valueForKey:@"results"];
                if(nearbySearchPlaceTokenDictionary == nil) {
                    nearbySearchPlaceTokenDictionary = [[NSMutableDictionary alloc] init];
                }
                if([jSONresult objectForKey:@"next_page_token"] != nil) {
                    nearbySearchPlaceTokenDictionary[type] = [jSONresult valueForKey:@"next_page_token"];
                } else {
                    nearbySearchPlaceTokenDictionary[type] = @"END";
                }
                completion(results, nil);
            }
        }];
        [task resume];
    }
}

- (void)getOnDemandPlacesCloseToLatitude:(NSString *)latitude andLongitude:(NSString *)longitude ofType:(NSString *)type basedOnKeyword:(NSString *)keyword withCompletion:(void (^)(NSArray *arrayOfPlaces, NSError *error))completion
{
    NSString *parameters = [NSString stringWithFormat:@"location=%@,%@&radius=50000&keyword=%@&type=%@",latitude,longitude,keyword,type];
    NSURLRequest *request = [self makeNSURLRequestWithType:@"place/nearbysearch" andParameters:parameters];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]) {
            if (!error) {
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                completion(nil, newError);
                return;
            }
            completion(nil, error);
            return;
        } else {
            NSArray *results = [jSONresult valueForKey:@"results"];
            completion(results, nil);
        }
    }];
    [task resume];
}

#pragma mark - Commute methods

- (void)getDistanceFromOrigin:(NSString *)origin toDestination:(NSString *)destination withCompletion:(void (^)(NSDictionary *distanceDurationDictionary, NSError *error))completion
{
    NSString *parameters = [NSString stringWithFormat:@"units=imperial&origins=place_id:%@&destinations=place_id:%@",origin,destination];
    NSURLRequest *request = [self makeNSURLRequestWithType:@"distancematrix" andParameters:parameters];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]) {
            if (!error) {
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                completion(nil, newError);
                return;
            }
            completion(nil, error);
            return;
        } else {
            NSDictionary *rowsDictionary = [jSONresult valueForKey:@"rows"];
            NSDictionary *distanceDurationDictionary = [rowsDictionary valueForKey:@"elements"];
            NSDictionary *durationDictionary = [distanceDurationDictionary valueForKey:@"duration"];
            completion(durationDictionary, nil);
        }
    }];
    [task resume];
}

//Departure time must be an integer in seconds since midnight, January 1, 1970 UTC
- (void)getCommuteDetailsFromOrigin:(NSString *)originId toDestination:(NSString *)destinationId withDepartureTime:(int)departureTime withCompletion:(void (^)(NSArray *commuteDetailsArray, NSError *error))completion
{
    NSString *parameters = [NSString stringWithFormat:@"origin=place_id:%@&destination=place_id:%@&mode=transit&departure_time=%d&transit_mode=train|tram|subway|bus",originId,destinationId,departureTime];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [self makeNSURLRequestWithType:@"directions" andParameters:parameters];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]) {
            if (!error) {
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                completion(nil, newError);
                return;
            }
            completion(nil, error);
            return;
        } else {
            NSArray *routesArray = [jSONresult valueForKey:@"routes"];
            completion(routesArray, nil);
        }
    }];
    [task resume];
}

#pragma mark - methods to get specific place properties

- (void)getPhotoFromReference:(NSString *)reference withCompletion:(void (^)(NSURL *photoURL, NSError *error))completion
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?photoreference=%@&sensor=false&maxheight=1600&maxwidth=1600&key=%@",reference,consumerKey];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSURL *myURL = response.URL;
        completion(myURL, nil);
    }];
    [task resume];
}

- (void)getWebsiteLinkOfPlaceWithId:(NSString *)placeId withCompletion:(void (^)(NSString *placeWebsiteString, NSError *error))completion
{
    NSString *parameters = [NSString stringWithFormat:@"placeid=%@&fields=website",placeId];
    NSURLRequest *request = [self makeNSURLRequestWithType:@"place/details" andParameters:parameters];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]) {
            if (!error) {
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                completion(nil, newError);
                return;
            }
            completion(nil, error);
            return;
        } else {
            NSDictionary *placeInfoDictionary = [jSONresult valueForKey:@"result"];
            NSString *websiteString = placeInfoDictionary[@"website"];
            completion(websiteString, nil);
        }
    }];
    [task resume];
}
#pragma mark - Helper methods

- (NSURLRequest *)makeNSURLRequestWithType:(NSString *)requestTypeString andParameters:(NSString *)parameters
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@/json?%@&key=%@",baseURLString,requestTypeString,parameters,consumerKey];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return request;
}

@end
