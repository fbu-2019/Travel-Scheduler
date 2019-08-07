//
//  Date.m
//  Travel Scheduler
//
//  Created by gilemos on 7/22/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Date.h"
#import "TravelSchedulerHelper.h"

DayOfWeek getDayOfWeekAsInt(NSDate *date)
{
    NSString *dayString = getDayOfWeek(date);
    if ([dayString isEqualToString:@"Monday"]) {
        return DayOfWeekMonday;
    } else if ([dayString isEqualToString:@"Tuesday"]) {
        return DayOfWeekTuesday;
    } else if ([dayString isEqualToString:@"Wednesday"]) {
        return DayOfWeekWednesday;
    } else if ([dayString isEqualToString:@"Thursday"]) {
        return DayOfWeekThursday;
    } else if ([dayString isEqualToString:@"Friday"]) {
        return DayOfWeekFriday;
    } else if ([dayString isEqualToString:@"Saturday"]) {
        return DayOfWeekSaturday;
    } else if ([dayString isEqualToString:@"Sunday"]) {
        return DayOfWeekSunday;
    }
    return -1;
}

NSDate *getSunday(NSDate *date, int offset)
{
    NSString *dayOfWeek = getDayOfWeek(date);
    while (![dayOfWeek isEqualToString:@"Sunday"]) {
        date = getNextDate(date, offset);
        dayOfWeek = getDayOfWeek(date);
    }
    return date;
}

NSString *getMonth(NSDate *date)
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    NSString *month = [formatter stringFromDate:date];
    return month;
}

NSDate *getNextDate(NSDate *date, int offset)
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    NSInteger theDay = [todayComponents day];
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:offset];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    return nextDate;
}

int getDayNumber(NSDate *date)
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger day = [components day];
    return day;
}

NSString *getDayOfWeek(NSDate *date)
{
    NSDateFormatter* day = [[NSDateFormatter alloc] init];
    [day setDateFormat: @"EEEE"];
    NSString *dayString = [day stringFromDate:date];
    return dayString;
}

NSString *getDateAsString(NSDate *date)
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE MM/dd/yyyy"];
    return [dateFormat stringFromDate:date];
}

NSDate *removeTime(NSDate *date)
{
    if (date == nil) {
        return nil;
    }
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}

NSString *formatMinutes(int min)
{
    return (min < 10) ? [NSString stringWithFormat:@"0%d", min] : [NSString stringWithFormat:@"%d", min];
}

@implementation Date

+ (float)getFormattedTimeFromString:(NSString *)timeString
{
    NSString *hourString = [timeString substringToIndex:2];
    int hourInt = [hourString intValue];
    NSString *minuteString = [timeString substringFromIndex:2];
    float minuteIntRaw = [minuteString floatValue];
    float minuteInt = minuteIntRaw/60;
    float formattedTime = hourInt + minuteInt;
    return formattedTime;
}

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:toDateTime];
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}

NSDate *createDateWithSpecificTime(NSDate *date, int hour, int min)
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    [dateComponents setHour:hour];
    [dateComponents setMinute:min];
    NSCalendar *calendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSDate *configuredDate = [calendar dateFromComponents:dateComponents];
    return configuredDate;
}

int getMinFromFloat(float num)
{
    float decimal = num - (int)num;
    return (int)(decimal * 60);
}

@end
