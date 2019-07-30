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
#import "Place.h"

TimeBlock getNextTimeBlock(TimeBlock timeBlock)
{
    return (timeBlock == TimeBlockEvening) ? 0 : timeBlock + 1;
}

#pragma mark - UI creation

UILabel *makeHeaderLabel(NSString *text, int size)
{
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectZero];
    [label setFont: [UIFont fontWithName:@"Gotham-Bold" size:size]];
    label.text = text;
    UIColor *grayColor = [UIColor colorWithRed:0.33 green:0.36 blue:0.41 alpha:1];
    label.textColor = grayColor;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    return label;
}

UILabel *makeSubHeaderLabel(NSString *text, int size)
{
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectZero];
    [label setFont: [UIFont fontWithName:@"Gotham-Thin" size:size]];
    label.text = text;
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    [label sizeToFit];
    return label;
}

UIButton *makeScheduleButton(NSString *string)
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button.titleLabel setFont:[UIFont fontWithName:@"Gotham-XLight" size:20]];
    [button setTitle:string forState:UIControlStateNormal];
    UIColor *pinkColor = [UIColor colorWithRed:0.93 green:0.30 blue:0.40 alpha:1];
    button.backgroundColor = pinkColor;
    button.layer.cornerRadius = 2;
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
