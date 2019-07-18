//
//  Hub.m
//  Travel Scheduler
//
//  Created by gilemos on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Hub.h"
#import "APIManager.h"
#import "NSArray+Map.h"

@implementation Hub

- (void)initHubWithName:(NSString *)name withCompletion:(void (^)(Hub *hub, NSError *error))completion{
    
    [super initWithName:name withCompletion:^(Place * _Nonnull place, NSError * _Nonnull error) {
        if(place) {
            self.imageView = [[UIImageView alloc] init];
            self.name = place.name;
            self.address = place.address;
            self.coordinates = place.coordinates;
            self.iconUrl = place.iconUrl;
            self.placeId = place.placeId;
            self.rating = place.rating;
            self.photos = place.photos;
            self.types = place.types;
            self.imageView = place.imageView;
            
            [self makeArrayOfNearbyPlacesWithType:@"point_of_interest"];
            completion(self, nil);
        }
    }];
    
}

-(void)makeAllPlacesArray {
    [self makeArrayOfNearbyPlacesWithType:@"point_of_interest"];
    //[self makeArrayOfNearbyPlacesWithType:@"aquarium"];
    //[self makeArrayOfNearbyPlacesWithType:@"amusement_park"];
    //[self makeArrayOfNearbyPlacesWithType:@"amusement_park"];
    //[self makeArrayOfNearbyPlacesWithType:@"amusement_park"];
    
}
- (void)makeArrayOfNearbyPlacesWithType:(NSString *)type {
    [[APIManager shared]getPlacesCloseToLatitude:self.coordinates[@"lat"] andLongitude:self.coordinates[@"lng"] ofType:type withCompletion:^(NSArray *arrayOfPlacesDictionary, NSError *getPlacesError) {
        if(arrayOfPlacesDictionary) {
            NSLog(@"Array of places dictionary worked");
            [self placesWithArray:arrayOfPlacesDictionary];
        }
        else {
            NSLog(@"did not work snif");
        }
    }];
}

- (void)placesWithArray:(NSArray *)arrayOfPlaceDictionaries {
    self.arrayOfNearbyPlaces = [arrayOfPlaceDictionaries mapObjectsUsingBlock:^(id obj, NSUInteger idx) {
        Place *place = [[Place alloc] initWithDictionary:obj];
        dispatch_semaphore_t setUpCompleted = dispatch_semaphore_create(0);
        [[Place alloc] setImageViewOfPlace:place withPriority:YES withDispatch:setUpCompleted withCompletion:^(UIImage *image, NSError * _Nonnull error) {
            if(image) {
                place.imageView.image = image;
            }
            else {
                NSLog(@"did not work snif");
            }
        }];
        
        dispatch_semaphore_wait(setUpCompleted, DISPATCH_TIME_FOREVER);
        //dispatch_release(setUpCompleted);
        return place;
        
    }];
}

@end
