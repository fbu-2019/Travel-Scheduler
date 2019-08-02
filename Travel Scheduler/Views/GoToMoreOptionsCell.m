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
    imageView.layer.cornerRadius = 5;
    imageView.clipsToBounds = YES;
    [imageView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    imageView.image = [UIImage imageNamed:@"2103641-512 (1)"];
}

static void instantiateTitle(UILabel *titleLabel)
{
    [titleLabel setFont: [UIFont fontWithName:@"Gotham-Bold" size:17]];
    titleLabel.text = @"MORE";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.layer.shouldRasterize = YES;
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
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,10,self.contentView.bounds.size.width ,self.contentView.frame.size.height/5)];
    instantiateTitle(self.titleLabel);
    [self.contentView addSubview:self.titleLabel];
    
    
    instantiateImageView(self.imageView);
    self.imageView.frame = CGRectMake(self.contentView.frame.size.width/4,self.titleLabel.frame.origin.y  + self.titleLabel.frame.size.height + 10,self.contentView.bounds.size.width/2,self.contentView.bounds.size.height/2);
    [self.contentView addSubview:self.imageView];
    [self instantiateGestureRecognizers];
}


#pragma mark - General helper methods

-(void)setShading
{
    UIColor *pinkColor = [UIColor colorWithRed:0.93 green:0.30 blue:0.40 alpha:1];
    
    self.layer.shadowOffset = CGSizeMake(1, 0);
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = .5;
    self.clipsToBounds = false;
    self.layer.masksToBounds = false;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
    self.layer.borderWidth = 2;
    self.layer.masksToBounds = false;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)pinkColor.CGColor, (id)[UIColor lightGrayColor].CGColor];
    [self.layer insertSublayer:gradient atIndex:0];
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
