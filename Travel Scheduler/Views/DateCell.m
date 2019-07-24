//
//  DateCell.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "DateCell.h"
#import "TravelSchedulerHelper.h"
#import "Date.h"

#pragma mark - default label settings

static UILabel* makeDayLabel(NSString *text) {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label adjustsFontSizeToFitWidth];
    return label;
}

@implementation DateCell

#pragma mark - DateCell initiation

- (void)makeDate:(NSDate *)date givenStart:(NSDate *)startDate andEnd:(NSDate *)endDate {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.date = date;
    [self createDayOfWeekLabel];
    [self createDayLabel];
    if ((([date compare:endDate] == NSOrderedAscending) && ([date compare:startDate] == NSOrderedDescending))) {
        self.dayLabel.textColor = [UIColor blackColor];
        self.dayStringLabel.textColor = [UIColor blackColor];
        UITapGestureRecognizer *dateTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapDate)];
        setupGRonImagewithTaps(dateTapGestureRecognizer, self.dayLabel, 1);
    }
}

#pragma mark - Action: tapped date

- (void)didTapDate {
    [self.delegate dateCell:self didTap:self.date];
}

#pragma mark - Selection settings

- (void)setUnselected {
    self.dayLabel.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected {
    self.dayLabel.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark - Label creation helpers

- (void)createDayOfWeekLabel {
    NSString *dayString = getDayOfWeek(self.date);
    if (self.dayStringLabel) {
        [self.dayStringLabel removeFromSuperview];
    }
    NSString *text;
    if ([dayString isEqualToString:@"Monday"]) {
        text = @"M";
    } else if ([dayString isEqualToString:@"Tuesday"]) {
        text = @"T";
    } else if ([dayString isEqualToString:@"Wednesday"]) {
        text = @"W";
    } else if ([dayString isEqualToString:@"Thursday"]) {
        text = @"Th";
    } else if ([dayString isEqualToString:@"Friday"]) {
        text = @"F";
    } else if ([dayString isEqualToString:@"Saturday"]) {
        text = @"S";
    } else if ([dayString isEqualToString:@"Sunday"]) {
        text = @"Su";
    }
    self.dayStringLabel = makeDayLabel(text);
    UIFont *thinFont = [UIFont systemFontOfSize:12 weight:UIFontWeightThin];
    [self.dayStringLabel setFont:thinFont];
    self.dayStringLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), 10);
    [self.contentView addSubview:self.dayStringLabel];
}

- (void)createDayLabel {
    int dayNum = getDayNumber(self.date);
    if (self.dayLabel) {
        [self.dayLabel removeFromSuperview];
    }
    self.dayLabel = makeDayLabel([NSString stringWithFormat:@"%d", dayNum]);
    CGRect frame = self.contentView.frame;
    self.dayLabel.frame = CGRectMake(7.5, 12.5, 35, 35);
    self.dayLabel.layer.cornerRadius = self.dayLabel.frame.size.width / 2;
    self.dayLabel.clipsToBounds = YES;
    [self.contentView addSubview:self.dayLabel];
}

@end
