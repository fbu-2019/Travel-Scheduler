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
    self.nextEvent = end.placeView;
    self.prevEvent = start.placeView;
    self.commute = (end.commuteTo) ? end.commuteTo : start.commuteFrom;
    self.dashedLine = [CAShapeLayer layer];
    [self.layer addSublayer:self.dashedLine];
    
    NSString *timeTravelString;
    if(self.commute.durationString != nil) {
    timeTravelString = [NSString stringWithFormat:@"%@ + 10 min buffer >", self.commute.durationString];
    } else {
    timeTravelString = @"10 min buffer >";
    }
    self.timeTravelLabel = makeTimeRangeLabel(timeTravelString, 13);
    [self addSubview:self.timeTravelLabel];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapView:)];
    setupGRonImagewithTaps(tapGestureRecognizer, self, 1);
    return self;
}

- (void)layoutSubviews {
    int xCoord = CGRectGetWidth(self.frame) / 4;
    self.dashedLine = makeDashedLine(CGRectGetHeight(self.frame), xCoord - 10, self.dashedLine);
    self.timeTravelLabel.frame = CGRectMake(xCoord + 20, 0, CGRectGetWidth(self.frame) - xCoord - 25, CGRectGetHeight(self.frame));
    [self.timeTravelLabel sizeToFit];
    self.timeTravelLabel.frame = CGRectMake(xCoord + 5, (CGRectGetHeight(self.frame) / 2) - (CGRectGetHeight(self.timeTravelLabel.frame) / 2), CGRectGetWidth(self.frame) - xCoord - 25, CGRectGetHeight(self.timeTravelLabel.frame));
}

- (void)didTapView:(UITapGestureRecognizer *)sender
{
    [self.delegate travelView:self didTap:self.commute];
}

@end
