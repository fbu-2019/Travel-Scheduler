//
//  GoToMoreOptionsCell.m
//  Travel Scheduler
//
//  Created by gilemos on 8/2/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "GoToMoreOptionsCell.h"
#import "TravelSchedulerHelper.h"

#pragma mark - Views Initialization

static void instantiateImageView(UIImageView *imageView)
{
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = 30;
    imageView.clipsToBounds = YES;
    [imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    imageView.image = [UIImage imageNamed:@"iconfinder_104_Direction_Board_Camping_Sign_label_camping_camp_4172884"];
    imageView.alpha = 0.5;
}

@implementation GoToMoreOptionsCell

#pragma mark - Initialization methods

- (void)initWithType:(NSString *)type
{
    [self setShading];
    self.placeTypeString = type;
    if(self.imageView == nil) {
    self.imageView = [[UIImageView alloc] init];
    }
    instantiateImageView(self.imageView);
    [self.contentView addSubview:self.imageView];
    [self instantiateGestureRecognizers];
}
    
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0,0,self.contentView.bounds.size.width,self.contentView.bounds.size.height);
}

#pragma mark - General helper methods

-(void)setShading
{
    self.layer.shadowOffset = CGSizeMake(1, 0);
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = .50;
    self.clipsToBounds = false;
    self.layer.masksToBounds = false;
}
#pragma mark - Segue to more options view controller

- (void)instantiateGestureRecognizers
{
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapImage:)];
    setupGRonImagewithTaps(profileTapGestureRecognizer, self.imageView, 1);
}

- (void)didTapImage:(UITapGestureRecognizer *)sender
{
    [self.delegate goToMoreOptionsWithType:self.placeTypeString];
}

@end
