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
typedef void (^getNearbyPlacesOfTypeDictionariesCompletion)(NSArray *, NSError *);
typedef void (^getPhotoOfPlaceCompletion)(NSURL *, NSError *);

@implementation Place

- (instancetype) initHubWithName: (NSString *)name
{
    self = [super init];
    NSArray *arrayOfTypes = [[NSArray alloc]initWithObjects:@"lodging", @"restaurant", @"museum", @"park", nil];
    dispatch_group_t serviceGroup = dispatch_group_create();
    dispatch_group_enter(serviceGroup);
    
    //CALL ONE - 1 CALL: GET HUB DICTIONARY FROM NAME
    [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        
        // ** Call one result **
        if(placeInfoDictionary) {
            [self initWithDictionary:placeInfoDictionary];
            for(NSString *type in arrayOfTypes) {
                
                //CALL TWO - ONE CALL FOR EACH TYPE: GET DICTIONARY FOR NEARBY PLACES OF TYPE
                [[APIManager shared]getPlacesCloseToLatitude:placeInfoDictionary[@"geometry"][@"location"][@"lat"] andLongitude:placeInfoDictionary[@"geometry"][@"location"][@"lng"] ofType:type withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
                    
                    // ** call two result **
                    if(arrayOfPlacesDictionary) {
                        __block int countNumberOfPlacesProcessed = 0;
                        NSArray* newArray = [arrayOfPlacesDictionary mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
                            //PSEUDO CALL TREE - 20 * NUMBER OF TYPES - MAKE PLACE OBJECT FROM NEARBY PLACE DICTIONARY
                            // **pseudo call three result **
                            Place *place = [[Place alloc] initWithDictionary:obj];
                            NSString *curPhotoReference = place.photos[0][@"photo_reference"];
                            
                            //CALL FOUR - 20 * NUMBER OF TYPES - GET PHOTO OF NEARBY PLACE
                            [[APIManager shared]getPhotoFromReference:curPhotoReference withCompletion:^(NSURL *photoURL, NSError *error) {
                                dispatch_group_enter(serviceGroup);
                                
                                //** Call four result **
                                if(photoURL) {
                                    place.photoURL = photoURL;
                                    if([self.dictionaryOfArrayOfPlaces objectForKey:type] == nil) {
                                        self.dictionaryOfArrayOfPlaces[type] = [[NSMutableArray alloc] init];
                                    } else {
                                        [self.dictionaryOfArrayOfPlaces[type] addObject:place];
                                    }
                                } else {
                                    //TO DO: Manage this error somehow and erase the NSLOG
                                    NSLog(@"ERROR IN THE GET PHOTO API CALL (error in call four of initHubWithName of place object)");
                                }
                                countNumberOfPlacesProcessed++;
                                dispatch_group_leave(serviceGroup);
                                if([type isEqualToString:arrayOfTypes[arrayOfTypes.count - 1]] && countNumberOfPlacesProcessed == arrayOfPlacesDictionary.count) {
                                    dispatch_group_leave(serviceGroup);
                                }
                            }];
                            return place;
                        }];
                    } else {
                        //TO DO: Manage this error somehow and erase the NSLOG
                        NSLog(@"ERROR IN GETTING DICTIONARIES OF NEARBY PLACES");
                    }
                }];
            }
        } else {
            NSLog(@"could not get dictionary");
        }
    }];
    dispatch_group_wait(serviceGroup,DISPATCH_TIME_FOREVER);
    return self;
}

#pragma mark - Initialization methods

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
        self.cachedTimeDistances = [[NSMutableDictionary alloc] init];
        [self makeScheduleDictionaries];
    }
    return self;
}

#pragma mark - General Helper methods for initialization

- (void)setArrivalDeparture:(TimeBlock)timeBlock
{
    float travelTime = ([self.travelTimeToPlace floatValue] / 3600) + 10.0/60.0;
    switch(timeBlock) {
        case TimeBlockBreakfast:
        self.arrivalTime = 9 + travelTime;
        self.departureTime = getMax(self.arrivalTime + 0.5, 10);
        return;
        case TimeBlockMorning:
        self.arrivalTime = (self.prevPlace) ? (self.prevPlace.departureTime + travelTime) : 10;
        self.departureTime = 12.5;
        return;
        case TimeBlockLunch:
        self.prevPlace.departureTime = 12.5 - travelTime;
        self.arrivalTime = 12.5;
        self.departureTime = 13.5;
        return;
        case TimeBlockAfternoon:
        self.arrivalTime = (self.prevPlace) ? (self.prevPlace.departureTime + travelTime) : 14;
        self.departureTime = getMax(self.arrivalTime + 2, 17);
        return;
        case TimeBlockDinner:
        self.arrivalTime = (self.prevPlace) ? (self.prevPlace.departureTime + travelTime) : 17.5;
        self.departureTime = self.arrivalTime + 1.5;
        return;
        case TimeBlockEvening:
        self.arrivalTime = (self.prevPlace) ? (self.prevPlace.departureTime + travelTime) : 19;
        self.departureTime = 20.5 - ([self.travelTimeFromPlace floatValue] / 3600);
        return;
    }
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
    if([self.types containsObject:@"attraction"] || [self.types containsObject:@"museum"] || [self.types containsObject:@"aquarium"] || [self.types containsObject:@"park"]) {
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

#pragma mark - Methods to update the array of nearby places (for hubs only)

- (void)updateArrayOfNearbyPlacesWithType:(NSString *)type withCompletion:(void (^)(bool success, NSError *error))completion
{
    dispatch_group_t updatePlacesDispatchGroup = dispatch_group_create();
    dispatch_group_enter(updatePlacesDispatchGroup);
    [[APIManager shared]getNextSetOfPlacesCloseToLatitude:self.coordinates[@"lat"] andLongitude:self.coordinates[@"lng"] ofType:type withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
        if(arrayOfPlacesDictionary) {
            __block int countNumberOfPlacesProcessed = 0;
            NSArray* newArray = [arrayOfPlacesDictionary mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
                Place *place = [[Place alloc] initWithDictionary:obj];
                NSString *curPhotoReference = place.photos[0][@"photo_reference"];
                [[APIManager shared]getPhotoFromReference:curPhotoReference withCompletion:^(NSURL *photoURL, NSError *error) {
                    dispatch_group_enter(updatePlacesDispatchGroup);
                    if(photoURL) {
                        place.photoURL = photoURL;
                        if([self.dictionaryOfArrayOfPlaces objectForKey:type] == nil) {
                            self.dictionaryOfArrayOfPlaces[type] = [[NSMutableArray alloc] init];
                        } else {
                            [self.dictionaryOfArrayOfPlaces[type] addObject:place];
                        }
                    } else {
                        NSLog(@"something went wrong");
                    }
                    countNumberOfPlacesProcessed++;
                    dispatch_group_leave(updatePlacesDispatchGroup);
                    if(countNumberOfPlacesProcessed == arrayOfPlacesDictionary.count) {
                        dispatch_group_leave(updatePlacesDispatchGroup);
                    }
                }];
                return place;
            }];
            dispatch_group_wait(updatePlacesDispatchGroup,DISPATCH_TIME_FOREVER);
            completion(YES, nil);
        } else {
            NSLog(@"did not work snif");
            completion(nil, getPlacesError);
        }
    }];
}


//TO DO: MAKE THIS CODE WORK
//- (instancetype) initHubWithName: (NSString *)name
//    {

//        self = [super init];
//        NSArray *arrayOfTypes = [[NSArray alloc]initWithObjects:@"lodging", @"restaurant", @"museum", @"park", nil];
//        dispatch_group_t serviceGroup = dispatch_group_create();
//
//        __block Place *place;
//        __block int countNumberOfPlacesProcessed;
//        __block NSArray *copyOfArrayOfPlacesDictionary;
//        __block NSString *copyOfType;
//
//        getPhotoOfPlaceCompletion getPhotoOfPlaceCompletionBlock = ^(NSURL *photoURL, NSError *error) {
//            dispatch_group_enter(serviceGroup);
//            if(photoURL) {
//                place.photoURL = photoURL;
//                if([self.dictionaryOfArrayOfPlaces objectForKey:copyOfType] == nil) {
//                    self.dictionaryOfArrayOfPlaces[copyOfType] = [[NSMutableArray alloc] init];
//                } else {
//                    [self.dictionaryOfArrayOfPlaces[copyOfType] addObject:place];
//                }
//            } else {
//                //TO DO: Manage this error somehow and erase the NSLOG
//                NSLog(@"ERROR IN THE GET PHOTO API CALL (error in initHubWithName of place object)");
//            }
//            countNumberOfPlacesProcessed++;
//            dispatch_group_leave(serviceGroup);
//            if([copyOfType isEqualToString:arrayOfTypes[arrayOfTypes.count - 1]] && countNumberOfPlacesProcessed == copyOfArrayOfPlacesDictionary.count) {
//                dispatch_group_leave(serviceGroup);
//            }
//        };
//
//        getNearbyPlacesOfTypeDictionariesCompletion getNearbyPlacesOfTypeDictionariesCompletionBlock = ^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
//
//            if(arrayOfPlacesDictionary) {
//                copyOfArrayOfPlacesDictionary = arrayOfPlacesDictionary;
//                countNumberOfPlacesProcessed = 0;
//                NSArray* newArray = [copyOfArrayOfPlacesDictionary mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
//                    place = [[Place alloc] initWithDictionary:obj];
//                    NSString *curPhotoReference = place.photos[0][@"photo_reference"];
//                    [[APIManager shared]getPhotoFromReference:curPhotoReference withCompletion:getPhotoOfPlaceCompletionBlock];
//                    return place;
//                    }];
//                } else {
//                //TO DO: Manage this error somehow and erase the NSLOG
//                NSLog(@"ERROR IN GETTING DICTIONARIES OF NEARBY PLACES (error in initHubWithName of place object)");
//            }
//        };
//
//
//        getHubDictionaryCompletion getHubDictionaryCompletionBlock = ^(NSDictionary *placeInfoDictionary, NSError *error)
//        {
//            if(placeInfoDictionary) {
//                [self initWithDictionary:placeInfoDictionary];
//                for(NSString *type in arrayOfTypes) {
//                    copyOfType = type;
//
//                    [[APIManager shared]getPlacesCloseToLatitude:placeInfoDictionary[@"geometry"][@"location"][@"lat"] andLongitude:placeInfoDictionary[@"geometry"][@"location"][@"lng"] ofType:copyOfType withCompletion:getNearbyPlacesOfTypeDictionariesCompletionBlock];
//
//                 }
//            } else {
//                //TO DO: Manage this error somehow and erase the NSLOG
//                NSLog(@"ERROR IN GETTING THE DICTIONARY OF THE HUB (error in initHubWithName of place object)");
//            }
//        };
//
//
//        dispatch_group_enter(serviceGroup);
//        [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:getHubDictionaryCompletionBlock];
//
//        dispatch_group_wait(serviceGroup,DISPATCH_TIME_FOREVER);
//        return self;
//
//}

@end
