//
//  DetailsViewController.h
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) int headerHeight;

@end

NS_ASSUME_NONNULL_END
