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
    if (place.selected) {
        [imageView.layer setBorderWidth: 5];
    } else {
        [imageView.layer setBorderWidth: 0];
    }
}

@implementation AttractionCollectionCell

#pragma mark - AttractionCollectionCell lifecycle

- (void)setImage
{
    self.imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.contentView.bounds.size.width,self.contentView.bounds.size.height)];
    instantiateImageView(self.imageView, self.place);
    if(self.place.photoURL == nil) {
        [self setPlaceholderImages];
    }
    [self instantiateGestureRecognizers];
    [self.contentView addSubview:self.imageView];
    makeSelected(self.imageView, self.place);
    if(self.selectedPlacesArray == nil) {
    self.selectedPlacesArray = [[NSMutableArray alloc] init];
    }
}

- (void)setPlaceholderImages
{
    if([self.place.specificType isEqualToString:@"hotel"]) {
        self.imageView.image = [UIImage imageNamed:@"iconfinder_traveling_icon_flat_outline-14_3405120"];
    } else if([self.place.specificType isEqualToString:@"restaurant"]) {
        self.imageView.image = [UIImage imageNamed:@"iconfinder_traveling_icon_flat_outline-10_3405123"];
    } else {
        self.imageView.image = [UIImage imageNamed:@"iconfinder_traveling_icon_flat_outline-08_3405109"];
    }
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
    if (self.place.selected) {
        self.place.selected = NO;
        [self.selectedPlacesArray removeObject:self.place];
    } else {
        self.place.selected = YES;
        [self.selectedPlacesArray addObject:self.place];
    }
    makeSelected(self.imageView, self.place);
}

@end
