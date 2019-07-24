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

UILabel* makeHeaderLabel(NSString *text);
UIButton* makeButton(NSString *string, int screenHeight, int screenWidth, int yCoord);
void setupGRonImagewithTaps(UITapGestureRecognizer *tgr, UIImageView *imageView, int numTaps);
NSDate* getNextDate(NSDate *date, int offset);
int getDayNumber(NSDate *date);
NSString* getDayOfWeek(NSDate *date);
NSDate* removeTime(NSDate *date);
NSString* formatMinutes(int min);
float getMax(float num1, float num2);
float getMin(float num1, float num2);

typedef NS_ENUM(NSInteger, TimeBlock)
{
    TimeBlockBreakfast = 0,
    TimeBlockMorning,
    TimeBlockLunch,
    TimeBlockAfternoon,
    TimeBlockDinner,
    TimeBlockEvening
};

@end

NS_ASSUME_NONNULL_END
