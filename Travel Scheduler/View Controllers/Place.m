//
//  Place.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Place.h"
#import "APIManager.h"
#import "TravelSchedulerHelper.h"
@import GooglePlaces;

//static int breakfast = 0;
//static int morning = 1;
//static int lunch = 2;
//static int afternoon = 3;
//static int dinner = 4;
//static int evening = 5;

@implementation Place

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if(self) {
        self.name = dictionary[@"name"];
        self.address = dictionary[@"formatted_address"];
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
        self.hasAlreadyGone = NO;
        self.isSelected = NO;
        self.openingTimesDictionary = [[NSMutableDictionary alloc] init];
        [self makeDictionaryOfOpeningTimes];
        //[self getFirstPhoto];
    }
    return self;
}

//- (void)getFirstPhoto {
//    GMSPlaceField fields = (GMSPlaceFieldPhotos);
//    GMSPlacesClient *_placesClient = [GMSPlacesClient sharedClient];
//    
//    [_placesClient fetchPlaceFromPlaceID:self.placeId placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"An error occurred %@", [error localizedDescription]);
//            return;
//        }
//        if (place != nil) {
//            GMSPlacePhotoMetadata *photoMetadata = [place photos][0];
//            [_placesClient loadPlacePhoto:photoMetadata callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
//                if (error != nil) {
//                    NSLog(@"Error loading photo metadata: %@", [error localizedDescription]);
//                    return;
//                } else {
//                    self.firstPhoto= photo;
//                }
//            }];
//        }
//    }];
//    
//}

- (NSMutableArray *)placesWithArray:(NSArray *)arrayOfPlaceDictionaries {
    NSMutableArray *arrayOfPlaces = [NSMutableArray array];
    for (NSDictionary *dictionary in arrayOfPlaceDictionaries) {
        Place *place = [[Place alloc] initWithDictionary:dictionary];
        [arrayOfPlaces addObject:place];
    }
    return arrayOfPlaces;
}

- (void)initWithName:(NSString *)name withCompletion:(void (^)(Place *place, NSError *error))completion {
    [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            NSLog(@"Success in getting dictionary");
            Place *place = [self initWithDictionary:placeInfoDictionary];
            completion(place, nil);
        }
        else {
            NSLog(@"could not get dictionary");
            completion(nil, error);
        }
    }];
}

- (void)getListOfPlacesCloseToPlaceWithName:(NSString *)centerPlaceName withCompletion:(void (^)(NSMutableArray *arrayOfPlaces, NSError *error))completion{
    [self initWithName:centerPlaceName withCompletion:^(Place *hubPlace, NSError *initWithNameError) {
        if(hubPlace) {
            NSString *hubLatitude = hubPlace.coordinates[@"lat"];
            NSString *hubLongitude = hubPlace.coordinates[@"lng"];
            
            [[APIManager shared]getPlacesCloseToLatitude:hubLatitude andLongitude:hubLongitude withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
                if(arrayOfPlacesDictionary) {
                    NSLog(@"Array of places dictionary worked");
                    NSMutableArray *arrayOfPlaces = [[NSMutableArray alloc] init];
                    arrayOfPlaces = [self placesWithArray:arrayOfPlacesDictionary];
                    completion(arrayOfPlaces, nil);
                }
                else {
                    NSLog(@"did not work snif");
                    completion(nil, getPlacesError);
                }
            }];
        }
        else {
            NSLog(@"could not get hub place");
            completion(nil, initWithNameError);
        }
    }];
}

#pragma mark - Methods to set type
-(void)setPlaceSpecificType {
    if([self.types containsObject:@"restaurant"]) {
        self.specificType = @"restaurant";
    }
    else if([self.types containsObject:@"lodging"]) {
        self.specificType = @"hotel";
    }
    else {
        self.specificType = @"attraction";
    }
}

#pragma mark - methods to make the dictionary of opening times
- (void)makeDictionaryOfOpeningTimes{
    for(int dayIndexInt = 0; dayIndexInt <= 6; ++dayIndexInt){
        NSNumber *dayIndexNSNumber = [[NSNumber alloc] initWithInt:dayIndexInt];
        [self formatTimeForDay:dayIndexNSNumber];
    }
}

-(void)formatTimeForDay:(NSNumber *)day {
    int dayInt = [day intValue];
    NSDictionary *dayDictionary = self.unformattedTimes[@"periods"][dayInt];
    float openingTimeFloat;
    float closingTimeFloat;
    
    if([dayDictionary objectForKey:@"open"] == nil) {
        //Always closed
        openingTimeFloat = -1;
        closingTimeFloat = -1;
    }
    else if([dayDictionary objectForKey:@"close"] == nil) {
        //Always open
        openingTimeFloat = 0;
        closingTimeFloat = 0;
    }
    else {
        NSString *closingTimeString = dayDictionary[@"close"][@"time"];
        closingTimeFloat = [self getTimeFromString:closingTimeString];
        NSString *openingTimeString = dayDictionary[@"open"][@"time"];
        openingTimeFloat = [self getTimeFromString:openingTimeString];
    }
    
    NSNumber *openingTimeNSNumber = [[NSNumber alloc] initWithFloat:openingTimeFloat];
    NSNumber *closingTimeNSNumber = [[NSNumber alloc] initWithFloat:closingTimeFloat];
    
    NSMutableDictionary *newDictionaryForDay = [[NSMutableDictionary alloc] init];
    newDictionaryForDay[@"opening"] = openingTimeNSNumber;
    newDictionaryForDay[@"closing"] = closingTimeNSNumber;
    if([self.specificType isEqualToString:@"restaurant"]) {
        newDictionaryForDay[@"periods"] = [self getRestaurantsPeriodsArrayFromOpeningTime:openingTimeFloat toClosingTime:closingTimeFloat];
    }
    else {
        newDictionaryForDay[@"periods"] = [self getAttractionsPeriodsArrayFromOpeningTime:openingTimeFloat toClosingTime:closingTimeFloat];
    }
    //NSString *dayString = [NSString stringWithFormat:@"%@",day];
    self.openingTimesDictionary[day] = newDictionaryForDay;
    
}

-(float)getTimeFromString:(NSString *)timeString{
    NSString *hourString = [timeString substringToIndex:2];
    int hourInt = [hourString intValue];
    NSString *minuteString = [timeString substringFromIndex:2];
    float minuteIntRaw = [minuteString floatValue];
    float minuteInt = minuteIntRaw/60;
    float formattedTime = hourInt + minuteInt;
    return formattedTime;
}

-(NSMutableArray *)getAttractionsPeriodsArrayFromOpeningTime:(float)openingTime toClosingTime:(float)closingTime {
    NSMutableArray *arrayOfPeriods = [[NSMutableArray alloc] init];
    
    if (openingTime < 0) {
        //Closed all day
        return arrayOfPeriods;
    }
    
    if (fabsf(openingTime - 0) < 0.1 && fabsf(closingTime - 0) < 0.1){
        //Open all day
        [arrayOfPeriods addObject:@(breakfast)];
        [arrayOfPeriods addObject:@(lunch)];
        [arrayOfPeriods addObject:@(dinner)];
        return arrayOfPeriods;
    }
    
    if (openingTime < 11 && closingTime >= 11) {
        [arrayOfPeriods addObject:@(breakfast)];
    }
    if (closingTime >= 13) {
        [arrayOfPeriods addObject:@(lunch)];
    }
    if(closingTime >= 17) {
        [arrayOfPeriods addObject:@(dinner)];
    }
    
    return arrayOfPeriods;
}

-(NSMutableArray *)getRestaurantsPeriodsArrayFromOpeningTime:(float)openingTime toClosingTime:(float)closingTime {
    NSMutableArray *arrayOfPeriods = [[NSMutableArray alloc] init];
    
    if (openingTime < 0) {
        //Closed all day
        return arrayOfPeriods;
    }
    
    if (openingTime == 0 && closingTime == 0){
        //Open all day
        [arrayOfPeriods addObject:@(morning)];
        [arrayOfPeriods addObject:@(afternoon)];
        [arrayOfPeriods addObject:@(evening)];
        return arrayOfPeriods;
    }
    
    if (openingTime < 11 && closingTime >= 11) {
        [arrayOfPeriods addObject:@(morning)];
    }
    if (closingTime >= 16) {
        [arrayOfPeriods addObject:@(afternoon)];
    }
    if(closingTime >= 19) {
        [arrayOfPeriods addObject:@(evening)];
    }
    
    return arrayOfPeriods;
}

@end
