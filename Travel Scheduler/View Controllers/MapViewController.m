//
//  MapViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/31/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MapViewController.h"
#import "Place.h"
@import GoogleMaps;

@interface MapViewController ()

@property (strong, nonatomic) GMSMapView *mapView;
@property(strong, nonatomic) NSArray *placesFromSchedule;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadView];
    [self creatingTripPath];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.mapView addGestureRecognizer:longPress];
}



- (void)didLongPress:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
        //    }
        //
        //    // Converts point where user did a long press to map coordinates
        //    CGPoint point = [sender locationInView:self.mapView];
        //    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        //
        //    // Create a basic point annotation and add it to the map
        //    MGLPointAnnotation *annotation = [MGLPointAnnotation alloc];
        //    annotation.coordinate = coordinate;
        //    annotation.title = @"Start navigation";
        //    [self.mapView addAnnotation:annotation];
        //
        //    // Calculate the route from the user's location to the set destination
        //    [self calculateRoutefromOrigin:self.mapView.userLocation.coordinate
        //                     toDestination:annotation.coordinate
        //                        completion:^(MBRoute * _Nullable route, NSError * _Nullable error) {
        //                            if (error != nil) {
        //                                NSLog(@"Error calculating route: %@", error);
        //                            }
        //                        }];
    }
}

- (void) loadView {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285 longitude:103.848 zoom:12];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = self.mapView;
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.indoorEnabled = NO;
    self.mapView.accessibilityElementsHidden = NO;
    self.mapView.myLocationEnabled = YES;
    NSLog(@"USer's location: %@", self.mapView.myLocation);
}


- (void) addingPlaceMarkers: (Place *) place withColor: (UIColor *)color {
    //CLLocation *myLocation = [[CLLocation alloc]  initWithLatitude:your_latitiude_value longitude:your_longitude_value];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([place.coordinates[@"latitude"] floatValue], [place.coordinates[@"longitude"] floatValue]);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.title = place.name;
    marker.map = self.mapView;
    marker.icon = [GMSMarker markerImageWithColor:color];
    marker.opacity = 0.6;
}

- (void) removingPlaceMarker : (GMSMarker *) marker {
    marker.map = nil;
    //[mapView clear];
}

- (void) creatingTripPath{
    GMSMutablePath *path = [GMSMutablePath path];
//    for (Place *place: self.placesFromSchedule){
//
//    }
    [path addCoordinate:CLLocationCoordinate2DMake(-33.85, 151.20)];
    [path addCoordinate:CLLocationCoordinate2DMake(-33.70, 151.40)];
    [path addCoordinate:CLLocationCoordinate2DMake(-33.73, 151.41)];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    
    //GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
    polyline.map = self.mapView;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
