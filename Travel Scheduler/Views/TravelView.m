//
//  TravelView.m
//  Travel Scheduler
//
//  Created by aliu18 on 8/1/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "TravelView.h"
#import "Place.h"
#import "TravelSchedulerHelper.h"

@implementation TravelView

#pragma mark - TravelView lifecycle

- (instancetype)initWithFrame:(CGRect)frame startPlace:(Place *)start endPlace:(Place *)end
{
    self = [super initWithFrame:frame];
    self.commute = (end.commuteTo) ? end.commuteTo : start.commuteFrom;
    self.dashedLine = [CAShapeLayer layer];
    [self.layer addSublayer:self.dashedLine];
    NSString *timeTravelString = [NSString stringWithFormat:@"%@ + 10 min buffer", self.commute.durationString];
    self.timeTravelLabel = makeTimeRangeLabel(timeTravelString, 13);
    [self addSubview:self.timeTravelLabel];
    return self;
}

- (void)layoutSubviews {
    int xCoord = CGRectGetWidth(self.frame) / 4;
    self.dashedLine = makeDashedLine(CGRectGetHeight(self.frame), xCoord, self.dashedLine);
    self.timeTravelLabel.frame = CGRectMake(xCoord + 20, 0, CGRectGetWidth(self.frame) - xCoord - 25, CGRectGetHeight(self.frame));
    [self.timeTravelLabel sizeToFit];
    self.timeTravelLabel.frame = CGRectMake(xCoord + 20, (CGRectGetHeight(self.frame) / 2) - (CGRectGetHeight(self.timeTravelLabel.frame) / 2), CGRectGetWidth(self.frame) - xCoord - 25, CGRectGetHeight(self.timeTravelLabel.frame));
}

@end
