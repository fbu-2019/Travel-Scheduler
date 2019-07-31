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


static void makeSelected(UIImageView *imageView, Place *place)
{
    (place.selected) ? [imageView.layer setBorderWidth: 5] : [imageView.layer setBorderWidth: 0];
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
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.contentView.bounds.size.width,self.contentView.bounds.size.height)];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.contentView.bounds.size.width - 14,20)];
    [self adjustUILabelFrame];
    instantiateImageView(self.imageView, self.place);
    instantiateImageViewTitle(self.titleLabel, self.place);
    [self.imageView addSubview:self.titleLabel];
    [self instantiateGestureRecognizers];
    [self.contentView addSubview:self.imageView];
    makeSelected(self.imageView, self.place);
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
    makeSelected(self.imageView, self.place);
}

@end
