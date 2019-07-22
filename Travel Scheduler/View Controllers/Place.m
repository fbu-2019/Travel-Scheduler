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
@import GooglePlaces;

static int breakfast = 0;
static int morning = 1;
static int lunch = 2;
static int afternoon = 3;
static int dinner = 4;
static int evening = 5;

@implementation Place {
    GMSPlacesClient *_placesClient;
    bool _gotPlacesClient;
}

#pragma mark - Initialization methods
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getPlacesClient];
        if(self) {
            [self createAllProperties];
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
            [self makeScheduleDictionaries];
        }
    });
    return self;
}

- (instancetype)initWithName:(NSString *)name withCompletion:(void (^)(bool sucess, NSError *error))completion {
    __block Place *place;
    [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            place = [place initWithDictionary:placeInfoDictionary];
            completion(YES, nil);
        }
        else {
            NSLog(@"could not get dictionary");
            completion(NO, error);
        }
    }];
    return place;
}

#pragma mark - General Helper methods for initialization

- (void)createAllProperties {
    self.coordinates = [[NSDictionary alloc] init];
    self.types = [[NSArray alloc] init];
    self.unformattedTimes = [[NSDictionary alloc] init];
    self.openingTimesDictionary = [[NSMutableDictionary alloc] init];
    self.prioritiesDictionary = [[NSMutableDictionary alloc] init];
    self.imageView = [[UIImageView alloc] init];
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


#pragma mark - methods to make the dictionary of opening times and priorities
- (void)makeScheduleDictionaries{
    for(int dayIndexInt = 0; dayIndexInt <= 6; ++dayIndexInt){
        NSNumber *dayIndexNSNumber = [[NSNumber alloc] initWithInt:dayIndexInt];
        [self formatTimeForDay:dayIndexNSNumber];
        [self formatPriorityForDay:dayIndexNSNumber];
    }
}

-(void)formatPriorityForDay:(NSNumber *)day {
    NSMutableArray *arrayOfPeriodsForDay = self.openingTimesDictionary[day][@"periods"];
    int numberOfPeriodsForDayInt = (int)[arrayOfPeriodsForDay count];
    NSNumber *numberOfPeriodsForDayNSNumber = [NSNumber numberWithInt:numberOfPeriodsForDayInt];
    [self.prioritiesDictionary setObject:numberOfPeriodsForDayNSNumber forKey:day];
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
    }
    else {
        newDictionaryForDay[@"periods"] = [self getAttractionsPeriodsArrayFromOpeningTime:openingTimeFloat toClosingTime:closingTimeFloat];
    }
    self.openingTimesDictionary[day] = newDictionaryForDay;
    
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

#pragma mark - Image methods
- (void)setImageViewOfPlace:(Place *)myPlace withPriority:(bool)priority withDispatch:(dispatch_semaphore_t)setUpCompleted withCompletion:(void (^)(UIImage *image, NSError *error))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        GMSPlaceField fields = (GMSPlaceFieldPhotos);
        
        if(priority) {
            dispatch_semaphore_signal(setUpCompleted);
        }
        
        [self->_placesClient fetchPlaceFromPlaceID:myPlace.placeId placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"An error occurred %@", [error localizedDescription]);
                completion(nil, error);
                return;
            }
            if (place != nil) {
                GMSPlacePhotoMetadata *photoMetadata = [place photos][0];
                [self->_placesClient loadPlacePhoto:photoMetadata callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
                    if (error != nil) {
                        NSLog(@"Error loading photo metadata: %@", [error localizedDescription]);
                        completion(nil, error);
                        return;
                    } else {
                        //myPlace.imageView.image = photo;
                        completion((UIImage *)photo, nil);
                    }
                }];
            }
        }];
    });
}

#pragma mark - Google API Helper methods
-(void)getPlacesClient {
    if(self->_gotPlacesClient != YES){
        self->_placesClient = [GMSPlacesClient sharedClient];
        self->_gotPlacesClient = YES;
    }
}

@end
