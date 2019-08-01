//
//  ScheduleViewController.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceView.h"
#import "TravelSchedulerHelper.h"
#import "Schedule.h"

@class Schedule;

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleViewController : UIViewController

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) UILabel *header;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *dates;
@property (strong, nonatomic) NSMutableArray *allDates;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) PlaceView *currSelectedView;
@property (strong, nonatomic) Place *nextLockedPlace;
@property (strong, nonatomic) NSDate *removeLockedDate;
@property (nonatomic) TimeBlock *removeLockedTime;
@property (strong, nonatomic) NSMutableArray *selectedPlacesArray;
@property (strong, nonatomic) NSDictionary *scheduleDictionary;
@property (strong, nonatomic) NSArray *dayPath;
@property (strong, nonatomic) Place *home;
@property (strong, nonatomic) Place *hub;
@property (strong, nonatomic) NSMutableDictionary *lockedDatePlaces;
@property (strong, nonatomic) Schedule *scheduleMaker;
@property (strong, nonatomic) NSDate *scheduleEndDate;
@property (nonatomic) BOOL regenerateEntireSchedule;
@property (strong, nonatomic) Place *errorPlace;
@property (strong, nonatomic) NSDate *errorDate;
@property (nonatomic) TimeBlock errorTime;
    
- (void)scheduleViewSetup;
- (void)setUpAllData;

@end

NS_ASSUME_NONNULL_END
