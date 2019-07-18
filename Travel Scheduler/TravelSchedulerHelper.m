//
//  TravelSchedulerHelper.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "TravelSchedulerHelper.h"
#import <UIKit/UIKit.h>

static int tabBarSpace = 90;

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

UIButton* generateScheduleButton(int screenHeight, int screenWidth, int yCoord) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Generate Schedule" forState:UIControlStateNormal];
    int xCoord = 25;
    int height = screenHeight - yCoord - (2 * 5) - tabBarSpace;
    button.frame = CGRectMake(xCoord, yCoord + 10, screenWidth - 2 * xCoord, height);
    button.backgroundColor = [UIColor blueColor];
    button.layer.cornerRadius = 10; // this value vary as per your desire
    button.clipsToBounds = YES;
    return button;
}

@implementation TravelSchedulerHelper

@end
