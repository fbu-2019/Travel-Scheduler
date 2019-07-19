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
    bool _gotPlacesClient;
}

-(void)getPlacesClient {
        if(self->_gotPlacesClient != YES){
            self->_placesClient = [GMSPlacesClient sharedClient];
            self->_gotPlacesClient = YES;
        }
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getPlacesClient];
        
        if(self) {
            self.imageView = [[UIImageView alloc] init];
            self.name = dictionary[@"name"];
            self.address = dictionary[@"formatted_address"];
            self.coordinates = dictionary[@"geometry"][@"location"];
            self.iconUrl = dictionary[@"icon"];
            self.placeId = dictionary[@"place_id"];
            self.rating = dictionary[@"rating"];
            self.photos = dictionary[@"photos"];
            self.types = dictionary[@"types"];
        }
    });
    return self;
}


- (void)initWithName:(NSString *)name withCompletion:(void (^)(Place *place, NSError *error))completion {
    [[APIManager shared]getCompleteInfoOfLocationWithName:name withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            NSLog(@"Success in getting dictionary");
            Place *place = [self initWithDictionary:placeInfoDictionary];
            [self setImageViewOfPlace:place withPriority:NO withDispatch:nil withCompletion:^(UIImage *image, NSError *error) {
                if(image) {
                    place.imageView.image = image;
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


@end
