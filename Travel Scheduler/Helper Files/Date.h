//
//  Date.h
//  Travel Scheduler
//
//  Created by gilemos on 7/22/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "TravelSchedulerHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface Date : NSObject

+ (float)getFormattedTimeFromString:(NSString *)timeString;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
DayOfWeek getDayOfWeekAsInt(NSDate *date);
NSDate* getSunday(NSDate *date, int offset);
NSString* getMonth(NSDate *date);
NSDate* getNextDate(NSDate *date, int offset);
int getDayNumber(NSDate *date);
NSString* getDayOfWeek(NSDate *date);
NSDate* removeTime(NSDate *date);
NSString *getDateAsString(NSDate *date);
NSDate *createDateWithSpecificTime(NSDate *date, int hour, int min);
int getMinFromFloat(float num);

@end

NS_ASSUME_NONNULL_END
