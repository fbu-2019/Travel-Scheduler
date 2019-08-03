//
//  Place.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Place.h"
#import "APIManager.h"
#import "Date.h"
#import "TravelSchedulerHelper.h"
#import "NSArray+Map.h"
#import <GIFProgressHUD.h>
@import GooglePlaces;

typedef void (^getHubDictionaryCompletion)(NSDictionary *, NSError *);
typedef void (^getNearbyPlacesOfTypeDictionariesCompletion)(NSArray *, NSString *type, NSError *);

@implementation Place

#pragma mark - Initialization methods
    
- (void)getHubWithName: (NSString *)name withArrayOfTypes:(NSArray *)arrayOfTypes withCompletion:(void (^)(Place *place, NSError *error))completion
    {
    Place *newPlace = [[Place alloc] init];
        
    getNearbyPlacesOfTypeDictionariesCompletion getNearbyPlacesOfTypeDictionariesCompletionBlock = ^(NSArray *arrayOfPlacesDictionary, NSString *type, NSError *getPlacesError) {
        if(arrayOfPlacesDictionary) {
            NSArray* newArray = [arrayOfPlacesDictionary mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
                Place *place = [[Place alloc] initWithDictionary:obj];
                if([newPlace.dictionaryOfArrayOfPlaces objectForKey:type] == nil) {
                    newPlace.dictionaryOfArrayOfPlaces[type] = [[NSMutableArray alloc] init];
                }
                [newPlace.dictionaryOfArrayOfPlaces[type] addObject:place];
                return place;
            }];
        } else {
            NSLog(@"ERROR IN GETTING DICTIONARIES OF NEARBY PLACES");
        }
        if((int)[newPlace.dictionaryOfArrayOfPlaces count] == arrayOfTypes.count) {
            completion(newPlace, nil);
        }
    };
    
    getHubDictionaryCompletion getHubDictionaryCompletionBlock = ^(NSDictionary *placeInfoDictionary, NSError *error)
    {
        if(placeInfoDictionary) {
            [newPlace initWithDictionary:placeInfoDictionary];
            for(NSString *type in arrayOfTypes) {
                [[APIManager shared]getPlacesCloseToLatitude:placeInfoDictionary[@"geometry"][@"location"][@"lat"] andLongitude:placeInfoDictionary[@"geometry"][@"location"][@"lng"] ofType:type withCompletion:getNearbyPlacesOfTypeDictionariesCompletionBlock];
            }
        } else {
            //TO DO: Manage this error somehow and erase the NSLOG
            NSLog(@"ERROR IN GETTING THE DICTIONARY OF THE HUB (error in initHubWithName of place object)");
        }
    };
    
    [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:getHubDictionaryCompletionBlock];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self) {
        [self createAllProperties];
        self.name = dictionary[@"name"];
        self.address = dictionary[@"formatted_address"];
        if(self.address == nil) {
            self.address = dictionary[@"vicinity"];
        }
        self.coordinates = dictionary[@"geometry"][@"location"];
        self.iconUrl = dictionary[@"icon"];
        self.placeId = dictionary[@"place_id"];
        self.rating = dictionary[@"rating"];
        self.photos = dictionary[@"photos"];
        self.types = dictionary[@"types"];
        [self setPlaceSpecificType];
        self.unformattedTimes = dictionary[@"opening_hours"];
        self.locked = NO;
        self.isHome = NO;
        self.scheduledTimeBlock = -1;
        self.timeToSpend = -1;
        self.arrivalTime = -1;
        self.departureTime = -1;
        self.travelTimeToPlace = @(-1);
        self.travelTimeFromPlace = @(-1);
        self.hasAlreadyGone = NO;
        self.selected = NO;
        self.cachedDistances = [[NSMutableDictionary alloc] init];
        self.cachedCommutes = [[NSMutableDictionary alloc] init];
        [self makeScheduleDictionaries];
    }
    return self;
}

#pragma mark - General Helper methods for initialization

- (bool)setArrivalDeparture:(TimeBlock)timeBlock
{
    float travelTime = ([self.travelTimeToPlace floatValue] / 3600) + 10.0/60.0;
    float arrivalTime;
    float departureTime;
    float indirectPrevTime = (self.indirectPrev) ? (self.indirectPrev.departureTime + travelTime) : -1;
    switch(timeBlock) {
        case TimeBlockBreakfast:
            arrivalTime = 9 + travelTime;
            departureTime = getMax(arrivalTime + 0.5, 10);
            break;
        case TimeBlockMorning:
            arrivalTime = (self.prevPlace) ? (self.prevPlace.departureTime + travelTime) : getMax(indirectPrevTime, 10);
            if (arrivalTime + 0.5 < 13.5) {
                departureTime = getMax(arrivalTime + 0.5, 12.5);
            } else {
                return false;
            }
            break;
        case TimeBlockLunch:
            arrivalTime = (self.prevPlace) ? (self.prevPlace.departureTime + travelTime) : getMax(indirectPrevTime, 12.5);
            if (arrivalTime > 14) {
                return false;
            }
            departureTime = arrivalTime + 1;
            break;
        case TimeBlockAfternoon:
            arrivalTime = (self.prevPlace) ? (self.prevPlace.departureTime + travelTime) : getMax(indirectPrevTime, 14);
            departureTime = getMax(arrivalTime + 2, 17);
            break;
        case TimeBlockDinner:
            arrivalTime = (self.prevPlace) ? (self.prevPlace.departureTime + travelTime) : getMax(indirectPrevTime, 17.5);
            departureTime = arrivalTime + 1.5;
            break;
        case TimeBlockEvening:
            arrivalTime = (self.prevPlace) ? (self.prevPlace.departureTime + travelTime) : getMax(indirectPrevTime, 19);
            departureTime = 20.5 - ([self.travelTimeFromPlace floatValue] / 3600);
            break;
    }
    if (arrivalTime > departureTime) {
        return false;
    }
    self.arrivalTime = arrivalTime;
    self.departureTime = departureTime;
    return true;
}

- (void)createAllProperties
{
    self.arrayOfNearbyPlaces = [[NSMutableArray alloc]init];
    self.dictionaryOfArrayOfPlaces = [[NSMutableDictionary alloc] init];
    self.coordinates = [[NSDictionary alloc] init];
    self.types = [[NSArray alloc] init];
    self.unformattedTimes = [[NSDictionary alloc] init];
    self.openingTimesDictionary = [[NSMutableDictionary alloc] init];
    self.prioritiesDictionary = [[NSMutableDictionary alloc] init];
}

- (void)setPlaceSpecificType
{
    if([self.types containsObject:@"stadium"] || [self.types containsObject:@"museum"] || [self.types containsObject:@"shopping_mall"] || [self.types containsObject:@"park"]) {
        self.specificType = @"attraction";
    } else if([self.types containsObject:@"lodging"]) {
        self.specificType = @"hotel";
    } else {
        self.specificType = @"restaurant";
    }
}

#pragma mark - methods to make the dictionary of opening times and priorities

- (void)makeScheduleDictionaries
{
    for(int dayIndexInt = 0; dayIndexInt <= 6; ++dayIndexInt) {
        NSNumber *dayIndexNSNumber = [[NSNumber alloc] initWithInt:dayIndexInt];
        [self formatTimeForDay:dayIndexNSNumber];
        [self formatPriorityForDay:dayIndexNSNumber];
    }
}

- (void)formatPriorityForDay:(NSNumber *)day
{
    NSMutableArray *arrayOfPeriodsForDay = self.openingTimesDictionary[day][@"periods"];
    int numberOfPeriodsForDayInt = (int)[arrayOfPeriodsForDay count];
    NSNumber *numberOfPeriodsForDayNSNumber = [NSNumber numberWithInt:numberOfPeriodsForDayInt];
    if (self.priority < 0 && numberOfPeriodsForDayInt > 0) {
        self.priority = numberOfPeriodsForDayInt;
    }
    [self.prioritiesDictionary setObject:numberOfPeriodsForDayNSNumber forKey:day];
}

- (void)formatTimeForDay:(NSNumber *)day
{
    int dayInt = [day intValue];
    NSDictionary *dayDictionary = self.unformattedTimes[@"periods"][dayInt];
    float openingTimeFloat;
    float closingTimeFloat;
    if (dayDictionary == nil) {
        openingTimeFloat = 0;
        closingTimeFloat = 0;
        self.priority = 3;
    } else if([dayDictionary objectForKey:@"open"] == nil) {
        //Always closed
        openingTimeFloat = -1;
        closingTimeFloat = -1;
        self.priority = -1;
    } else if([dayDictionary objectForKey:@"close"] == nil) {
        //Always open
        openingTimeFloat = 0;
        closingTimeFloat = 0;
        self.priority = 3;
    } else {
        NSString *closingTimeString = dayDictionary[@"close"][@"time"];
        closingTimeFloat = [Date getFormattedTimeFromString:closingTimeString];
        NSString *openingTimeString = dayDictionary[@"open"][@"time"];
        openingTimeFloat = [Date getFormattedTimeFromString:openingTimeString];
    }
    NSNumber *openingTimeNSNumber = [[NSNumber alloc] initWithFloat:openingTimeFloat];
    NSNumber *closingTimeNSNumber = [[NSNumber alloc] initWithFloat:closingTimeFloat];
    NSMutableDictionary *newDictionaryForDay = [[NSMutableDictionary alloc] init];
    newDictionaryForDay[@"opening"] = openingTimeNSNumber;
    newDictionaryForDay[@"closing"] = closingTimeNSNumber;
    if([self.specificType isEqualToString:@"restaurant"]) {
        newDictionaryForDay[@"periods"] = [self getRestaurantsPeriodsArrayFromOpeningTime:openingTimeFloat toClosingTime:closingTimeFloat];
    } else {
        newDictionaryForDay[@"periods"] = [self getAttractionsPeriodsArrayFromOpeningTime:openingTimeFloat toClosingTime:closingTimeFloat];
    }
    self.openingTimesDictionary[day] = newDictionaryForDay;
}

- (NSMutableArray *)getAttractionsPeriodsArrayFromOpeningTime:(float)openingTime toClosingTime:(float)closingTime
{
    NSMutableArray *arrayOfPeriods = [[NSMutableArray alloc] init];
    
    if (openingTime < 0) {
        //Closed all day
        return arrayOfPeriods;
    }
    if (fabsf(openingTime - 0) < 0.1 && fabsf(closingTime - 0) < 0.1){
        //Open all day
        [arrayOfPeriods addObject:@(TimeBlockMorning)];
        [arrayOfPeriods addObject:@(TimeBlockAfternoon)];
        [arrayOfPeriods addObject:@(TimeBlockEvening)];
        return arrayOfPeriods;
    }
    if (openingTime < 11 && closingTime >= 11) {
        [arrayOfPeriods addObject:@(TimeBlockMorning)];
    }
    if (closingTime >= 13) {
        [arrayOfPeriods addObject:@(TimeBlockAfternoon)];
    }
    if(closingTime >= 17) {
        [arrayOfPeriods addObject:@(TimeBlockEvening)];
    }
    return arrayOfPeriods;
}

- (NSMutableArray *)getRestaurantsPeriodsArrayFromOpeningTime:(float)openingTime toClosingTime:(float)closingTime
{
    NSMutableArray *arrayOfPeriods = [[NSMutableArray alloc] init];
    
    if (openingTime < 0) {
        //Closed all day
        return arrayOfPeriods;
    }
    if (openingTime == 0 && closingTime == 0){
        //Open all day
        [arrayOfPeriods addObject:@(TimeBlockBreakfast)];
        [arrayOfPeriods addObject:@(TimeBlockLunch)];
        [arrayOfPeriods addObject:@(TimeBlockDinner)];
        return arrayOfPeriods;
    }
    if (openingTime < 11 && closingTime >= 11) {
        [arrayOfPeriods addObject:@(TimeBlockBreakfast)];
    }
    if (closingTime >= 16) {
        [arrayOfPeriods addObject:@(TimeBlockLunch)];
    }
    if(closingTime >= 20) {
        [arrayOfPeriods addObject:@(TimeBlockDinner)];
    }
    return arrayOfPeriods;
}

#pragma mark - Methods to get new places on demand (for infinite scrolling and search bar)

- (void)updateArrayOfNearbyPlacesWithType:(NSString *)type withCompletion:(void (^)(bool success, NSError *error))completion
{
    [[APIManager shared]getNextSetOfPlacesCloseToLatitude:self.coordinates[@"lat"] andLongitude:self.coordinates[@"lng"] ofType:type withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
        if(arrayOfPlacesDictionary) {
            NSArray* newArray = [arrayOfPlacesDictionary mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
                Place *place = [[Place alloc] initWithDictionary:obj];
                if([self.dictionaryOfArrayOfPlaces objectForKey:type] == nil) {
                    self.dictionaryOfArrayOfPlaces[type] = [[NSMutableArray alloc] init];
                }
                [self.dictionaryOfArrayOfPlaces[type] addObject:place];
                return place;
            }];
            completion(YES, nil);
        } else {
            NSLog(@"did not work snif");
            completion(nil, getPlacesError);
        }
    }];
}

- (void)makeNewArrayOfPlacesOfType:(NSString *)type basedOnKeyword:(NSString *)keyword withCompletion:(void (^)(NSArray *arrayOfNewPlaces, NSError *error))completion
{
    dispatch_group_t makeNewSetOfPlacesDispatchGroup = dispatch_group_create();
    dispatch_group_enter(makeNewSetOfPlacesDispatchGroup);
    [[APIManager shared]getOnDemandPlacesCloseToLatitude:self.coordinates[@"lat"] andLongitude:self.coordinates[@"lng"] ofType:type basedOnKeyword:keyword withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
        if(arrayOfPlacesDictionary) {
            NSArray* newArray = [arrayOfPlacesDictionary mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
                Place *place = [[Place alloc] initWithDictionary:obj];
                NSString *curPhotoReference = place.photos[0][@"photo_reference"];
                [[APIManager shared]getPhotoFromReference:curPhotoReference withCompletion:^(NSURL *photoURL, NSError *error) {
                    dispatch_group_enter(makeNewSetOfPlacesDispatchGroup);
                    if(photoURL) {
                        place.photoURL = photoURL;
                    } else {
                        NSLog(@"something went wrong");
                    }
                    dispatch_group_leave(makeNewSetOfPlacesDispatchGroup);
                    if(arrayOfPlacesDictionary.count - 1 == idx) {
                        dispatch_group_leave(makeNewSetOfPlacesDispatchGroup);
                    }
                }];
                return place;
            }];
            dispatch_group_wait(makeNewSetOfPlacesDispatchGroup,DISPATCH_TIME_FOREVER);
            completion(newArray, nil);
        } else {
            NSLog(@"did not work snif");
            completion(nil, getPlacesError);
        }
    }];
}

@end
