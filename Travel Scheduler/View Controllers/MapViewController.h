//
//  MapViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/31/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RegexKitLite.h"
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
    NSArray* routes;
    BOOL isUpdatingRoutes;
}

@property(strong, nonatomic) NSArray *placesFromSchedule;
@property (strong, nonatomic) MKMapView *mainMapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *arrayOfAnnotations;
@property (strong, nonatomic) UIButton *buttonToNavigation;
@property (strong, nonatomic) NSString *apiUrlStr;
@property (strong, nonatomic) NSArray *annotationMarkers;
@property(strong, nonatomic) Place *homeFromSchedule;
@property(strong, nonatomic) NSMutableArray *arrayWithoutDuplicates;

- (void) showRouteFrom:(MKPointAnnotation *)f to:(MKPointAnnotation *)t;

@end

NS_ASSUME_NONNULL_END
