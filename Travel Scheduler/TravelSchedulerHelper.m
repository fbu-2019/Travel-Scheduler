//
//  TravelSchedulerHelper.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "TravelSchedulerHelper.h"
#import <UIKit/UIKit.h>

int breakfast = 0;
int morning = 1;
int lunch = 2;
int afternoon = 3;
int dinner = 4;
int evening = 5;

UILabel* makeHeaderLabel(NSString *text) {
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(15, 95, 500, 50)];
    [label setFont: [UIFont fontWithName:@"Arial-BoldMT" size:40]];
    label.text = text;
    label.numberOfLines = 1;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.minimumScaleFactor = 10.0f/12.0f;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

@implementation TravelSchedulerHelper

@end
