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
@end
