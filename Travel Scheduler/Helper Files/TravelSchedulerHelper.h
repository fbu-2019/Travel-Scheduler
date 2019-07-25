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
UILabel* makeHeaderLabel(NSString *text);
UIButton* makeButton(NSString *string, int screenHeight, int screenWidth, int yCoord);
void setupGRonImagewithTaps(UITapGestureRecognizer *tgr, UIImageView *imageView, int numTaps);
NSString* formatMinutes(int min);
float getMax(float num1, float num2);
float getMin(float num1, float num2);

@end

NS_ASSUME_NONNULL_END
