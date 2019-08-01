//
//  MapViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/31/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleViewController.h"
@import GooglePlacePicker;
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController
//@property(strong, nonatomic) NSMutableArray *shedulePlaceArray;
@property (strong, nonatomic) GMSMapView *mapView;
@property(strong, nonatomic) NSArray *placesFromSchedule;
@property(strong, nonatomic) CLLocationManager *locationManager;

@end

NS_ASSUME_NONNULL_END
