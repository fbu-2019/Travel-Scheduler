//
//  ScheduleEventView.h
//  Travel Scheduler
//
//  Created by aliu18 on 8/5/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleEventView : UIView

@property (strong, nonatomic) ScheduleEventView *prevEvent;
@property (strong, nonatomic) ScheduleEventView *nextEvent;

@end

NS_ASSUME_NONNULL_END
