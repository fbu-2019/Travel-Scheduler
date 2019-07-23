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
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic, strong) NSString *website;
@property(nonatomic, strong) NSString *iconUrl;
@property(nonatomic, strong) NSArray *types;
@property(nonatomic) BOOL selected;
@property(nonatomic, strong) NSString *specificType;
@property(nonatomic, strong)NSDictionary *unformattedTimes;
@property(nonatomic, strong)NSMutableDictionary *openingTimesDictionary;
@property(nonatomic, strong)NSMutableDictionary *prioritiesDictionary;
@property(nonatomic)bool locked;
@property(nonatomic)bool isHome;
@property(nonatomic)int scheduledTimeBlock;
@property(nonatomic)int timeToSpend;
@property(nonatomic)bool isSelected;
@property(nonatomic)bool hasAlreadyGone;
@property(nonatomic)bool isHub;

@property(strong, nonatomic)NSMutableArray *arrayOfNearbyPlaces;
@property(strong, nonatomic)NSMutableDictionary *dictionaryOfArrayOfPlaces;

- (instancetype)initWithName:(NSString *)name beginHub:(bool)isHub;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (void)setImageViewOfPlace:(Place *)myPlace withPriority:(bool)priority withDispatch:(dispatch_semaphore_t)setUpCompleted withCompletion:(void (^)(UIImage *image, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
