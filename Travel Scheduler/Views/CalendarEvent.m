//
//  CalendarEvent.m
//  Travel Scheduler
//
//  Created by aliu18 on 8/5/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "CalendarEvent.h"
#import <EventKit/EventKit.h>
#import "Place.h"

@implementation CalendarEvent

- (instancetype)initWithPlace:(Place *)place requestStatus:(bool)needsToRequestAccessToEventStore
{
    self = [super init];
    self.place = place;
    EKAuthorizationStatus authorizationStatus = EKAuthorizationStatusAuthorized; // iOS 5 behavior
//    if ([[EKEventStore class] respondsToSelector:@selector(authorizationStatusForEntityType:)]) {
//        authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
//        needsToRequestAccessToEventStore = (authorizationStatus == EKAuthorizationStatusNotDetermined);
//    }
    self.store = [EKEventStore new];
    if (needsToRequestAccessToEventStore) {
        [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // You can use the event store now
                });
            }
        }];
//    } else if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        // You can use the event store now
    } else {
        // Access denied
    }
    return self;
}

- (void)addToCalendar
{
    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:self.store];
        event.title = self.place.name;
        event.startDate = [NSDate date]; //today
        event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
        event.calendar = [self.store defaultCalendarForNewEvents];
        NSError *err = nil;
        [self.store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        self.savedEventId = event.eventIdentifier;  //save the event id if you want to access this later
        self.place.calendarEvent = self;
    }];
}

- (void)removeFromCalendar
{
    EKEventStore* store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent* eventToRemove = [store eventWithIdentifier:self.savedEventId];
        if (eventToRemove) {
            NSError* error = nil;
            [store removeEvent:eventToRemove span:EKSpanThisEvent commit:YES error:&error];
        }
    }];
}

@end
