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

#pragma mark - Label helpers

UILabel* makeLabel(int xCoord, int yCoord, NSString *text, CGRect frame, UIFont *font) {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xCoord, yCoord, CGRectGetWidth(frame) - 100 - 5, 35)];
    label.text = text;
    [label setNumberOfLines:0];
    [label setFont:font];
    [label sizeToFit];
    label.alpha = 1;
    return label;
}

NSString* getFormattedTimeRange(Place *place) {
    int startHour = (int)place.arrivalTime;
    int startMin = (int)((place.arrivalTime - startHour) * 60);
    NSString *startMinString = formatMinutes(startMin);
        NSString *startUnit = @"am";
    if (startHour > 12) {
        startHour -= 12;
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

void reformatOverlaps(UILabel *name, UILabel *times, int height) {
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
}

@implementation PlaceView

#pragma mark - PlaceView lifecycle

- (instancetype)initWithFrame:(CGRect)frame andPlace:(Place *)place {
    self = [super initWithFrame:frame];
    self.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.25];
    _place = place;
    [self makeImage];
    [self makeLabels];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapView:)];
    setupGRonImagewithTaps(tapGestureRecognizer, self, 1);
    return self;
}

#pragma mark - tap action segue to details

- (void)didTapView:(UITapGestureRecognizer *)sender{
    [self.delegate placeView:self didTap:self.place];
}

#pragma mark - PlaceView helper methods

- (void)makeLabels {
    int xCoord = self.placeImage.frame.origin.x + CGRectGetWidth(self.placeImage.frame) + 10;
    int midYCoord = self.placeImage.frame.origin.y + (CGRectGetHeight(self.placeImage.frame) / 2);
    self.placeName = makeLabel(xCoord, 10, self.place.name, self.frame, [UIFont systemFontOfSize:20]);
    NSString *times = getFormattedTimeRange(self.place);
    self.timeRange = makeLabel(xCoord, self.placeName.frame.origin.y + CGRectGetHeight(self.placeName.frame), times, self.frame, [UIFont systemFontOfSize:15 weight:UIFontWeightThin]);
    self.timeRange.textColor = [UIColor darkGrayColor];
    reformatOverlaps(self.placeName, self.timeRange, CGRectGetHeight(self.frame));
    [self addSubview:self.placeName];
    [self addSubview:self.timeRange];
}

- (void)makeImage {
    self.placeImage = [[UIImageView alloc] init];
    //self.placeImage.image = place.firstPhoto;
    //TESTING
    self.placeImage.backgroundColor = [UIColor grayColor];
    //int diameter = getMin(CGRectGetHeight(self.frame) - 10, 100 - 10);
    int diameter = 45;
    if (diameter > CGRectGetHeight(self.frame) - 10) {
        return;
    }
    self.placeImage.frame = CGRectMake(5, 5, diameter, diameter);
    self.placeImage.layer.cornerRadius = self.placeImage.frame.size.width / 2;
    self.placeImage.clipsToBounds = YES;
    [self addSubview:self.placeImage];
}

@end
