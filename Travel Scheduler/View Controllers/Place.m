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

- (Place *)initWithName:(NSString *)name {
    __block Place *place = nil;
    [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            NSLog(@"Success in getting dictionary");
            place = [self initWithDictionary:placeInfoDictionary];
        }
        else {
            NSLog(@"could not get dictionary");
        }
    }];
    return place;
}

- (NSArray *)getListOfPlacesCloseToPlaceWithName:(NSString *)centerPlaceName {
    __block NSMutableArray *arrayOfPlaces = nil;
    Place *hubPlace = [self initWithName:centerPlaceName];
    NSString *hubLatitude = hubPlace.coordinates[@"lat"];
    NSString *hubLongitude = hubPlace.coordinates[@"lng"];
    
    [[APIManager shared]getPlacesCloseToLatitude:hubLatitude andLongitude:hubLongitude withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *error) {
        if(arrayOfPlacesDictionary) {
            NSLog(@"Array of places dictionary worked");
            arrayOfPlaces = [self placesWithArray:arrayOfPlacesDictionary];
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
    return arrayOfPlaces;
}
@end
