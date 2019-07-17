//
//  Place.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "Place.h"

@implementation Place

- (void)initWithDictionary:(NSDictionary *)dictionary {
    self.name = dictionary[@"name"];
    self.address = dictionary[@"formatted_address"];
    self.coordinates = dictionary[@"geometry"][@"location"];
    self.iconUrl = dictionary[@"icon"];
    self.placeId = dictionary[@"place_id"];
    self.rating = dictionary[@"rating"];
    self.photos = dictionary[@"photos"];
    self.types = dictionary[@"types"];
}

- (void)initWithName:(NSDictionary *)name {

}
@end
