//
//  HomeCollectionViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeCollectionViewController : UIViewController

@property (strong, nonatomic) NSString *hubPlaceName;
@property (strong, nonatomic) Place *hub;
@property (strong, nonatomic) UITableView *homeTable;
@property (strong, nonatomic) UITableViewCell *placesToVisitCell;
@property (strong, nonatomic) NSArray *arrayOfTypes;
@property (nonatomic, strong) NSMutableDictionary *dictionaryOfLocationsArray;
@property (nonatomic, strong) NSArray *colorArray;
@property (strong, nonatomic) UIButton *scheduleButton;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSString *curTableViewCategory;
@property (nonatomic, strong) NSMutableArray *selectedPlacesArray;
@end

NS_ASSUME_NONNULL_END
