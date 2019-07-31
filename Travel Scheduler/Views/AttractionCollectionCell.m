//
//  AttractionCollectionCell.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "AttractionCollectionCell.h"
#import "APIManager.h"
#import "TravelSchedulerHelper.h"
#import "Date.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - UI initiation

static void instantiateImageView(UIImageView *imageView, Place *place)
{
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [imageView setImageWithURL:place.photoURL];
    [imageView.layer setBorderColor: [[UIColor yellowColor] CGColor]];
}


static void makeSelected(UIButton *checkmark, Place *place)
{
    if (place.selected) {
        [checkmark setBackgroundImage:[UIImage imageNamed:@"checkmarkImage"] forState: UIControlStateNormal];
        checkmark.layer.borderColor = [[UIColor whiteColor] CGColor];
    }
}

static void instantiateImageViewTitle(UILabel *titleLabel, Place *place)
{
    [titleLabel setFont: [UIFont fontWithName:@"Arial-BoldMT" size:15]];
    titleLabel.text = place.name;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 2;
    titleLabel.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    titleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    titleLabel.layer.shadowRadius = 3.0;
    titleLabel.layer.shadowOpacity = 1;
    titleLabel.layer.masksToBounds = NO;
    [titleLabel sizeToFit];
    titleLabel.layer.shouldRasterize = YES;
}

@implementation AttractionCollectionCell

#pragma mark - AttractionCollectionCell lifecycle

- (void)setImage
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    instantiateImageView(self.imageView, self.place);
    [self.contentView addSubview:self.imageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.contentView.bounds.size.width - 10,20)];
    instantiateImageViewTitle(self.titleLabel, self.place);
    [self.imageView addSubview:self.titleLabel];
    
    self.checkmark = [UIButton buttonWithType:UIButtonTypeCustom];
    self.checkmark.backgroundColor = [UIColor whiteColor];
    [self.checkmark addTarget:self action:@selector(doDoubleTap) forControlEvents:UIControlEventTouchUpInside];
    [self.checkmark.layer setBorderColor:[[UIColor blueColor] CGColor]];
    [self.checkmark.layer setBorderWidth:1];
    [self.contentView addSubview:self.checkmark];
    
    [self instantiateGestureRecognizers];
    makeSelected(self.checkmark, self.place);
//    if (self.place.selected) {
//        [self.checkmark setBackgroundImage:[UIImage imageNamed:@"checkmarkImage"] forState: UIControlStateNormal];
//    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0,0,self.contentView.bounds.size.width,self.contentView.bounds.size.height);
    self.titleLabel.frame = CGRectMake(5, CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(self.titleLabel.frame), CGRectGetWidth(self.contentView.frame) - 10, CGRectGetHeight(self.titleLabel.frame));
    self.checkmark.frame = CGRectMake(self.contentView.bounds.size.width - 25, 5, 20, 20);
    self.checkmark.layer.cornerRadius = self.checkmark.frame.size.width / 2;
    self.checkmark.clipsToBounds = YES;
}

- (void)adjustUILabelFrame
{
    CGRect frame = self.titleLabel.frame;
    frame.origin.y = self.contentView.bounds.size.height - self.titleLabel.frame.size.height - 20;
    frame.origin.x = 7;
    self.titleLabel.frame= frame;
}

#pragma mark - tap action segue to details

- (void)didTapImage:(UITapGestureRecognizer *)sender
{
    [self.delegate attractionCell:self didTap:self.place];
}

#pragma mark - AttractionCollectionCell helper methods

- (void)instantiateGestureRecognizers
{
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImage:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doDoubleTap)];
    setupGRonImagewithTaps(profileTapGestureRecognizer, self.imageView, 1);
    setupGRonImagewithTaps(doubleTap, self.imageView, 2);
    [profileTapGestureRecognizer requireGestureRecognizerToFail:doubleTap];
}

- (void)doDoubleTap
{
    [self.setSelectedDelegate updateSelectedPlacesArrayWithPlace:self.place];
    makeSelected(self.checkmark, self.place);
//    if (self.place.selected) {
//        [self.checkmark setBackgroundImage:[UIImage imageNamed:@"checkmarkImage"] forState: UIControlStateNormal];
//    }
}

@end
