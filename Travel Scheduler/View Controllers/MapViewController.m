//
//  MapViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/31/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MapViewController.h"
#import "Place.h"
#import "ScheduleViewController.h"
@import GooglePlacePicker;
@import GoogleMaps;

@interface MapViewController () <GMSPlacePickerViewControllerDelegate>



@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadView];
    [self creatingTripPath];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.mapView addGestureRecognizer:longPress];
    
    [self.locationManager requestAlwaysAuthorization];
    
    
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter = 500; // meters
    [self.locationManager startUpdatingLocation];
    
    for (Place *place in self.placesFromSchedule){
        [self addingPlaceMarkers:place withColor: [UIColor redColor]];
    }
    
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
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([place.coordinates[@"lat"] floatValue], [place.coordinates[@"lng"] floatValue]);
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
    for (Place *place in self.placesFromSchedule){
        [path addCoordinate:CLLocationCoordinate2DMake([place.coordinates[@"lat"] floatValue], [place.coordinates[@"lng"] floatValue])];
    }
//    [path addCoordinate:CLLocationCoordinate2DMake(-33.85, 151.20)];
//    [path addCoordinate:CLLocationCoordinate2DMake(-33.70, 151.40)];
//    [path addCoordinate:CLLocationCoordinate2DMake(-33.73, 151.41)];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    
    //GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 10.f;
    polyline.geodesic = YES;
    polyline.map = self.mapView;
    
    //GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    GMSStrokeStyle *solidRed = [GMSStrokeStyle solidColor:[UIColor redColor]];
    GMSStrokeStyle *redYellow =
    [GMSStrokeStyle gradientFromColor:[UIColor redColor] toColor:[UIColor yellowColor]];
    polyline.spans = @[[GMSStyleSpan spanWithStyle:solidRed],
                       [GMSStyleSpan spanWithStyle:solidRed],
                       [GMSStyleSpan spanWithStyle:redYellow]];
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // Update your marker on your map using location.coordinate.latitude
        //and location.coordinate.longitude);
        GMSMarker *marker = [GMSMarker markerWithPosition: location.coordinate];
        marker.map = self.mapView;
        marker.icon = [GMSMarker markerImageWithColor: [UIColor blueColor]];
        marker.opacity = 0.6;
    }
}

//- (void)pickPlace:(UIButton *)sender {
//    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
//    GMSPlacePickerViewController *placePicker =
//    [[GMSPlacePickerViewController alloc] initWithConfig:config];
//    placePicker.delegate = self;
//    [self presentViewController:placePicker animated:YES completion:nil];
//}
//
//
//- (void)placePicker:(GMSPlacePickerViewController *)viewController didPickPlace:(GMSPlace *)place {
//    [viewController dismissViewControllerAnimated:YES completion:nil];
//    NSLog(@"Place name %@", place.name);
//    NSLog(@"Place address %@", place.formattedAddress);
//    NSLog(@"Place attributions %@", place.attributions.string);
//}
//
//- (void)placePickerDidCancel:(GMSPlacePickerViewController *)viewController {
//    [viewController dismissViewControllerAnimated:YES completion:nil];
//    NSLog(@"No place selected");
//}

//GMSPlaceField fields = (GMSPlaceFieldName | GMSPlaceFieldPlaceID);
//[_placesClient findPlaceLikelihoodsFromCurrentLocationWithPlaceFields:fields callback:^(NSArray<GMSPlaceLikelihood *> * _Nullable likelihoods, NSError * _Nullable error) {
//    if (error != nil) {
//        NSLog(@"An error occurred %@", [error localizedDescription]);
//        return;
//    }
//    if (likelihoods != nil) {
//        for (GMSPlaceLikelihood *likelihood in likelihoods) {
//            GMSPlace *place = likelihood.place;
//            NSLog(@"Current place name: %@", place.name);
//            NSLog(@"Place ID: %@", place.placeID);
//        }
//    }
//}];


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
