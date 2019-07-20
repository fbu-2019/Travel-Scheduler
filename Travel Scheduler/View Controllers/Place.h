//
//  Place.h
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Place : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *placeId;
@property(nonatomic, strong) NSString *rating;
@property(nonatomic, strong) NSDictionary *coordinates;
@property(nonatomic, strong) NSArray *photos;
@property(nonatomic, strong) UIImage *firstPhoto;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic, strong) NSString *website;
@property(nonatomic, strong) NSString *iconUrl;
@property(nonatomic, strong) NSArray *types;
@property(nonatomic, strong) NSString *specificType;
@property(nonatomic, strong)NSDictionary *unformattedTimes;
@property(nonatomic, strong)NSMutableDictionary *openingTimesDictionary;
@property(nonatomic)bool locked;
@property(nonatomic)bool isHome;
@property(nonatomic)int scheduledTimeBlock;
@property(nonatomic)int timeToSpend;
@property(nonatomic)int travelTimeToPlace;
@property(nonatomic)bool isSelected;
@property(nonatomic)bool hasAlreadyGone;



- (void)initWithName:(NSString *)name withCompletion:(void (^)(Place *place, NSError *error))completion;
- (void)getListOfPlacesCloseToPlaceWithName:(NSString *)centerPlaceName withCompletion:(void (^)(NSMutableArray *arrayOfPlaces, NSError *error))completion;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


@end

NS_ASSUME_NONNULL_END
