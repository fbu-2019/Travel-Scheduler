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

NSString *getFormattedTimeRange(Place *place)
{
    int startHour = (int)place.arrivalTime;
    int startMin = (int)((place.arrivalTime - startHour) * 60);
    NSString *startMinString = formatMinutes(startMin);
    NSString *startUnit = @" AM";
    if (startHour > 12) {
        startHour -= 12;
        startUnit = @" PM";
    }
    if (startHour == 12) {
        startUnit = @" PM";
    }
    int endHour = (int)place.departureTime;
    int endMin = (int)((place.departureTime - endHour) * 60);
    NSString *endMinString = formatMinutes(endMin);
    NSString *endUnit = @" AM";
    if (endHour > 12) {
        endHour -= 12;
        endUnit = @" PM";
    }
    NSString *string = [NSString stringWithFormat:@"%d:%@%@ - %d:%@%@", startHour, startMinString, startUnit, endHour, endMinString, endUnit];
    return string;
}

void reformatOverlaps(UILabel *name, UILabel *times, CGRect cellFrame)
{
    int height = CGRectGetHeight(cellFrame);
    int nameFrameWidth = CGRectGetWidth(cellFrame) - name.frame.origin.x - 60;
    int totalHeight = times.frame.origin.y + CGRectGetHeight(times.frame);
    if (totalHeight > height) {
        name.frame = CGRectMake(name.frame.origin.x, name.frame.origin.y, nameFrameWidth, 0);
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

- (instancetype)initWithFrame:(CGRect)frame andPlace:(Place *)place
{
    self = [super initWithFrame:frame];
    self.color = (place.scheduledTimeBlock % 2 == 0) ? [UIColor orangeColor] : [UIColor blueColor];
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

- (instancetype)initWithPlace:(Place *)place
{
    self = [super init];
    self.place = place;
    self.color = (place.scheduledTimeBlock % 2 == 0) ? [UIColor orangeColor] : [UIColor blueColor];
    if (place.locked) {
        self.layer.borderWidth = 2;
        [self.layer setBorderColor: [[UIColor redColor] CGColor]];
    }
    self.backgroundColor = [self.color colorWithAlphaComponent:0.25];
    if (45 < CGRectGetHeight(self.frame) - 10) {
        self.placeImage = makeImage(self.place.iconUrl);
        [self addSubview:self.placeImage];
    }
    [self makeLabels];
    [self makeEditButton];
    [self createGestureRecognizers];
    return self;
}


- (void)layoutSubviews {
    self.placeImage.frame = CGRectMake(5, 5, 45, 45);
    int xCoord = CGRectGetMaxX(self.placeImage.frame) + 10;
    self.placeName.frame = CGRectMake(xCoord, 10, CGRectGetWidth(self.frame) - xCoord - 65, 35);
    [self.placeName sizeToFit];
    self.timeRange.frame = CGRectMake(xCoord, CGRectGetMaxY(self.placeName.frame) + 5, CGRectGetWidth(self.frame) - 2 * xCoord, 35);
    [self.timeRange sizeToFit];
    reformatOverlaps(self.placeName, self.timeRange, self.frame);
    self.editButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 60, 5, 60, 25);
}

#pragma mark - PlaceView helper methods

- (void)makeLabels
{
    self.placeName = makeSubHeaderLabel(self.place.name, 19);
    self.placeName.textColor = [UIColor blackColor];
    NSString *times = getFormattedTimeRange(self.place);
    self.timeRange = makeTimeRangeLabel(times, 15);
    [self addSubview:self.placeName];
    [self addSubview:self.timeRange];
}

- (void)makeEditButton
{
    self.editButton = [[UIButton alloc] initWithFrame:CGRectZero];
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

- (void)editView
{
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
    [self.delegate sendViewForward:self];
}

#pragma mark - Action: change view size with pan press

- (void)moveWithPan:(float)changeInY edge:(BOOL)top
{
    int originalTopY = self.frame.origin.y;
    int originalBottomY = originalTopY + CGRectGetHeight(self.frame);
    if (top) {
        self.frame = CGRectMake(self.frame.origin.x, originalTopY + changeInY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - changeInY);
    } else {
        self.frame = CGRectMake(self.frame.origin.x, originalTopY, CGRectGetWidth(self.frame), changeInY);
    }
    [self.topCircle updateFrame];
    [self.bottomCircle updateFrame];
    [self updatePlaceAndLabel];
    [self.delegate sendViewForward:self];
}

#pragma mark - View changing actions

- (void)unselect
{
    self.backgroundColor = [self.color colorWithAlphaComponent:0.25];
    self.placeName.textColor = [UIColor blackColor];
    self.timeRange.textColor = [UIColor grayColor];
    [self.topCircle removeFromSuperview];
    [self.bottomCircle removeFromSuperview];
}

- (void)updatePlaceAndLabel
{
    self.place.arrivalTime = ((self.frame.origin.y - 45) / 100.0) + 8;
    self.place.departureTime = self.place.arrivalTime + (CGRectGetHeight(self.frame) / 100.0);
    [self.placeName removeFromSuperview];
    [self.timeRange removeFromSuperview];
    [self makeLabels];
}

@end
