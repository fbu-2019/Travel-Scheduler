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
    return (timeinMin < 60) ? [NSString stringWithFormat:@"%.f mins", timeinMin] : [NSString stringWithFormat:@"%.01f hrs", timeinMin / 60];
}

@implementation TravelStepCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithPlace:(Place *)place
{
    self = [super init];
    [self createAllProperties];
    self.title.text = place.name;
    self.subLabel.text = place.address;
    return self;
}

- (instancetype)initWithStep:(Step *)step
{
    self = [super init];
    [self createAllProperties];
    float distance = [step.distance floatValue] / 1000;
    NSString *timeString = makeTimeString([step.durationInSeconds floatValue]);
    self.subLabel.text = [NSString stringWithFormat:@"About %@", timeString];
    if (step.vehicle) {
        NSString *titleString = [NSString stringWithFormat:@"%@", step.vehicle];
        if (step.numberOfStops) {
            titleString = [NSString stringWithFormat:@"%@ - %@ stops", titleString, step.numberOfStops];
        }
        if (step.directionToGo) {
            titleString = [NSString stringWithFormat:@"%@ toward %@", titleString, step.directionToGo];
        }
        self.title.text = titleString;
    } else {
        NSString *titleString = [NSString stringWithFormat:@"Walk %.02f km", distance];
        self.title.text = titleString;
    }
    return self;
}

- (void)setTravelStep:(Step *)step
{
    [self createAllProperties];
    float distance = [step.distance floatValue] / 1000;
    NSString *timeString = makeTimeString([step.durationInSeconds floatValue]);
    self.subLabel.text = [NSString stringWithFormat:@"About %@", timeString];
    if (step.vehicle) {
        NSString *titleString = [NSString stringWithFormat:@"%@", step.vehicle];
        if (step.numberOfStops) {
            titleString = [NSString stringWithFormat:@"%@ - %@ stops", titleString, step.numberOfStops];
        }
        if (step.directionToGo) {
            titleString = [NSString stringWithFormat:@"%@ toward %@", titleString, step.directionToGo];
        }
        self.title.text = titleString;
    } else {
        NSString *titleString = [NSString stringWithFormat:@"Walk %.02f km", distance];
        self.title.text = titleString;
    }
}

- (void)setTravelPlace:(Place *)place
{
    [self createAllProperties];
    self.title.text = place.name;
    self.subLabel.text = place.address;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.title.frame = CGRectMake(60, 13, CGRectGetWidth(self.frame) - 70, CGRectGetHeight(self.frame));
    [self.title sizeToFit];
    self.subLabel.frame = CGRectMake(70, CGRectGetMaxY(self.title.frame) + 5, CGRectGetWidth(self.frame) - 80, CGRectGetHeight(self.frame));
    [self.subLabel sizeToFit];
    self.iconImage.frame = CGRectMake(5, 10, 50, 50);
    self.iconImage.layer.cornerRadius = self.iconImage.frame.size.width / 2;
    self.iconImage.clipsToBounds = YES;
}

- (void)createAllProperties
{
    self.title = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.title setFont:[UIFont fontWithName:@"Gotham-Light" size:18]];
    self.title.numberOfLines = 0;
    [self.contentView addSubview:self.title];
    
    self.subLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.subLabel setFont:[UIFont fontWithName:@"Gotham-XLight" size:15]];
    self.subLabel.numberOfLines = 0;
    self.subLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.subLabel];
    
    self.iconImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.iconImage.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImage.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:self.iconImage];
}

@end
