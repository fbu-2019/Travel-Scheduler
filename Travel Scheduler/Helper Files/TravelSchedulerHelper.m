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

NSString *getStringFromTimeBlock(TimeBlock timeBlock)
{
    switch(timeBlock) {
        case TimeBlockBreakfast:
            return @"breakfast";
        case TimeBlockMorning:
            return @"morning";
        case TimeBlockLunch:
            return @"lunch";
        case TimeBlockAfternoon:
            return @"afternoon";
        case TimeBlockDinner:
            return @"dinner";
        case TimeBlockEvening:
            return @"evening";
    }
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
    return label;
}

UILabel *makeSubHeaderLabel(NSString *text, int size)
{
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectZero];
    [label setFont: [UIFont fontWithName:@"Gotham-Light" size:size]];
    label.text = text;
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

UILabel *makeThinHeaderLabel(NSString *text, int size)
{
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectZero];
    [label setFont: [UIFont fontWithName:@"Gotham-XLight" size:size]];
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
    button.backgroundColor = getColorFromIndex(CustomColorRegularPink);
    button.layer.cornerRadius = 2;
    button.clipsToBounds = YES;
    return button;
}

UIImageView *makeImage(NSURL *placeUrl)
{
    UIImageView *placeImage = [[UIImageView alloc] init];
    placeImage.backgroundColor = [UIColor whiteColor];
    placeImage.layer.cornerRadius = 20;
    placeImage.clipsToBounds = YES;
    NSURL *url = [[NSURL alloc] initWithString:placeUrl];
    [placeImage setImageWithURL:url];
    return placeImage;
}

CAShapeLayer *makeDashedLine(int yStart, int xCoord, CAShapeLayer *shapeLayer)
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(xCoord, yStart)];
    [path addLineToPoint:CGPointMake(xCoord, 0)];
    [path stroke];
    shapeLayer.path = [path CGPath];
    UIColor *lightGrayColor = [UIColor colorWithRed:0.65 green:0.69 blue:0.76 alpha:0.8];
    shapeLayer.strokeColor = [lightGrayColor CGColor];
    shapeLayer.lineWidth = 3;
    shapeLayer.fillColor = [[UIColor yellowColor] CGColor];
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:5],nil]];
    return shapeLayer;
}

UILabel *makeTimeRangeLabel(NSString *text, int size)
{
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectZero];
    [label setFont: [UIFont fontWithName:@"Gotham-XLight" size:size]];
    label.text = text;
    label.textColor = [UIColor darkGrayColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

#pragma mark - Color helper
UIColor *getColorFromIndex(int index)
{
    NSArray *colorArray = [NSArray alloc];
    colorArray = @[[UIColor colorWithRed:0.33 green:0.94 blue:0.77 alpha:1.0], [UIColor colorWithRed:0.51 green:0.93 blue:0.93 alpha:1.0], [UIColor colorWithRed:0.45 green:0.73 blue:1.00 alpha:1.0], [UIColor colorWithRed:0.64 green:0.61 blue:1.00 alpha:1.0], [UIColor colorWithRed:0.00 green:0.72 blue:0.58 alpha:1.0], [UIColor colorWithRed:0.00 green:0.81 blue:0.79 alpha:1.0], [UIColor colorWithRed:0.04 green:0.52 blue:0.89 alpha:1.0], [UIColor colorWithRed:0.42 green:0.36 blue:0.91 alpha:1.0], [UIColor colorWithRed:0.98 green:0.69 blue:0.63 alpha:1.0], [UIColor colorWithRed:1.00 green:0.46 blue:0.46 alpha:1.0], [UIColor colorWithRed:0.99 green:0.47 blue:0.66 alpha:1.0], [UIColor colorWithRed:0.99 green:0.80 blue:0.43 alpha:1.0], [UIColor colorWithRed:0.88 green:0.44 blue:0.33 alpha:1.0], [UIColor colorWithRed:0.84 green:0.19 blue:0.19 alpha:1.0], [UIColor colorWithRed:0.91 green:0.26 blue:0.58 alpha:1.0], [UIColor colorWithRed:0.93 green:0.30 blue:0.40 alpha:1],[UIColor colorWithRed:0.97 green:0.65 blue:0.76 alpha:1]];
    
    if(index < 1 || index > (colorArray.count - 1)) {
        index = arc4random_uniform((int)colorArray.count - 1);
    }
    return colorArray[index];
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
