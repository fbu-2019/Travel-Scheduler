//
//  MapViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/31/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MapViewController.h"
#import "Place.h"
#import <CoreLocation/CoreLocation.h>
#import "TravelSchedulerHelper.h"

@interface MapViewController () <CLLocationManagerDelegate>

- (NSArray*)calculateRoutesFrom:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to;

@end

@implementation MapViewController

#pragma mark - View Controller LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Trip Overview";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor darkGrayColor],
       NSFontAttributeName:[UIFont fontWithName:@"Gotham-Light" size:21]}];
    [self loadMapView];
    self.arrayOfAnnotations = [[NSMutableArray alloc] init];
    for (Place *place in self.placesFromSchedule){
        [self addingPlaceMarkers:place withColor: [UIColor redColor]];
        NSLog(@"%@", place.name);
    }
    self.view = _mainMapView;
    [_mainMapView setDelegate:self];
    self.buttonToNavigation = makeScheduleButton(@"Click For Trip Navigation");
    self.buttonToNavigation.alpha = 1.0;
    [self.buttonToNavigation addTarget:self action:@selector(navigation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonToNavigation];
    
    for  (int i = 0; i < [self.arrayOfAnnotations count] - 1; i++){
        [self showRouteFrom:self.arrayOfAnnotations[i] to:self.arrayOfAnnotations[i+1]];
    }
}

#pragma mark - View contoller Subviews

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.buttonToNavigation.frame = CGRectMake(25, CGRectGetHeight(self.view.frame) - self.bottomLayoutGuide.length - 60, CGRectGetWidth(self.view.frame) - 2 * 25, 50);
}

#pragma mark - Setting Navigation

- (void)navigation
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.apiUrlStr] options:@{} completionHandler:^(BOOL success) {}];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.apiUrlStr]];
    }
}

#pragma mark - creating map

- (void)loadMapView
{
    Place *centerLocation = self.placesFromSchedule[0];
    CLLocationCoordinate2D coordForPin = {.latitude = [centerLocation.coordinates[@"lat"] floatValue], .longitude = [centerLocation.coordinates[@"lng"] floatValue]};
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordForPin];
    [annotation setTitle:@"Pin Here"];
    [_mainMapView addAnnotation:annotation];
    _mainMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    MKCoordinateSpan span = {.latitudeDelta = 4.0f, .longitudeDelta = 4.0f};
    MKCoordinateRegion region = {coordForPin, span};
    [_mainMapView setRegion:region];
}

#pragma mark - Making place annotations

- (void)addingPlaceMarkers:(Place *)place withColor:(UIColor *)color
{
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([place.coordinates[@"lat"] floatValue], [place.coordinates[@"lng"] floatValue]);
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
    [marker setCoordinate:position];
    [marker setTitle:place.name];
    [_mainMapView addAnnotation:marker];
    [self.arrayOfAnnotations addObject:marker];
    Place *place1 = self.placesFromSchedule[0];
    Place *place2 = self.placesFromSchedule[[self.placesFromSchedule count]-1];
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake([place1.coordinates[@"lat"] floatValue], [place1.coordinates[@"lng"] floatValue]);
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake([place2.coordinates[@"lat"] floatValue], [place2.coordinates[@"lng"] floatValue]);
    MKMapPoint p1 = MKMapPointForCoordinate (coordinate1);
    MKMapPoint p2 = MKMapPointForCoordinate (coordinate2);
    MKMapRect mapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y));
    [_mainMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f) animated:YES];
    [_mainMapView showAnnotations:self.arrayOfAnnotations animated:YES];
    for  (int i = 0; i < [self.arrayOfAnnotations count] - 1; i++){
        MKPointAnnotation *place1 = self.arrayOfAnnotations[i];
        MKPointAnnotation *place2 = self.arrayOfAnnotations[i+1];
        CLLocationCoordinate2D coordinate1 = place1.coordinate;
        CLLocationCoordinate2D coordinate2 = place2.coordinate;
        MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:coordinate1];
        MKMapItem *sourceMapItem = [[MKMapItem alloc]initWithPlacemark:source];
        MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:coordinate2];
        MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
        [request setSource:sourceMapItem];
        [request setDestination:distMapItem];
        [request setTransportType:MKDirectionsTransportTypeAutomobile];
        MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
        [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (!error) {
                [self.mainMapView addOverlay:[response.routes[0] polyline] level:MKOverlayLevelAboveRoads];
            }
        }];
    }
}

#pragma mark - Setting Polylines delegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:3.0];
        return renderer;
    }
    return nil;
}

#pragma mark - Drawing route

- (void)drawRoute:(NSArray *)path
{
    NSInteger numberOfSteps = path.count;
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        Place *placeLocation = [path objectAtIndex:index];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([placeLocation.coordinates[@"lat"] floatValue], [placeLocation.coordinates[@"lng"] floatValue]);
        coordinates[index] = coordinate;
    }
}

#pragma mark - Accessing user location

- (void)startUserLocationSearch
{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Getting user location

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self.locationManager stopUpdatingLocation];
    CGFloat usersLatitude = self.locationManager.location.coordinate.latitude;
    CGFloat usersLongidute = self.locationManager.location.coordinate.longitude;
    CLLocationCoordinate2D coordForPin = {.latitude = usersLatitude, .longitude = usersLongidute};
    MKPointAnnotation *annotationForCurrentLocation = [[MKPointAnnotation alloc] init];
    [annotationForCurrentLocation setCoordinate:coordForPin];
    [annotationForCurrentLocation setTitle:@"Current location"];
    [_mainMapView addAnnotation:annotationForCurrentLocation];
    _mainMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Calculating route path

- (NSArray*)calculateRoutesFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    self.apiUrlStr = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,&daddr=%@", saddr, daddr];
    return _placesFromSchedule;
}

#pragma mark - Showing route path

- (void)showRouteFrom:(MKPointAnnotation*)f to:(MKPointAnnotation*)t
{
    [self.mainMapView addAnnotation:f];
    [self.mainMapView addAnnotation:t];
    
    routes = [self calculateRoutesFrom:f.coordinate to:t.coordinate];
    NSInteger numberOfSteps = routes.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++)
    {
        Place *place = self.placesFromSchedule[index];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([place.coordinates[@"lat"] floatValue], [place.coordinates[@"lng"] floatValue]);
        coordinates[index] = coordinate;
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
}

@end
