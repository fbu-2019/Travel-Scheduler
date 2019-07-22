//
//  Date.m
//  Travel Scheduler
//
//  Created by gilemos on 7/22/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Date.h"

@implementation Date

+ (float)getFormattedTimeFromString:(NSString *)timeString{
    NSString *hourString = [timeString substringToIndex:2];
    int hourInt = [hourString intValue];
    NSString *minuteString = [timeString substringFromIndex:2];
    float minuteIntRaw = [minuteString floatValue];
    float minuteInt = minuteIntRaw/60;
    float formattedTime = hourInt + minuteInt;
    return formattedTime;
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}
@end
