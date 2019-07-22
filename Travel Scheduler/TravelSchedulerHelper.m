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

static int tabBarSpace = 90;

#pragma mark - UI creation

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

UIButton* makeButton(NSString *string, int screenHeight, int screenWidth, int yCoord) {
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

void setupGRonImagewithTaps(UITapGestureRecognizer *tgr, UIImageView *imageView, int numTaps) {
    tgr.numberOfTapsRequired = (NSInteger) numTaps;
    [imageView addGestureRecognizer:tgr];
    [imageView setUserInteractionEnabled:YES];
}

#pragma mark - Date method helpers

NSDate* getNextDate(NSDate *date, int offset) {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    NSInteger theDay = [todayComponents day];
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:offset];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    return nextDate;
}

int getDayNumber(NSDate *date) {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger day = [components day];
    return day;
}

NSString* getDayOfWeek(NSDate *date) {
    NSDateFormatter* day = [[NSDateFormatter alloc] init];
    [day setDateFormat: @"EEEE"];
    NSString *dayString = [day stringFromDate:date];
    return dayString;
}

NSDate* removeTime(NSDate *date) {
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}

@implementation TravelSchedulerHelper

@end
