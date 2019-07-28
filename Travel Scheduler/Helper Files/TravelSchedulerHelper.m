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
#import "UIImageView+AFNetworking.h"

static int tabBarSpace = 90;

TimeBlock getNextTimeBlock(TimeBlock timeBlock)
{
    return (timeBlock == TimeBlockEvening) ? 0 : timeBlock + 1;
}

#pragma mark - UI creation

UILabel *makeHeaderLabel(NSString *text)
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

UIButton *makeButton(NSString *string, int screenHeight, int screenWidth, int yCoord)
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

UIImageView *makeImage(NSURL *placeUrl)
{
    UIImageView *placeImage = [[UIImageView alloc] init];
    placeImage.backgroundColor = [UIColor whiteColor];
    int diameter = 45;
    placeImage.frame = CGRectMake(5, 5, diameter, diameter);
    placeImage.layer.cornerRadius = placeImage.frame.size.width / 2;
    placeImage.clipsToBounds = YES;
    NSURL *url = [[NSURL alloc] initWithString:placeUrl];
    [placeImage setImageWithURL:url];
    return placeImage;
}

UILabel *makeLabel(int xCoord, int yCoord, NSString *text, CGRect frame, UIFont *font)
{
    CGFloat xVal = (CGFloat) xCoord;
    CGFloat yVal = (CGFloat) yCoord;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xVal, yVal, CGRectGetWidth(frame) - 140 - 5, 35)];
    label.text = text;
    [label setNumberOfLines:0];
    [label setFont:font];
    [label sizeToFit];
    label.alpha = 1;
    return label;
}

#pragma mark - Tap Gesture Recognizer helper

void setupGRonImagewithTaps(UITapGestureRecognizer *tgr, UIView *imageView, int numTaps)
{
    tgr.numberOfTapsRequired = (NSInteger) numTaps;
    [imageView addGestureRecognizer:tgr];
    [imageView setUserInteractionEnabled:YES];
}

#pragma mark - Max and min functions

float getMax(float num1, float num2)
{
    return (num1 > num2) ? num1 : num2;
}

float getMin(float num1, float num2)
{
    return (num1 > num2) ? num2 : num1;
}

@implementation TravelSchedulerHelper

@end
