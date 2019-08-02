//
//  CommuteDetailsViewController.h
//  Travel Scheduler
//
//  Created by aliu18 on 8/2/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commute.h"
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommuteDetailsViewController : UIViewController

@property (strong, nonatomic) Commute *commute;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UILabel *totalTimeLabel;
@property (strong, nonatomic) UILabel *totalCostLabel;

@end

NS_ASSUME_NONNULL_END
