//
//  TravelStepCell.m
//  Travel Scheduler
//
//  Created by aliu18 on 8/2/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "TravelStepCell.h"
#import "Place.h"
#import "Step.h"

static NSString *makeTimeString(float timeInSeconds)
{
    float timeinMin = timeInSeconds / 60;
    if (timeinMin < 60) {
        return ((int)(timeinMin + 0.5) == 1) ? @"1 min" : [NSString stringWithFormat:@"%.f mins", timeinMin];
    } else {
        return ((int)(timeinMin / 60 + 0.5) == 1) ? @"1 hr" : [NSString stringWithFormat:@"%.01f hrs", timeinMin / 60];
    }
}

@implementation TravelStepCell

- (instancetype)initWithPlace:(Place *)place
{
    self = [super init];
    [self setTravelPlace:place];
    return self;
}

- (instancetype)initWithStep:(Step *)step
{
    self = [super init];
    [self setTravelStep:step];
    return self;
}

- (void)setTravelStep:(Step *)step
{
    [self createAllProperties];
    float distance = [step.distance floatValue] / 1000;
    NSString *timeString = makeTimeString([step.durationInSeconds floatValue]);
    self.subLabel.text = [NSString stringWithFormat:@"About %@", timeString];
    if (step.vehicle) {
        self.iconImage.image = [UIImage imageNamed:@"busIcon"];
        NSString *titleString = [NSString stringWithFormat:@"%@", step.vehicle];
        NSString *busName = [step.line valueForKey:@"name"];
        if (busName) {
            titleString = [NSString stringWithFormat:@"%@ %@", busName, titleString];
        }
        NSString *busNumString = [step.line valueForKey:@"short_name"];
        if (busNumString) {
            titleString = [NSString stringWithFormat:@"%@ %@", titleString, busNumString];
        }
        NSString *busInfoString;
        if (step.numberOfStops) {
            busInfoString = [NSString stringWithFormat:@"%@ stops", step.numberOfStops];
        }
        if (step.arrivalStop && step.departureStop) {
            busInfoString = [NSString stringWithFormat:@"%@:\r    %@\r        |\r    %@", busInfoString, step.departureStop, step.arrivalStop];
        }
        if (busInfoString) {
            self.busInfoLabel = makeSubHeaderLabel(busInfoString, 16);
            self.busInfoLabel.textColor = [UIColor darkGrayColor];
            [self.contentView addSubview:self.busInfoLabel];
        }
        self.title.text = titleString;
    } else {
        self.iconImage.image = [UIImage imageNamed:@"walkingIcon"];
        NSString *titleString = [NSString stringWithFormat:@"Walk %.02f km", distance];
        self.title.text = titleString;
    }
}

- (void)setTravelPlace:(Place *)place
{
    [self createAllProperties];
    self.title.text = place.name;
    self.subLabel.text = place.address;
    self.iconImage.image = [UIImage imageNamed:@"locationIcon"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.title.frame = CGRectMake(60, 13, CGRectGetWidth(self.frame) - 70, CGRectGetHeight(self.frame));
    [self.title sizeToFit];
    if (self.busInfoLabel) {
        self.busInfoLabel.frame = CGRectMake(70, CGRectGetMaxY(self.title.frame) + 7, CGRectGetWidth(self.frame) - 80, CGRectGetHeight(self.frame));
        [self.busInfoLabel sizeToFit];
        self.subLabel.frame = CGRectMake(70, CGRectGetMaxY(self.busInfoLabel.frame) + 7, CGRectGetWidth(self.frame) - 80, CGRectGetHeight(self.frame));
    } else {
        self.subLabel.frame = CGRectMake(70, CGRectGetMaxY(self.title.frame) + 5, CGRectGetWidth(self.frame) - 80, CGRectGetHeight(self.frame));
    }
    [self.subLabel sizeToFit];
    self.iconImage.frame = CGRectMake(5, 10, 50, 50);
    self.iconImage.layer.cornerRadius = self.iconImage.frame.size.width / 2;
    self.iconImage.clipsToBounds = YES;
}

- (void)createAllProperties
{
    if (self.title) {
        [self.title removeFromSuperview];
    }
    self.title = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.title setFont:[UIFont fontWithName:@"Gotham-Light" size:18]];
    self.title.numberOfLines = 0;
    [self.contentView addSubview:self.title];
    
    if (self.subLabel) {
        [self.subLabel removeFromSuperview];
    }
    self.subLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.subLabel setFont:[UIFont fontWithName:@"Gotham-XLight" size:15]];
    self.subLabel.numberOfLines = 0;
    self.subLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.subLabel];
    
    if (self.iconImage) {
        [self.iconImage removeFromSuperview];
    }
    self.iconImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.iconImage.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImage.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:self.iconImage];
}

@end
