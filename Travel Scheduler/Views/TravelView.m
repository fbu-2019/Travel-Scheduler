//
//  TravelView.m
//  Travel Scheduler
//
//  Created by aliu18 on 8/1/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "TravelView.h"
#import "Place.h"

@implementation TravelView

- (instancetype)initWithFrame:(CGRect)frame startPlace:(Place *)start endPlace:(Place *)end
{
    self = [super initWithFrame:frame];
    self.startPlace = start;
    self.endPlace = end;
    
    //FOR TESTING ONLY
    self.backgroundColor = [UIColor yellowColor];
    
    self.dashedLine = [CAShapeLayer layer];
    [self.layer addSublayer:self.dashedLine];
    return self;
}

- (void)layoutSubviews {
    self.dashedLine = makeDashedLine(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame) / 4, self.dashedLine);
}

@end
