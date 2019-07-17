//
//  Place.h
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Place : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSDictionary *coordinates;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *phoneNumber;
@property(nonatomic, strong) NSString *website;
@property(nonatomic, strong) NSArray *types;



@end

NS_ASSUME_NONNULL_END