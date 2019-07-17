//
//  Place.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Place.h"
#import "APIManager.h"

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
    }
    return self;
}

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
@end
