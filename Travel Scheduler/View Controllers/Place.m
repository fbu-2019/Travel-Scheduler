//
//  Place.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Place.h"
#import "APIManager.h"
@import GooglePlaces;

@implementation Place {
GMSPlacesClient *_placesClient;
}

-(void)getPlacesClient {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_placesClient = [GMSPlacesClient sharedClient];
    });
}
- (void)initWithDictionary:(NSDictionary *)dictionary withCompletion:(void (^)(Place *place, NSError *error))completion {
    
    [self getPlacesClient];
    Place *place = [[Place alloc] init];

    if(place) {
        place.imageView = [[UIImageView alloc] init];
        place.name = dictionary[@"name"];
        place.address = dictionary[@"formatted_address"];
        place.coordinates = dictionary[@"geometry"][@"location"];
        place.iconUrl = dictionary[@"icon"];
        place.placeId = dictionary[@"place_id"];
        place.rating = dictionary[@"rating"];
        place.photos = dictionary[@"photos"];
        place.types = dictionary[@"types"];
        [self setImageViewOfPlace:place withCompletion:^(UIImage *photo, NSError *error) {
            if(photo) {
                place.imageView.image = photo;
                completion(place, nil);
            }
            else {
                NSLog(@"error");
                completion(nil, error);
            }
        }];
    }
}

- (NSMutableArray *)placesWithArray:(NSArray *)arrayOfPlaceDictionaries {
    NSMutableArray *arrayOfPlaces = [NSMutableArray array];
    for (NSDictionary *dictionary in arrayOfPlaceDictionaries) {
        [self initWithDictionary:dictionary withCompletion:^(Place *place, NSError *error) {
            if(place) {
                [arrayOfPlaces addObject:place];
            }
            else {
                NSLog(@"error");
            }
        }];
    }
    return arrayOfPlaces;
}

- (void)initWithName:(NSString *)name withCompletion:(void (^)(Place *place, NSError *error))completion {
    [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            NSLog(@"Success in getting dictionary");
            [self initWithDictionary:placeInfoDictionary withCompletion:^(Place *place, NSError *error) {
                if(place) {
                    completion(place, nil);
                }
                else {
                    NSLog(@"error");
                    completion(nil, error);
                }
            }];
        }
        else {
            NSLog(@"could not get dictionary");
            completion(nil, error);
        }
    }];
}

- (void)getListOfPlacesCloseToPlaceWithName:(NSString *)centerPlaceName withType:(NSString *)type withCompletion:(void (^)(NSMutableArray *arrayOfPlaces, NSError *error))completion{
    [self initWithName:centerPlaceName withCompletion:^(Place *hubPlace, NSError *initWithNameError) {
        if(hubPlace) {
            NSString *hubLatitude = hubPlace.coordinates[@"lat"];
            NSString *hubLongitude = hubPlace.coordinates[@"lng"];
            
            [[APIManager shared]getPlacesCloseToLatitude:hubLatitude andLongitude:hubLongitude ofType:type withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
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

- (void)setImageViewOfPlace:(Place *)myPlace withCompletion:(void (^)(UIImage *image, NSError *error))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
    GMSPlaceField fields = (GMSPlaceFieldPhotos);
    
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
                    completion((UIImage *)photo, nil);
                   // myPlace.imageView.image = photo;
            
                }
            }];
        }
    }];
    });
}


@end
