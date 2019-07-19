//
//  DateCell.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "DateCell.h"
#import "TravelSchedulerHelper.h"

static UILabel* makeDayLabel(int dayNum) {
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%d", dayNum];
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

@implementation DateCell

- (void)makeDate:(NSDate *)date {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.date = date;
    int dayNum = getDayNumber(date);
    if (self.dayLabel) {
        [self.dayLabel removeFromSuperview];
    }
    //if (self.dayLabel == nil) {
        self.dayLabel = makeDayLabel(dayNum);
        self.dayLabel.frame = self.contentView.frame;
        [self.contentView addSubview:self.dayLabel];
    //}
    UITapGestureRecognizer *dateTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapDate)];
    setupGRonImagewithTaps(dateTapGestureRecognizer, self.dayLabel, 1);
}

- (void)didTapDate {
    //self.contentView.backgroundColor = [UIColor lightGrayColor];
    [self.delegate dateCell:self didTap:self.date];
}

- (void)setUnselected {
    self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected {
    self.contentView.backgroundColor = [UIColor lightGrayColor];
}



@end
