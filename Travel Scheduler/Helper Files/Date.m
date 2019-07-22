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

@end
