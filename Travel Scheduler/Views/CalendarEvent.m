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
#import "Date.h"

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
                    [self addToCalendar];
                });
            }
        }];
    } else if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        [self addToCalendar];
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
        event.startDate = createDateWithSpecificTime(self.place.date, (int)self.place.arrivalTime, getMinFromFloat(self.place.arrivalTime));
        event.endDate = createDateWithSpecificTime(self.place.date, (int)self.place.departureTime, getMinFromFloat(self.place.departureTime));
        event.calendar = [self.store defaultCalendarForNewEvents];
        NSError *err = nil;
        [self.store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        self.savedEventId = event.eventIdentifier;
        self.place.calendarEvent = self;
    }];
}

- (void)removeFromCalendar
{
    self.store = [EKEventStore new];
    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent* eventToRemove = [self.store eventWithIdentifier:self.savedEventId];
        if (eventToRemove) {
            NSError* error = nil;
            [self.store removeEvent:eventToRemove span:EKSpanThisEvent commit:YES error:&error];
        }
    }];
}

@end
