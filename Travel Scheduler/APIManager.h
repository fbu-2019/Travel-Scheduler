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

+ (instancetype)shared;
- (void)getLocationAdressWithName:(NSString *)locationName withCompletion:(void(^)(NSDictionary *location, NSError *error))completion;
- (void)getLocationPhotos:(NSString *)locationName withCompletion:(void(^)(NSDictionary *location, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
