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
#import <MapKit/MapKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface CommuteDetailsViewController : UIViewController 

@property (strong, nonatomic) Commute *commute;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) MKMapView *commuteMapView;
@property (strong, nonatomic) UIView *viewForMap;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *cellHeights;
@property (nonatomic) float commuteHeaderHeight;
@property(strong, nonatomic) NSString *apiUrl;
@property(strong, nonatomic) UITapGestureRecognizer *tappedMap;
@property(strong, nonatomic) UILabel *textOnMap;

@end

NS_ASSUME_NONNULL_END
