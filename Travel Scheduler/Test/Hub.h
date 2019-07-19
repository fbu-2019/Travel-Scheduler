//
//  Hub.h
//  Travel Scheduler
//
//  Created by gilemos on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface Hub : Place
@property(strong, nonatomic)NSMutableArray *arrayOfNearbyPlaces;
@property(strong, nonatomic)NSMutableDictionary *dictionaryOfArrayOfPlaces;

- (instancetype)initHubWithPlace:(Place *)place;
- (void)makeArrayOfNearbyPlacesWithType:(NSString *)type withComlpetion:(void (^)(bool success, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
