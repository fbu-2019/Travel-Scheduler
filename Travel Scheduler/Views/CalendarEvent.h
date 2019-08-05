//
//  CalendarEvent.h
//  Travel Scheduler
//
//  Created by aliu18 on 8/5/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EKEventStore;
@class Place;

NS_ASSUME_NONNULL_BEGIN

@interface CalendarEvent : NSObject

@property (strong, nonatomic) NSString *savedEventId;
@property (strong, nonatomic) EKEventStore *store;
@property (strong, nonatomic) Place *place;

- (instancetype)initWithPlace:(Place *)place requestStatus:(bool)needsToRequestAccessToEventStore;

@end

NS_ASSUME_NONNULL_END
