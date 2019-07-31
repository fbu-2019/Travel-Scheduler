//
//  FirstScreenViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import <GIFProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

@interface FirstScreenViewController : UIViewController

@property (strong, nonatomic) NSString *placeTypedByUser;
@property (strong, nonatomic) UITextField *beginTripDateTextField;
@property (strong, nonatomic) UITextField *endTripDateTextField;
@property (strong, nonatomic) UIDatePicker *beginTripDatePicker;
@property (strong, nonatomic) UIDatePicker *endTripDatePicker;
@property (strong, nonatomic) Place *hub;
@property (strong, nonatomic) NSMutableArray *selectedPlacesArray;
@property (strong, nonatomic) UISearchBar *placesSearchBar;
@property (strong, nonatomic) NSDateFormatter *dateFormat;
@property (strong, nonatomic) NSString *firstDateString;
@property (strong, nonatomic) NSString *userSpecifiedPlaceToVisit;
@property (strong, nonatomic) NSDate *userSpecifiedStartDate;
@property (strong, nonatomic) NSDate *userSpecifiedEndDate;
@property (strong, nonatomic) UILabel *searchLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property(strong, nonatomic) NSMutableArray *resultsArr;
@property(strong, nonatomic) UITableView *autocompleteTableView;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) GIFProgressHUD *hud;
@property (strong, nonatomic) UIImageView *topIconImageView;
@property (strong, nonatomic) UIBezierPath *path;
@property (nonatomic) bool isHudInitated;
@property (nonatomic) bool hasLoadedHub;

@end

NS_ASSUME_NONNULL_END
