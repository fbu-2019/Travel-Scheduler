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

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

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
    self.arrayWithoutDuplicates = [[NSMutableArray alloc] init];
    [self createHomeAnnotation];
    int count = 0;
    for(Place *place in self.placesFromSchedule){
        if (! [place.name isEqualToString:self.homeFromSchedule.name]){
            [self.arrayWithoutDuplicates addObject:place];
        }
    }
    [self createPathFromHomeToPlace];
    for (int k = 0; k < [self.arrayWithoutDuplicates count]; k++){
        Place *place = self.arrayWithoutDuplicates[k];
        [self addingPlaceMarkers:place withColor:[UIColor redColor] withInt:k];
    }
    [self createPathFromHomeToPlace];
    self.view = _mainMapView;
    [_mainMapView setDelegate:self];
    self.buttonToNavigation = makeScheduleButton(@"Click For Trip Navigation");
    self.buttonToNavigation.alpha = 1.0;
    [self.buttonToNavigation addTarget:self action:@selector(navigation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonToNavigation];
    [self showRouteFrom:self.arrayOfAnnotations[0] to:self.arrayOfAnnotations[1]];
}

#pragma  mark - Creating a Home Annotation

- (void)createHomeAnnotation{
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([self.homeFromSchedule.coordinates[@"lat"] floatValue], [self.homeFromSchedule.coordinates[@"lng"] floatValue]);
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
    [marker setCoordinate:position];
    [marker setTitle: [NSString stringWithFormat:@"%i. %@", 1,self.homeFromSchedule.name]];
    [_mainMapView addAnnotation:marker];
    [self.arrayOfAnnotations addObject:marker];
}

#pragma mark - Creating start and end paths

- (void) createPathFromHomeToPlace
{
    Place *pos1 = self.homeFromSchedule;
    Place *pos2 = self.arrayWithoutDuplicates[0];
    [self gettingRouteFromApple:pos1 andSeconPlace:pos2];
}

- (void) createPathFromLastPlaceToHome
{
    Place *pos1 = self.arrayWithoutDuplicates[[_arrayWithoutDuplicates count] - 1];
    NSLog(@"%@", pos1.name);
    Place *pos2 = self.homeFromSchedule;
    [self gettingRouteFromApple:pos1 andSeconPlace:pos2];
    
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

- (void)addingPlaceMarkers:(Place *)place withColor:(UIColor *)color withInt:(int)annotationCount
{
    NSLog(@"@%i", annotationCount);
    NSLog(@"@%lu", [self.arrayWithoutDuplicates count]);
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([place.coordinates[@"lat"] floatValue], [place.coordinates[@"lng"] floatValue]);
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
    [marker setCoordinate:position];
    [marker setTitle: [NSString stringWithFormat:@"%i. %@",annotationCount + 2, place.name]];
    [_mainMapView addAnnotation:marker];
    [self.arrayOfAnnotations addObject:marker];
    [self setMapViewRange];
    int updateAnnotationCount = annotationCount;
    
    if (updateAnnotationCount == [self.arrayWithoutDuplicates count]){
        
    }
    
    if(updateAnnotationCount + 1 < [self.arrayWithoutDuplicates count]){
        Place *pos1 = self.arrayWithoutDuplicates[updateAnnotationCount];
        Place *pos2 = self.arrayWithoutDuplicates[updateAnnotationCount + 1];
        [self gettingRouteFromApple:pos1 andSeconPlace:pos2];
    }
}

#pragma mark - Call for route

- (void)gettingRouteFromApple:(Place *)pos1 andSeconPlace:(Place *)pos2
{
    CLLocationCoordinate2D coord1 = CLLocationCoordinate2DMake([pos1.coordinates[@"lat"] floatValue], [pos1.coordinates[@"lng"] floatValue]);
    CLLocationCoordinate2D coord2 = CLLocationCoordinate2DMake([pos2.coordinates[@"lat"] floatValue], [pos2.coordinates[@"lng"] floatValue]);
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:coord1];
    MKMapItem *sourceMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:coord2];
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

#pragma mark - setting the map view

- (void)setMapViewRange{
    Place *place1 = self.arrayWithoutDuplicates[0];
    Place *place2 = self.arrayWithoutDuplicates[[self.arrayWithoutDuplicates count]-1];
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake([place1.coordinates[@"lat"] floatValue], [place1.coordinates[@"lng"] floatValue]);
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake([place2.coordinates[@"lat"] floatValue], [place2.coordinates[@"lng"] floatValue]);
    MKMapPoint p1 = MKMapPointForCoordinate (coordinate1);
    MKMapPoint p2 = MKMapPointForCoordinate (coordinate2);
    MKMapRect mapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y));
    [_mainMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f) animated:YES];
    [_mainMapView showAnnotations:self.arrayOfAnnotations animated:YES];
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
    self.apiUrlStr = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,&daddr=%@&dirflg=d", saddr, daddr];
    return _placesFromSchedule;
}

#pragma mark - Showing route path

- (void)showRouteFrom:(MKPointAnnotation*)f to:(MKPointAnnotation*)t
{
    [self.mainMapView addAnnotation:f];
    [self.mainMapView addAnnotation:t];
    
    routes = [self calculateRoutesFrom:f.coordinate to:t.coordinate];
}

@end
