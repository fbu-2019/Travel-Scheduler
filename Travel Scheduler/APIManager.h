//
//  APIManager.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDBOAuth1SessionManager.h"
#import "BDBOAuth1SessionManager+SFAuthenticationSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : BDBOAuth1SessionManager

@property(nonatomic, strong) NSArray *searchResults;
+ (instancetype)shared;
- (void)getIdOfLocationWithName:(NSString *)locationName withCompletion:(void (^)(NSString *locationInfo, NSError *error))completion;
-(void)getCompleteInfoOfLocationWithId:(NSString *)locationId withCompletion:(void (^)(NSDictionary *placeInfoDictionary, NSError *error))completion;
- (void)getDistanceFromOrigin:(NSString *)origin toDestination:(NSString *)destination withCompletion:(void (^)(NSDictionary *distanceDurationDictionary, NSError *error))completion;
-(void)getCompleteInfoOfLocationWithName:(NSString *)locationName withCompletion:(void (^)(NSDictionary *placeInfoDictionary, NSError *error))completion;
-(void)getPlacesCloseToLatitude:(NSString *)latitude andLongitude:(NSString *)longitude withCompletion:(void (^)(NSArray *arrayOfPlaces, NSError *error))completion;
- (void)getPhotoFromReference:(NSString *)reference withCompletion:(void (^)(UIImage *photo, NSError *error))completion;
-(void)getCommuteDetailsFromOrigin:(NSString *)originId toDestination:(NSString *)destinationId withDepartureTime:(int)departureTime withCompletion:(void (^)(NSArray *commuteDetailsArray, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
