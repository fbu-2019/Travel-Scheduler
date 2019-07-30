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

@protocol DetailsViewControllerSetSelectedProtocol;

@interface DetailsViewController : UIViewController

@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) int headerHeight;
@property (strong, nonatomic) NSMutableArray *arrayOfComments;
@property (weak, nonatomic) id<DetailsViewControllerSetSelectedProtocol> setSelectedDelegate;
@end

@protocol DetailsViewControllerSetSelectedProtocol
- (void)updateSelectedPlacesArrayWithPlace:(Place *)place;
@end

NS_ASSUME_NONNULL_END
