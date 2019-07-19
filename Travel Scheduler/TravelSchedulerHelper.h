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
UIButton* generateScheduleButton(int screenHeight, int screenWidth, int yCoord);
void setupGRonImagewithTaps(UITapGestureRecognizer *tgr, UIImageView *imageView, int numTaps);
NSDate* getNextDate(NSDate *date);
int getDayNumber(NSDate *date);

@end

NS_ASSUME_NONNULL_END
