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
#import "CalendarEvent.h"

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

UIImageView *instantiateLockImageView(UILabel *lateralLabel)
{
    int sideSize = lateralLabel.frame.size.height;
    int xCoord = lateralLabel.frame.origin.x + lateralLabel.frame.size.width + 10;
    int yCoord = lateralLabel.frame.origin.y;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xCoord, yCoord, sideSize, sideSize)];
    UIImage *lockImage = [UIImage imageNamed:@"lockIcon"];
    imageView.image = lockImage;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    return imageView;
}

@implementation PlaceView

#pragma mark - PlaceView lifecycle

- (instancetype)initWithFrame:(CGRect)frame andPlace:(Place *)place
{
    self = [super initWithFrame:frame];
    self.place = place;
    [self updateGradientWithAlpha:0.8];
    self.layer.shadowOffset = CGSizeMake(1, 0);
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = .25;
    self.clipsToBounds = false;
    self.layer.masksToBounds = false;
    [self makeLabels];
    [self makeEditButton];
    [self makeCalendarButton];
    if (place.locked) {
        self.lockImage.hidden = NO;
    }
    [self createGestureRecognizers];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    int xCoord = 10;
    self.placeName.frame = CGRectMake(xCoord, 10, CGRectGetWidth(self.frame) - xCoord - 65, 35);
    [self.placeName sizeToFit];
    self.timeRange.frame = CGRectMake(xCoord, CGRectGetMaxY(self.placeName.frame) + 5, CGRectGetWidth(self.frame) - 2 * xCoord, 35);
    [self.timeRange sizeToFit];
    reformatOverlaps(self.placeName, self.timeRange, self.frame);
    self.editButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 45, 7, 25, 25);
    self.lockImage.frame = CGRectMake(self.timeRange.frame.origin.x + self.timeRange.frame.size.width + 10, self.timeRange.frame.origin.y, self.timeRange.frame.size.height, self.timeRange.frame.size.height);
    self.calendarButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 303, CGRectGetHeight(self.frame) - 30, 300, 25);
}

#pragma mark - PlaceView helper methods

- (void)makeLabels
{
    self.placeName = makeSubHeaderLabel(self.place.name, 19);
    self.placeName.textColor = [UIColor whiteColor];
    NSString *times = getFormattedTimeRange(self.place);
    self.timeRange = makeTimeRangeLabel(times, 15);
    self.timeRange.textColor = [UIColor whiteColor];
    [self addSubview:self.placeName];
    [self addSubview:self.timeRange];
}

- (void)makeEditButton
{
    self.editButton = [[UIButton alloc] initWithFrame:CGRectZero];
    UIImage *pencilImage = [UIImage imageNamed:@"pencil"];
    [self.editButton setImage:pencilImage forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.editButton];
}

- (void)makeCalendarButton
{
    self.calendarButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.calendarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    if (self.place.calendarEvent) {
        [self.calendarButton setTitle:@"Remove" forState:UIControlStateNormal];
    } else {
        [self.calendarButton setTitle:@"Add to calendar" forState:UIControlStateNormal];
    }
    self.calendarButton.titleLabel.font = [UIFont fontWithName:@"Gotham-XLight" size:13];
    [self.calendarButton addTarget:self action:@selector(changeCalendarStatus) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.calendarButton];
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

- (void)updateGradientWithAlpha:(float)alpha {
    if(self.colorGradient != nil) {
        [self.colorGradient removeFromSuperlayer];
    }
    self.colorGradient = [CAGradientLayer layer];
    self.colorGradient.frame = self.bounds;
    if(self.place.scheduledTimeBlock % 2 == 0) {
        self.colorGradient.colors = @[(id)[getColorFromIndex(CustomColorExodusFruit) colorWithAlphaComponent:alpha].CGColor, (id)[getColorFromIndex(CustomColorShyMoment) colorWithAlphaComponent:alpha].CGColor];
    } else {
        self.colorGradient.colors = @[(id)[getColorFromIndex(CustomColorRegularPink) colorWithAlphaComponent:alpha].CGColor, (id)[getColorFromIndex(CustomColorLightPink)colorWithAlphaComponent:alpha].CGColor];
    }
    [self.layer insertSublayer:self.colorGradient atIndex:0];
}

#pragma mark - Edit button segue

- (void)editView
{
    [self.delegate tappedEditPlace:self.place forView:self];
}

#pragma mark - Add place to calendar

- (void)changeCalendarStatus
{
    if (self.delegate.currSelectedView == self) {
        return;
    }
    if (self.delegate.currSelectedView) {
        [self.delegate.currSelectedView unselect];
    } else {
        if (self.place.calendarEvent) {
            [self.place.calendarEvent removeFromCalendar];
            [self.calendarButton setTitle:@"Add to calendar" forState:UIControlStateNormal];
            self.calendarButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 303, CGRectGetHeight(self.frame) - 30, 300, 25);
            self.calendarButton.titleLabel.frame = self.calendarButton.frame;
            [self layoutIfNeeded];
            self.place.calendarEvent = nil;
        } else {
            [[CalendarEvent alloc] initWithPlace:self.place requestStatus:NO];
            [self.calendarButton setTitle:@"Remove" forState:UIControlStateNormal];
            self.calendarButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 303, CGRectGetHeight(self.frame) - 30, 300, 25);
            self.calendarButton.titleLabel.frame = self.calendarButton.frame;
            [self layoutIfNeeded];
        }
    }
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
    [self updateGradientWithAlpha:1];
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
        [self.travelPathTo removeFromSuperview];
    } else {
        self.frame = CGRectMake(self.frame.origin.x, originalTopY, CGRectGetWidth(self.frame), changeInY);
        [self.travelPathFrom removeFromSuperview];
    }
    [self.topCircle updateFrame];
    [self.bottomCircle updateFrame];
    [self updateGradientWithAlpha:1];
    [self updatePlaceAndLabel];
    [self.delegate sendViewForward:self];
}

#pragma mark - View changing actions

- (void)unselect
{
    self.placeName.textColor = [UIColor whiteColor];
    self.timeRange.textColor = [UIColor whiteColor];
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
