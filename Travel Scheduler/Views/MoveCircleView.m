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

-(void)move:(UIPanGestureRecognizer *)sender
{
//    CGPoint point = [pan locationInView:self.superview];
//    self.frame = CGRectMake(self.frame.origin.x, point.y, 10, 10);
//    [self.view moveWithPan:point edge:self.top];
    
    [self.view bringSubviewToFront:sender.view];
    CGPoint translatedPoint = [sender translationInView:sender.view.superview];
    
    CGFloat firstY;
    if (sender.state == UIGestureRecognizerStateBegan) {
        firstY = sender.view.center.y;
    }
    
    
    translatedPoint = CGPointMake(sender.view.center.x+translatedPoint.x, sender.view.center.y+translatedPoint.y);
    
    [sender.view setCenter:translatedPoint];
    [sender setTranslation:CGPointZero inView:sender.view];
    
    
    
    //[self.view moveWithPan:translatedPoint edge:self.top];
    
    
    
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGFloat velocityY = (0.2*[sender velocityInView:self.view].y);
        
        CGFloat finalY = translatedPoint.y; //+ velocityY;// translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
        
        /*if (finalY < 50) { // to avoid status bar
            finalY = 50;
        } else if (finalY > self.view.frame.size.height) {
            finalY = self.view.frame.size.height;
        }*/
        
        CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
        
        //NSLog(@"the duration is: %f", animationDuration);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidFinish)];
        [[sender view] setCenter:CGPointMake(self.frame.origin.x + (CGRectGetWidth(self.frame) / 2), finalY)];
        [UIView commitAnimations];
    }
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
    self.frame = CGRectMake(xCoord, yCoord, 15, 15);
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = self.frame.size.width / 2;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.clipsToBounds = YES;
}

@end
