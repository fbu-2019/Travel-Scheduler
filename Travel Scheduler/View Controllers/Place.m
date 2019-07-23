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
#import "NSArray+Map.h"
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
    //dispatch_async(dispatch_get_main_queue(), ^{
        [self getPlacesClient];
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
            self.hasAlreadyGone = NO;
            self.isSelected = NO;
            [self makeScheduleDictionaries];
        }
   // });
    return self;
}

- (instancetype)initWithName:(NSString *)name beginHub:(bool)isHub{
    self = [super init];
    dispatch_semaphore_t didCreatePlace = dispatch_semaphore_create(0);
    [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            [self initWithDictionary:placeInfoDictionary];
            if(isHub) {
                self.isHub = YES;
                [self createDictionaryOfArrays];
            }
            dispatch_semaphore_signal(didCreatePlace);
        }
        else {
            NSLog(@"could not get dictionary");
            dispatch_semaphore_signal(didCreatePlace);
        }
    }];
   dispatch_semaphore_wait(didCreatePlace, DISPATCH_TIME_FOREVER);
   return self;
}

#pragma mark - General Helper methods for initialization

- (void)createAllProperties {
    self.arrayOfNearbyPlaces = [[NSMutableArray alloc]init];
    self.dictionaryOfArrayOfPlaces = [[NSMutableDictionary alloc] init];
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
- (void)setImageViewOfPlace:(Place *)myPlace withPriority:(bool)priority withDispatch:(dispatch_semaphore_t)setUpCompleted {
        GMSPlaceField fields = (GMSPlaceFieldPhotos);
        
        [self->_placesClient fetchPlaceFromPlaceID:myPlace.placeId placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"An error occurred %@", [error localizedDescription]);
                if(priority) {
                    dispatch_semaphore_signal(setUpCompleted);
                }
                return;
            }
            if (place != nil) {
                GMSPlacePhotoMetadata *photoMetadata = [place photos][0];
                [self->_placesClient loadPlacePhoto:photoMetadata callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
                    if (error != nil) {
                        NSLog(@"Error loading photo metadata: %@", [error localizedDescription]);
                        if(priority) {
                            dispatch_semaphore_signal(setUpCompleted);
                        }
                        return;
                    } else {
                        myPlace.imageView.image = photo;
                        if(priority) {
                            dispatch_semaphore_signal(setUpCompleted);
                        }
                    }
                }];
            }
        }];
}

#pragma mark - Hub methods
-(void)createDictionaryOfArrays{
    NSArray *arrayOfTypes = [[NSArray alloc]initWithObjects:@"lodging", @"restaurant", @"museum", @"park", nil];
    
    for(NSString *type in arrayOfTypes){
        dispatch_semaphore_t createdTheArray = dispatch_semaphore_create(0);
        [self makeArrayOfNearbyPlacesWithType:type withCompletion:^(bool success, NSError * _Nonnull error) {
            if(success) {
                NSLog(@"so far so good");
                dispatch_semaphore_signal(createdTheArray);
            }
            else {
                NSLog(@"error getting arrays");
                dispatch_semaphore_signal(createdTheArray);
            }
        }];
        dispatch_semaphore_wait(createdTheArray, DISPATCH_TIME_FOREVER);
    }
}

#pragma mark - Methods to get the array of nearby places
- (void)makeArrayOfNearbyPlacesWithType:(NSString *)type withCompletion:(void (^)(bool success, NSError *error))completion {
    [[APIManager shared]getPlacesCloseToLatitude:self.coordinates[@"lat"] andLongitude:self.coordinates[@"lng"] ofType:type withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
        if(arrayOfPlacesDictionary) {
            NSLog(@"Array of places dictionary worked");
            [self placesWithArray:arrayOfPlacesDictionary withType:type];
            completion(YES, nil);
        }
        else {
            NSLog(@"did not work snif");
            completion(nil, getPlacesError);
        }
    }];
}

- (void)placesWithArray:(NSArray *)arrayOfPlaceDictionaries withType:(NSString *)type{
    //dispatch_async(dispatch_get_main_queue(), ^{
    NSArray* newArray = [arrayOfPlaceDictionaries mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
        Place *place = [[Place alloc] initWithDictionary:obj];
//        dispatch_semaphore_t setUpCompleted = dispatch_semaphore_create(0);
//        [[Place alloc] setImageViewOfPlace:place withPriority:YES withDispatch:setUpCompleted];
//        dispatch_semaphore_wait(setUpCompleted, DISPATCH_TIME_FOREVER);
        //dispatch_release(setUpCompleted);
        return place;
    }];
    self.dictionaryOfArrayOfPlaces[type] = newArray;
    //});
}



#pragma mark - Google API Helper methods
-(void)getPlacesClient {
    dispatch_async(dispatch_get_main_queue(), ^{
    if(self->_gotPlacesClient != YES){
        self->_placesClient = [GMSPlacesClient sharedClient];
        self->_gotPlacesClient = YES;
    }
        });
}

@end
