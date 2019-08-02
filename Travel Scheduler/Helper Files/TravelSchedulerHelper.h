//
//  TravelSchedulerHelper.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TravelSchedulerHelper : NSObject

typedef NS_ENUM(NSInteger, TimeBlock)
{
    TimeBlockBreakfast = 0,
    TimeBlockMorning,
    TimeBlockLunch,
    TimeBlockAfternoon,
    TimeBlockDinner,
    TimeBlockEvening
};

typedef NS_ENUM(NSInteger, DayOfWeek)
{
    DayOfWeekSunday = 0,
    DayOfWeekMonday,
    DayOfWeekTuesday,
    DayOfWeekWednesday,
    DayOfWeekThursday,
    DayOfWeekFriday,
    DayOfWeekSaturday
};

TimeBlock getNextTimeBlock(TimeBlock timeBlock);
UILabel* makeHeaderLabel(NSString *text, int size);
UILabel *makeSubHeaderLabel(NSString *text, int size);
UILabel *makeThinHeaderLabel(NSString *text, int size);
UILabel *makeTimeRangeLabel(NSString *text, int size);
UIButton *makeScheduleButton(NSString *string);
void setupGRonImagewithTaps(UITapGestureRecognizer *tgr, UIView *imageView, int numTaps);
NSString* formatMinutes(int min);
float getMax(float num1, float num2);
float getMin(float num1, float num2);
UIImageView *makeImage(NSURL *placeUrl);
CAShapeLayer *makeDashedLine(int yStart, int xCoord, CAShapeLayer *shapeLayer);
NSString *getStringFromTimeBlock(TimeBlock timeBlock);
UILabel *makeTimeRangeLabel(NSString *text, int size);

@end

NS_ASSUME_NONNULL_END
