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

#pragma mark - UI initiation

static void instantiateImageView(UIImageView *imageView, Place *place) {
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    if (place) {
        imageView.image = place.firstPhoto;
    } else {
        imageView.image = [UIImage imageNamed:@"heart3"];
    }
    [imageView.layer setBorderColor: [[UIColor yellowColor] CGColor]];
}

static void makeSelected(UIImageView *imageView, Place *place) {
    if (place.selected) {
        [imageView.layer setBorderWidth: 5];
    } else {
        [imageView.layer setBorderWidth: 0];
    }
}

@implementation AttractionCollectionCell

#pragma mark - AttractionCollectionCell lifecycle

- (void)setImage:(Place *)place {
    self.imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.contentView.bounds.size.width,self.contentView.bounds.size.height)];
    instantiateImageView(self.imageView, place);
    [self instantiateGestureRecognizers];
    [self.contentView addSubview:self.imageView];
    makeSelected(self.imageView, self.place);
}

-(void)setPlaceForIndex:(NSIndexPath *)indexPath {
    
}
#pragma mark - tap action segue to details

- (void)didTapImage:(UITapGestureRecognizer *)sender{
    [self.delegate attractionCell:self didTap:self.place];
}

#pragma mark - AttractionCollectionCell helper methods
- (void)instantiateGestureRecognizers {
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImage:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doDoubleTap)];
    setupGRonImagewithTaps(profileTapGestureRecognizer, self.imageView, 1);
    setupGRonImagewithTaps(doubleTap, self.imageView, 2);
    [profileTapGestureRecognizer requireGestureRecognizerToFail:doubleTap];
}

- (void)doDoubleTap {
    if (self.place.selected) {
        //TODO: Remove Place from selected array
        self.place.selected = NO;
    } else {
        //TODO: Add Place to selected array
        self.place.selected = YES;
    }
    makeSelected(self.imageView, self.place);
}

@end
