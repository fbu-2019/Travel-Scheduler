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

#pragma mark - MoveCircleView lifeCycle

- (instancetype)initWithView:(PlaceView *)view top:(BOOL)top
{
    self = [super init];
    self.view = view;
    self.top = top;
    [self makeView];
    [self makePanGesture];
    return self;
}

#pragma mark - Pan Gesture Recognizer methods

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect frame = CGRectMake(-30, -30, 75, 75);
    return CGRectContainsPoint(frame, point) ? self : nil;
}

-(void)move:(UIPanGestureRecognizer *)sender
{
    [self.view bringSubviewToFront:sender.view];
    CGPoint translatedPoint = [sender translationInView:sender.view.superview];
    CGFloat firstY;
    if (sender.state == UIGestureRecognizerStateBegan) {
        firstY = sender.view.center.y;
    }
    translatedPoint = CGPointMake(sender.view.center.x, sender.view.center.y+translatedPoint.y);
    [sender.view setCenter:translatedPoint];
    [sender setTranslation:CGPointZero inView:sender.view];
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat velocityY = (0.2*[sender velocityInView:self.view].y);
        CGFloat finalY = sender.view.center.y;
        if (!self.top && finalY < 50) {
            finalY = 50;
        }
        if (self.top && finalY > CGRectGetHeight(self.view.frame) - 50) {
            finalY = CGRectGetHeight(self.view.frame) - 50;
        }
        [self makeAnimation:velocityY];
        CGPoint finalPoint = CGPointMake(self.frame.origin.x + (CGRectGetWidth(self.frame) / 2), finalY);
        [[sender view] setCenter:finalPoint];
        [UIView commitAnimations];
        float changeInY = finalY - firstY;
        [self.view moveWithPan:changeInY edge:self.top];
    }
}

#pragma mark - MoveCircleView helper methods

- (void)makePanGesture
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self addGestureRecognizer:panRecognizer];
}

- (void)makeAnimation:(CGFloat)velocityY {
    CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
}

- (void)makeView
{
    [self updateFrame];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.clipsToBounds = YES;
}

- (void)updateFrame
{
    int yCoord;
    int xCoord;
    if (self.top) {
        yCoord = -5;
        xCoord = CGRectGetWidth(self.view.frame) - 50;
    } else {
        yCoord = CGRectGetHeight(self.view.frame) - 5;
        xCoord = 50;
    }
    self.frame = CGRectMake(xCoord, yCoord, 15, 15);
}

@end
