//
//  MoveCircleView.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/25/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MoveCircleView.h"
#import "PlaceView.h"

@implementation MoveCircleView

- (instancetype)initWithView:(PlaceView *)view top:(BOOL)top
{
    self = [super init];
    self.view = view;
    self.top = top;
    [self makeView];
    [self makePanGesture];
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect frame = CGRectInset(self.bounds, -50, -50);
    return CGRectContainsPoint(frame, point) ? self : nil;
}

- (void)makePanGesture {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:panRecognizer];
}

-(void)move:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.superview];
    self.frame = CGRectMake(self.frame.origin.x, point.y, 10, 10);
    [self.view moveWithPan:point edge:self.top];
}

- (void)makeView {
    int yCoord;
    int xCoord;
    if (self.top) {
        yCoord = -5;
        xCoord = CGRectGetWidth(self.view.frame) - 50;
    } else {
        yCoord = CGRectGetHeight(self.view.frame) - 5;
        xCoord = 50;
    }
    self.frame = CGRectMake(xCoord, yCoord, 12, 12);
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.clipsToBounds = YES;
}

@end
