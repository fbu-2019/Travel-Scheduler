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


- (void)getLocationAdressWithName:(NSString *)locationName withCompletion:(void (^)(BOOL isSuccess, NSError *error))completion {
        
        if (!locationName) {
            return;
        }
        
        locationName = locationName.lowercaseString;
        
        self.searchResults = [NSMutableArray array];
        
        if ([self.searchResultsCache objectForKey:searchWord]) {
            NSArray * pastResults = [self.searchResultsCache objectForKey:searchWord];
            self.searchResults = [NSMutableArray arrayWithArray:pastResults];
            completion(YES, nil);
            
        } else {
            
            NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&radius=500&language=en&key=%@",searchWord,apiKey];
            
            NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
                    if (!error){
                        NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                        NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                        completion(NO, newError);
                        return;
                    }
                    completion(NO, error);
                    return;
                } else {
                    
                    NSArray *results = [jSONresult valueForKey:@"predictions"];
                    
                    for (NSDictionary *jsonDictionary in results) {
                        
                    }
                    
                    //[self.searchResultsCache setObject:self.searchResults forKey:searchWord];
                    
                    completion(YES, nil);
                    
                }
            }];
            
            [task resume];
        }
    }
    
  
}

-(void)getLocation:(NSString *)locationName {
    

}




//Franklin

- (void)getLocationPhotos:(NSString *)locationName withCompletion:(void(^)(NSString *photoURL, NSError *error))completion{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:<#(id  _Nonnull const __unsafe_unretained * _Nullable)#> forKeys:<#(id<NSCopying>  _Nonnull const __unsafe_unretained * _Nullable)#> count:<#(NSUInteger)#>]
    [self GET:@"maps.googleapis.com/maps/api/place/photo?parameters
     "
   parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable photosDictionaries) {
       completion(photos, nil);
   } failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
       completion(nil, error);
   }];
}

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
=======
//-(void)getLocationPhotos:((void(^)(NSArray *photos, NSError *error))completion
//{
//}

//Angela
                          
//-
>>>>>>> 58b7d0a1bb0db48cbe170e787c841d9b152482e9

@end
