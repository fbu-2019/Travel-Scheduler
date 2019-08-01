//
//  MapViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/31/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property(strong, nonatomic) NSArray *placesFromSchedule;

@end

NS_ASSUME_NONNULL_END
