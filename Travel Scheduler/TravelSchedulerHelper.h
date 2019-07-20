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

extern int breakfast;
extern int morning;
extern int lunch;
extern int afternoon;
extern int dinner;
extern int evening;

@end

NS_ASSUME_NONNULL_END
