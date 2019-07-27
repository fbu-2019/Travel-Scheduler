//
//  PlaceView.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/23/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PlaceView.h"
#import "Place.h"
#import "TravelSchedulerHelper.h"
#import "Date.h"
#import "UIImageView+AFNetworking.h"
#import "MoveCircleView.h"

#pragma mark - Label helpers

NSString* getFormattedTimeRange(Place *place) {
    int startHour = (int)place.arrivalTime;
    int startMin = (int)((place.arrivalTime - startHour) * 60);
    NSString *startMinString = formatMinutes(startMin);
    NSString *startUnit = @"am";
    if (startHour > 12) {
        startHour -= 12;
        startUnit = @"pm";
    }
    if (startHour == 12) {
        startUnit = @"pm";
    }
    int endHour = (int)place.departureTime;
    int endMin = (int)((place.departureTime - endHour) * 60);
    NSString *endMinString = formatMinutes(endMin);
    NSString *endUnit = @"pm";
    if (endHour > 12) {
        endHour -= 12;
        endUnit = @"pm";
    }
    NSString *string = [NSString stringWithFormat:@"%d:%@%@ - %d:%@%@", startHour, startMinString, startUnit, endHour, endMinString, endUnit];
    return string;
}

void reformatOverlaps(UILabel *name, UILabel *times, CGRect cellFrame) {
    int height = CGRectGetHeight(cellFrame);
    int nameFrameWidth = CGRectGetWidth(name.frame);
    int totalHeight = times.frame.origin.y + CGRectGetHeight(times.frame);
    if (totalHeight > height) {
        name.frame = CGRectMake(name.frame.origin.x, name.frame.origin.y, CGRectGetWidth(name.frame), 0);
        [name setNumberOfLines:1];
        [name sizeToFit];
        name.frame = CGRectMake(name.frame.origin.x, name.frame.origin.y, nameFrameWidth, CGRectGetHeight(name.frame));
        times.frame = CGRectMake(times.frame.origin.x, name.frame.origin.y + CGRectGetHeight(name.frame) + 5, CGRectGetWidth(times.frame), CGRectGetHeight(times.frame));
    }
    totalHeight = times.frame.origin.y + CGRectGetHeight(times.frame);
    if (totalHeight > height) {
        times.alpha = 0;
    }
    if (name.frame.origin.y + CGRectGetHeight(name.frame) > height) {
        name.frame = cellFrame;
        name.numberOfLines = 1;
        name.minimumFontSize = 8;
        name.adjustsFontSizeToFitWidth = YES;
    }
}

@implementation PlaceView

#pragma mark - PlaceView lifecycle

- (instancetype)initWithFrame:(CGRect)frame andPlace:(Place *)place {
    self = [super initWithFrame:frame];
    if (place.scheduledTimeBlock % 2 == 0) {
        self.color = [UIColor orangeColor];
    } else {
        self.color = [UIColor blueColor];
    }
    if (place.locked) {
        self.layer.borderWidth = 2;
        [self.layer setBorderColor: [[UIColor redColor] CGColor]];
    }
    self.backgroundColor = [self.color colorWithAlphaComponent:0.25];
    _place = place;
    if (45 < CGRectGetHeight(self.frame) - 10) {
        self.placeImage = makeImage(self.place.iconUrl);
        [self addSubview:self.placeImage];
    }
    [self makeLabels];
    [self makeEditButton];
    [self createGestureRecognizers];
    return self;
}

#pragma mark - PlaceView helper methods

- (void)makeLabels {
    int xCoord = self.placeImage.frame.origin.x + CGRectGetWidth(self.placeImage.frame) + 10;
    int midYCoord = self.placeImage.frame.origin.y + (CGRectGetHeight(self.placeImage.frame) / 2);
    self.placeName = makeLabel(xCoord, 10, self.place.name, self.frame, [UIFont systemFontOfSize:20]);
    NSString *times = getFormattedTimeRange(self.place);
    self.timeRange = makeLabel(xCoord, self.placeName.frame.origin.y + CGRectGetHeight(self.placeName.frame), times, self.frame, [UIFont systemFontOfSize:15 weight:UIFontWeightThin]);
    self.timeRange.textColor = [UIColor darkGrayColor];
    reformatOverlaps(self.placeName, self.timeRange, self.frame);
    [self addSubview:self.placeName];
    [self addSubview:self.timeRange];
}

- (void)makeEditButton {
    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 60, 5, 60, 25)];
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.editButton];
}

- (void)createGestureRecognizers
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapView:)];
    setupGRonImagewithTaps(tapGestureRecognizer, self, 1);
    UILongPressGestureRecognizer *pressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    pressGestureRecognizer.minimumPressDuration = 1.0;
    pressGestureRecognizer.delegate = self;
    [self addGestureRecognizer:pressGestureRecognizer];
    [tapGestureRecognizer requireGestureRecognizerToFail:pressGestureRecognizer];
}

#pragma mark - Edit button segue

- (void)editView {
    [self.delegate tappedEditPlace:self.place forView:self];
}

#pragma mark - Action: tap segue to details view

- (void)didTapView:(UITapGestureRecognizer *)sender
{
    [self.delegate placeView:self didTap:self.place];
}

#pragma mark - Action: long press to allow edit

- (void)longPress:(UITapGestureRecognizer *)sender
{
    if (self.delegate.currSelectedView == self) {
        return;
    }
    if (self.delegate.currSelectedView) {
        [self.delegate.currSelectedView unselect];
    }
    self.backgroundColor = [self.color colorWithAlphaComponent:0.5];
    self.placeName.textColor = [UIColor whiteColor];
    self.timeRange.textColor = [UIColor whiteColor];
    self.delegate.currSelectedView = self;
    self.topCircle = [[MoveCircleView alloc] initWithView:self top:YES];
    self.bottomCircle = [[MoveCircleView alloc] initWithView:self top:NO];
    [self addSubview:self.topCircle];
    [self addSubview:self.bottomCircle];
}

- (void)unselect {
    self.backgroundColor = [self.color colorWithAlphaComponent:0.25];
    self.placeName.textColor = [UIColor blackColor];
    self.timeRange.textColor = [UIColor grayColor];
    [self.topCircle removeFromSuperview];
    [self.bottomCircle removeFromSuperview];
}

- (void)moveWithPan:(CGPoint)point edge:(BOOL)top
{
    //    int originalTopY = self.frame.origin.y;
    //    int originalBottomY = originalTopY + CGRectGetHeight(self.frame);
    //    if (top) {
    //        self.frame = CGRectMake(self.frame.origin.x, point.y, CGRectGetWidth(self.frame), originalBottomY - point.y);
    //    } else {
    //        self.frame = CGRectMake(self.frame.origin.x, originalTopY, CGRectGetWidth(self.frame), point.y - originalTopY);
    //    }
    float topMidY = self.topCircle.frame.origin.y - (CGRectGetHeight(self.topCircle.frame) / 2);
    float height = topMidY - (self.bottomCircle.frame.origin.y + (CGRectGetHeight(self.topCircle.frame) / 2));
    self.frame = CGRectMake(self.frame.origin.x, topMidY, CGRectGetWidth(self.frame), height);
    
    
}

@end
