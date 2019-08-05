//
//  Place.h
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GIFProgressHUD.h>
#import "TravelSchedulerHelper.h"
#import "Date.h"
#import "Commute.h"
#import "PlaceView.h"

@class Commute;
@class PlaceView;
@class CalendarEvent;

NS_ASSUME_NONNULL_BEGIN

@interface Place : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSDictionary *coordinates;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic) bool selected;
@property (nonatomic, strong) NSString *specificType;
@property (nonatomic, strong) NSDictionary *unformattedTimes;
@property (nonatomic, strong) NSMutableDictionary *openingTimesDictionary;
@property (nonatomic, strong) NSMutableDictionary *prioritiesDictionary;
@property (nonatomic, strong) Place *prevPlace;
@property (nonatomic) bool locked;
@property (nonatomic) bool isHome;
@property (nonatomic) TimeBlock scheduledTimeBlock;
@property (nonatomic) float arrivalTime;
@property (nonatomic) float departureTime;
@property (nonatomic) float timeToSpend;
@property (nonatomic, strong) NSNumber *travelTimeToPlace;
@property (nonatomic, strong) NSNumber *travelTimeFromPlace;
@property (nonatomic) bool hasAlreadyGone;
@property (nonatomic, strong) NSMutableDictionary *cachedDistances;
@property (nonatomic) bool isHub;
@property (strong, nonatomic) NSMutableArray *arrayOfNearbyPlaces;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfArrayOfPlaces;
@property(nonatomic) int priority;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDate *tempDate;
@property (nonatomic) TimeBlock tempBlock;
@property (strong, nonatomic) NSMutableDictionary *cachedCommutes;
@property (strong, nonatomic) Commute *commuteTo;
@property (strong, nonatomic) Commute *commuteFrom;
@property (strong, nonatomic) PlaceView *placeView;
@property (strong, nonatomic) Place *indirectPrev;
@property (strong, nonatomic) CalendarEvent *calendarEvent;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (bool)setArrivalDeparture:(TimeBlock)timeBlock;
- (void)updateArrayOfNearbyPlacesWithType:(NSString *)type withCompletion:(void (^)(bool success, NSError *error))completion;
- (void)makeNewArrayOfPlacesOfType:(NSString *)type basedOnKeyword:(NSString *)keyword withCompletion:(void (^)(NSArray *arrayOfNewPlaces, NSError *error))completion;
- (void)getHubWithName:(NSString *)name withArrayOfTypes:(NSArray *)arrayOfTypes withCompletion:(void (^)(Place *place, NSError *error))completion;
    
@end

NS_ASSUME_NONNULL_END
