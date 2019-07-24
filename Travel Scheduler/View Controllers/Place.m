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
@import GooglePlaces;

@implementation Place {
    GMSPlacesClient *_placesClient;
    bool _gotPlacesClient;
}

#pragma mark - Initialization methods
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
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
        self.arrivalTime = -1;
        self.departureTime = -1;
        self.travelTimeToPlace = @(-1);
        self.travelTimeFromPlace = @(-1);
        self.hasAlreadyGone = NO;
        self.isSelected = NO;
        self.cachedDistances = [[NSMutableDictionary alloc] init];
        [self makeScheduleDictionaries];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name beginHub:(bool)isHub
{
    self = [super init];
    dispatch_semaphore_t didCreatePlace = dispatch_semaphore_create(0);
    [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            [self initWithDictionary:placeInfoDictionary];
            if(isHub) {
                self.isHub = YES;
                [self createDictionaryOfArrays];
            }
        }
        else {
            NSLog(@"could not get dictionary");
        }
        dispatch_semaphore_signal(didCreatePlace);
    }];
    dispatch_semaphore_wait(didCreatePlace, DISPATCH_TIME_FOREVER);
    return self;
}

- (void)setArrivalDeparture:(TimeBlock)timeBlock {
    float travelTime = ([self.travelTimeToPlace floatValue] / 3600) + 10.0/60.0;
    switch(timeBlock) {
        case TimeBlockBreakfast:
            self.arrivalTime = 9 + travelTime;
            self.departureTime = getMax(self.arrivalTime + 0.5, 10);
            return;
        case TimeBlockMorning:
            self.arrivalTime = self.prevPlace.departureTime + travelTime;
            return;
        case TimeBlockLunch:
            self.prevPlace.departureTime = 12.5 - travelTime;
            self.arrivalTime = 12.5;
            self.departureTime = 13.5;
            return;
        case TimeBlockAfternoon:
            self.arrivalTime = self.prevPlace.departureTime + travelTime;
            self.departureTime = getMax(self.arrivalTime + 2, 17.5);
            return;
        case TimeBlockDinner:
            self.arrivalTime = self.prevPlace.departureTime + travelTime;
            self.departureTime = self.arrivalTime + 1.5;
            return;
        case TimeBlockEvening:
            self.arrivalTime = self.prevPlace.departureTime + travelTime;
            self.departureTime = 20 - ([self.travelTimeFromPlace floatValue] / 3600);
            return;
    }
}

#pragma mark - General Helper methods for initialization
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
    if([self.types containsObject:@"restaurant"]) {
        self.specificType = @"restaurant";
    } else if([self.types containsObject:@"lodging"]) {
        self.specificType = @"hotel";
    } else {
        self.specificType = @"attraction";
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
    [self.prioritiesDictionary setObject:numberOfPeriodsForDayNSNumber forKey:day];
}

- (void)formatTimeForDay:(NSNumber *)day
{
    int dayInt = [day intValue];
    NSDictionary *dayDictionary = self.unformattedTimes[@"periods"][dayInt];
    float openingTimeFloat;
    float closingTimeFloat;
    
    if([dayDictionary objectForKey:@"open"] == nil) {
        //Always closed
        openingTimeFloat = -1;
        closingTimeFloat = -1;
    } else if([dayDictionary objectForKey:@"close"] == nil) {
        //Always open
        openingTimeFloat = 0;
        closingTimeFloat = 0;
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
        [arrayOfPeriods addObject:@(TimeBlockBreakfast)];
        [arrayOfPeriods addObject:@(TimeBlockLunch)];
        [arrayOfPeriods addObject:@(TimeBlockDinner)];
        return arrayOfPeriods;
    }
    if (openingTime < 11 && closingTime >= 11) {
        [arrayOfPeriods addObject:@(TimeBlockBreakfast)];
    }
    if (closingTime >= 13) {
        [arrayOfPeriods addObject:@(TimeBlockLunch)];
    }
    if(closingTime >= 17) {
        [arrayOfPeriods addObject:@(TimeBlockDinner)];
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
        [arrayOfPeriods addObject:@(TimeBlockMorning)];
        [arrayOfPeriods addObject:@(TimeBlockAfternoon)];
        [arrayOfPeriods addObject:@(TimeBlockEvening)];
        return arrayOfPeriods;
    }
    if (openingTime < 11 && closingTime >= 11) {
        [arrayOfPeriods addObject:@(TimeBlockMorning)];
    }
    if (closingTime >= 16) {
        [arrayOfPeriods addObject:@(TimeBlockAfternoon)];
    }
    if(closingTime >= 19) {
        [arrayOfPeriods addObject:@(TimeBlockEvening)];
    }
    return arrayOfPeriods;
}

#pragma mark - Methods to get the array of nearby places (for hubs only)
- (void)createDictionaryOfArrays
{
    NSArray *arrayOfTypes = [[NSArray alloc]initWithObjects:@"lodging", @"restaurant", @"museum", @"park", nil];
    for(NSString *type in arrayOfTypes) {
        dispatch_semaphore_t createdTheArray = dispatch_semaphore_create(0);
        [self makeArrayOfNearbyPlacesWithType:type withCompletion:^(bool success, NSError * _Nonnull error) {
            if(success) {
                NSLog(@"so far so good");
            } else {
                NSLog(@"error getting arrays");
            }
            dispatch_semaphore_signal(createdTheArray);
        }];
        dispatch_semaphore_wait(createdTheArray, DISPATCH_TIME_FOREVER);
    }
    NSLog(@"created one");
}

- (void)makeArrayOfNearbyPlacesWithType:(NSString *)type withCompletion:(void (^)(bool success, NSError *error))completion
{
    [[APIManager shared]getPlacesCloseToLatitude:self.coordinates[@"lat"] andLongitude:self.coordinates[@"lng"] ofType:type withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
        if(arrayOfPlacesDictionary) {
            NSLog(@"Array of places dictionary worked");
            [self placesWithArray:arrayOfPlacesDictionary withType:type];
            completion(YES, nil);
        } else {
            NSLog(@"did not work snif");
            completion(nil, getPlacesError);
        }
    }];
}

- (void)placesWithArray:(NSArray *)arrayOfPlaceDictionaries withType:(NSString *)type
{
    NSArray* newArray = [arrayOfPlaceDictionaries mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
        Place *place = [[Place alloc] initWithDictionary:obj];
        dispatch_semaphore_t getPhotoCompleted = dispatch_semaphore_create(0);
        NSString *curPhotoReference = place.photos[0][@"photo_reference"];
        [[APIManager shared]getPhotoFromReference:curPhotoReference withCompletion:^(NSURL *photoURL, NSError *error) {
            if(photoURL) {
                place.photoURL = photoURL;
                NSLog(@"----ONE MORE PLACEEEE -------");
            } else {
                NSLog(@"something went wrong");
            }
            dispatch_semaphore_signal(getPhotoCompleted);
        }];
        dispatch_semaphore_wait(getPhotoCompleted, DISPATCH_TIME_FOREVER);
        return place;
    }];
    self.dictionaryOfArrayOfPlaces[type] = newArray;
}


#pragma mark - Google API Helper methods
- (void)getPlacesClient
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->_gotPlacesClient != YES){
            self->_placesClient = [GMSPlacesClient sharedClient];
            self->_gotPlacesClient = YES;
        }
    });
}

#pragma mark - NSCoding protocol
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.placeId = [decoder decodeObjectForKey:@"placeId"];
        self.rating = [decoder decodeObjectForKey:@"rating"];
        self.address = [decoder decodeObjectForKey:@"address"];
        self.phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
        self.website = [decoder decodeObjectForKey:@"website"];
        self.iconUrl = [decoder decodeObjectForKey:@"iconUrl"];
        self.specificType = [decoder decodeObjectForKey:@"specificType"];
        self.selected = [decoder decodeBoolForKey:@"selected"];
        self.locked = [decoder decodeBoolForKey:@"locked"];
        self.isHome = [decoder decodeBoolForKey:@"isHome"];
        self.isSelected = [decoder decodeBoolForKey:@"isSelected"];
        self.hasAlreadyGone = [decoder decodeBoolForKey:@"hasAlreadyGone"];
        self.isHub = [decoder decodeBoolForKey:@"isHub"];
        self.photos = [decoder decodeObjectForKey:@"photos"];
        if (self.photos == nil) {
            self.photos = [[NSArray alloc] init];
        }
        self.types = [decoder decodeObjectForKey:@"types"];
        if (self.types == nil) {
            self.types = [[NSArray alloc] init];
        }
        self.coordinates = [decoder decodeObjectForKey:@"coordinates"];
        if (self.coordinates == nil) {
            self.coordinates = [[NSDictionary alloc] init];
        }
        self.unformattedTimes = [decoder decodeObjectForKey:@"unformattedTimes"];
        if (self.unformattedTimes == nil) {
            self.unformattedTimes = [[NSDictionary alloc] init];
        }
        self.openingTimesDictionary = [decoder decodeObjectForKey:@"openingTimesDictionary"];
        if (self.openingTimesDictionary == nil) {
            self.openingTimesDictionary = [[NSMutableDictionary alloc] init];
        }
        self.prioritiesDictionary = [decoder decodeObjectForKey:@"prioritiesDictionary"];
        if (self.prioritiesDictionary == nil) {
            self.prioritiesDictionary= [[NSMutableDictionary alloc] init];
        }
        self.dictionaryOfArrayOfPlaces = [decoder decodeObjectForKey:@"dictionaryOfArrayOfPlaces"];
        if (self.dictionaryOfArrayOfPlaces == nil) {
            self.dictionaryOfArrayOfPlaces = [[NSMutableDictionary alloc] init];
        }
        self.arrayOfNearbyPlaces = [decoder decodeObjectForKey:@"arrayOfNearbyPlaces"];
        if (self.arrayOfNearbyPlaces == nil) {
            self.arrayOfNearbyPlaces = [[NSMutableArray alloc] init];
        }
        self.photoURL = [decoder decodeObjectForKey:@"photoURL"];
        self.scheduledTimeBlock = [decoder decodeInt32ForKey:@"scheduledTimeBlock"];
        self.timeToSpend = [decoder decodeInt32ForKey:@"timeToSpend"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.placeId forKey:@"placeId"];
    [encoder encodeObject:self.rating forKey:@"rating"];
    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.phoneNumber forKey:@"phoneNumber"];
    [encoder encodeObject:self.website forKey:@"website"];
    [encoder encodeObject:self.iconUrl forKey:@"iconUrl"];
    

//    @property(nonatomic, strong) NSDictionary *coordinates;
//    @property(nonatomic, strong) NSArray *photos;


//    @property(nonatomic, strong) NSString *iconUrl;
//    @property(nonatomic, strong)NSURL *photoURL;
//    @property(nonatomic, strong) NSArray *types;
//    @property(nonatomic) BOOL selected;
//    @property(nonatomic, strong) NSString *specificType;
//    @property(nonatomic, strong)NSDictionary *unformattedTimes;
//    @property(nonatomic, strong)NSMutableDictionary *openingTimesDictionary;
//    @property(nonatomic, strong)NSMutableDictionary *prioritiesDictionary;
//    @property(nonatomic)bool locked;
//    @property(nonatomic)bool isHome;
//    @property(nonatomic)int scheduledTimeBlock;
//    @property(nonatomic)int timeToSpend;
//    @property(nonatomic)bool isSelected;
//    @property(nonatomic)bool hasAlreadyGone;
//    @property(nonatomic)bool isHub;
//    @property(strong, nonatomic)NSMutableArray *arrayOfNearbyPlaces;
//    @property(strong, nonatomic)NSMutableDictionary *dictionaryOfArrayOfPlaces;
   
//}
}

@end
