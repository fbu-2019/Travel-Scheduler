//
//  DetailHeaderCell.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailHeaderCell : UITableViewCell

@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) NSString *placeName;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UILabel *placeNameLabel;
@property (strong, nonatomic) UIButton *goingButton;
@property (strong, nonatomic) Place *place;
@property (nonatomic) int width;

- (instancetype)initWithWidth:(int)width andPlace:(Place *)givenPlace;
@end

NS_ASSUME_NONNULL_END
