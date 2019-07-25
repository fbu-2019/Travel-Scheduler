//
//  TravelSchedulerHelper.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "TravelSchedulerHelper.h"
#import "Date.h"
#import <UIKit/UIKit.h>

static int tabBarSpace = 90;

#pragma mark - UI creation
UILabel* makeHeaderLabel(NSString *text)
{
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

UIButton* makeButton(NSString *string, int screenHeight, int screenWidth, int yCoord)
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:string forState:UIControlStateNormal];
    int xCoord = 25;
    int height = screenHeight - yCoord - (2 * 5) - tabBarSpace;
    button.frame = CGRectMake(xCoord, yCoord + 10, screenWidth - 2 * xCoord, height);
    button.backgroundColor = [UIColor blueColor];
    button.layer.cornerRadius = 10;
    button.clipsToBounds = YES;
    return button;
}

#pragma mark - Tap Gesture Recognizer helper
void setupGRonImagewithTaps(UITapGestureRecognizer *tgr, UIImageView *imageView, int numTaps)
{
    tgr.numberOfTapsRequired = (NSInteger) numTaps;
    [imageView addGestureRecognizer:tgr];
    [imageView setUserInteractionEnabled:YES];
}

#pragma mark - Date method helpers

float getMax(float num1, float num2) {
    if (num1 > num2) {
        return num1;
    }
    return num2;
}

float getMin(float num1, float num2) {
    if (num1 > num2) {
        return num2;
    }
    return num1;
}

@implementation TravelSchedulerHelper

@end
