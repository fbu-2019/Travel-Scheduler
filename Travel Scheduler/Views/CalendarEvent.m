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

#pragma mark - CalendarEvent lifecycle

- (instancetype)initWithPlace:(Place *)place requestStatus:(bool)needsToRequestAccessToEventStore
{
    self = [super init];
    self.place = place;
    EKAuthorizationStatus authorizationStatus = EKAuthorizationStatusAuthorized;
    if ([[EKEventStore class] respondsToSelector:@selector(authorizationStatusForEntityType:)]) {
        authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        needsToRequestAccessToEventStore = (authorizationStatus == EKAuthorizationStatusNotDetermined);
    }
    self.store = [EKEventStore new];
    if (authorizationStatus == EKAuthorizationStatusAuthorized) {
    } else {
        authorizationStatus = EKAuthorizationStatusNotDetermined;
    }
    [self addToCalendar];
    return self;
}

#pragma mark - Calendar event actions

- (void)addToCalendar
{
    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) {
            NSLog([NSString stringWithFormat:@"Prelim error: ", error]);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            EKEvent *event = [EKEvent eventWithEventStore:self.store];
            event.title = self.place.name;
            event.startDate = createDateWithSpecificTime(self.place.date, (int)self.place.arrivalTime, getMinFromFloat(self.place.arrivalTime));
            event.endDate = createDateWithSpecificTime(self.place.date, (int)self.place.departureTime, getMinFromFloat(self.place.departureTime));
            event.calendar = [self.store defaultCalendarForNewEvents];
            NSError *err = nil;
            [self.store saveEvent:event span:EKSpanThisEvent error:&err];
            if (error) {
                NSLog([NSString stringWithFormat:@"Place adding error: %@", error]);
            }
            [self.place.placeView.calendarButton setTitle:@"Remove" forState:UIControlStateNormal];
            self.savedEventId = event.eventIdentifier;
            self.place.calendarEvent = self;
        });
    }];
}

- (void)removeFromCalendar
{
    [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        dispatch_async(dispatch_get_main_queue(), ^{
        EKEvent* eventToRemove = [self.store eventWithIdentifier:self.savedEventId];
        if (eventToRemove) {
            NSError* error = nil;
            [self.store removeEvent:eventToRemove span:EKSpanThisEvent commit:YES error:&error];
            if (error) {
                NSLog([NSString stringWithFormat:@"Removal error: %@", error]);
            }
            [self.place.placeView.calendarButton setTitle:@"Add to calendar" forState:UIControlStateNormal];
        }
        });
    }];
}

- (void)updateEvent
{
    [self removeFromCalendar];
    self.place.calendarEvent = nil;
    [self addToCalendar];
}

@end
