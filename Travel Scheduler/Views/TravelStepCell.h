//
//  TravelStepCell.h
//  Travel Scheduler
//
//  Created by aliu18 on 8/2/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Place;
@class Step;

NS_ASSUME_NONNULL_BEGIN

@interface TravelStepCell : UITableViewCell

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *subLabel;
@property (strong, nonatomic) UIImageView *iconImage;

- (instancetype)initWithPlace:(Place *)place;
- (instancetype)initWithStep:(Step *)step;

@end

NS_ASSUME_NONNULL_END
