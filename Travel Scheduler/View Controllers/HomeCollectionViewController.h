//
//  HomeCollectionViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "SlideMenuUIView.h"
#import "PopUpViewLateral.h"
#import "PopUpViewVertical.h"
#import "Place.h"
#import <GIFProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HomeViewControllerDelegate;

@interface HomeCollectionViewController : UIViewController

@property (strong, nonatomic) NSString *hubPlaceName;
@property (strong, nonatomic) Place *hub;
@property (strong, nonatomic) UITableView *homeTable;
@property (strong, nonatomic) UITableViewCell *placesToVisitCell;
@property (strong, nonatomic) NSArray *arrayOfTypes;
@property (strong, nonatomic) UIButton *scheduleButton;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *arrayOfSelectedPlaces;
@property (strong, nonatomic) NSMutableArray *arrayOfSelectedPlacesCurrentlyOnSchedule;
@property (nonatomic) int numberOfTravelDays;
@property (nonatomic) int numOfSelectedRestaurants;
@property (nonatomic) int numOfSelectedAttractions;
@property (strong, nonatomic) Place *home;
@property (strong, nonatomic) UIView *backgroundView;
@property (nonatomic, strong) UIButton *buttonToMenu;
@property (nonatomic, strong) SlideMenuUIView *leftViewToSlideIn;
@property (nonatomic, strong) UIButton *closeLeft;
@property (nonatomic) bool menuViewShow;
@property (nonatomic) bool hasFirstSchedule;
@property (nonatomic) bool isScheduleUpToDate;
@property (nonatomic, strong) PopUpViewLateral *errorPopUpViewLateral;
@property (nonatomic, strong) PopUpViewVertical *errorPopUpViewVertical;
@property (strong, nonatomic) GIFProgressHUD *hud;
@property (weak, nonatomic)id<HomeViewControllerDelegate>delegate;
@property (strong, nonatomic)UIImageView *alertImageView;
@end

@protocol HomeViewControllerDelegate
- (void)removeAllEvents;
@end

NS_ASSUME_NONNULL_END
