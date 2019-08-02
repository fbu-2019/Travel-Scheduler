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


-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadMapView];
    
    self.arrayOfAnnotations = [[NSMutableArray alloc] init];
    for (Place *place in self.placesFromSchedule){
       [self addingPlaceMarkers:place withColor: [UIColor redColor]];
        NSLog(@"%@", place.name);
    }
    //[_mainMapView addAnnotations:self.annotationMarkers];
    self.view = _mainMapView;
    [_mainMapView setDelegate:self];
    [self drawRoute:self.placesFromSchedule];
    
    
    self.buttonToNavigation = makeScheduleButton(@"Click For Trip Navigation");
    self.buttonToNavigation.alpha = 1.0;
    [self.buttonToNavigation addTarget:self action:@selector(navigation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonToNavigation];
    
    int i;
    for  (i = 0; i < [self.arrayOfAnnotations count] - 1; i++){
        [self showRouteFrom:self.arrayOfAnnotations[i] to:self.arrayOfAnnotations[i+1]];
    }
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.buttonToNavigation.frame = CGRectMake(25, CGRectGetHeight(self.view.frame) - self.bottomLayoutGuide.length - 60, CGRectGetWidth(self.view.frame) - 2 * 25, 50);
}

- (void)navigation
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.apiUrlStr] options:@{} completionHandler:^(BOOL success) {}];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.apiUrlStr]];
    }
}

- (void)loadMapView
{
    Place *centerLocation = self.placesFromSchedule[0];
    //   }
    CLLocationCoordinate2D coordForPin = {.latitude = [centerLocation.coordinates[@"lat"] floatValue], .longitude = [centerLocation.coordinates[@"lng"] floatValue]};
    //CLLocationCoordinate2D coordForPin = {.latitude = 49.894107, .longitude = -97.138545};
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordForPin];
    [annotation setTitle:@"Pin Here"];
    [_mainMapView addAnnotation:annotation];
    _mainMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
   // CLLocationCoordinate2D coord = {.latitude = [centerLocation.coordinates[@"lat"] floatValue], .longitude = [centerLocation.coordinates[@"lng"] floatValue]};
    //CLLocationCoordinate2D coord = {.latitude = 49.894107, .longitude = -97.138545};
    MKCoordinateSpan span = {.latitudeDelta = 4.0f, .longitudeDelta = 4.0f};
    MKCoordinateRegion region = {coordForPin, span};
    [_mainMapView setRegion:region];
}

- (void)addingPlaceMarkers: (Place *) place withColor: (UIColor *)color
{
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([place.coordinates[@"lat"] floatValue], [place.coordinates[@"lng"] floatValue]);
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
 
    
    [marker setCoordinate:position];
    [marker setTitle:place.name];
   // [self.arrayOfAnnotations addObject:<#(nonnull id)#>];
    //[_mainMapView addAnnotations:<#(nonnull NSArray<id<MKAnnotation>> *)#>:marker];
     [_mainMapView addAnnotation:marker];

    [self.arrayOfAnnotations addObject:marker];
    
    
    Place *place1 = self.placesFromSchedule[0];
    Place *place2 = self.placesFromSchedule[[self.placesFromSchedule count]];
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake([place1.coordinates[@"lat"] floatValue], [place1.coordinates[@"lng"] floatValue]);
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake([place2.coordinates[@"lat"] floatValue], [place2.coordinates[@"lng"] floatValue]);
    
    // convert them to MKMapPoint
    MKMapPoint p1 = MKMapPointForCoordinate (coordinate1);
    MKMapPoint p2 = MKMapPointForCoordinate (coordinate2);
    
    // and make a MKMapRect using mins and spans
    MKMapRect mapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y));

    [_mainMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f) animated:YES];
    [_mainMapView showAnnotations:self.arrayOfAnnotations animated:YES];
    

}

//-(void) animateAnnotation:(MyAnnotation*)annotation{
//    [UIView animateWithDuration:2.0f
//                     animations:^{
//                         annotation.coordinate = newCordinates;
//                     }
//                     completion:nil];
//}


- (void)drawRoute:(NSArray *) path
{
    NSInteger numberOfSteps = path.count;
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        Place *placeLocation = [path objectAtIndex:index];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([placeLocation.coordinates[@"lat"] floatValue], [placeLocation.coordinates[@"lng"] floatValue]);
        //CLLocationCoordinate2D coordinate = placeLocation.coordinates;
        coordinates[index] = coordinate;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    //[_mainMapView addOverlay:polyLine];
}

//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
//    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
//    polylineView.strokeColor = [UIColor redColor];
//    polylineView.lineWidth = 1.0;
//
//    return polylineView;
//}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor purpleColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
}



- (void)creatingTripPath
{
    
}

-(void)startUserLocationSearch{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //Remember your pList needs to be configured to include the location persmission - adding the display message  (NSLocationWhenInUseUsageDescription)
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];
    CGFloat usersLatitude = self.locationManager.location.coordinate.latitude;
    CGFloat usersLongidute = self.locationManager.location.coordinate.longitude;
    
    //Now you have your user's co-oridinates
    
    CLLocationCoordinate2D coordForPin = {.latitude = usersLatitude, .longitude = usersLongidute};
    //CLLocationCoordinate2D coordForPin = {.latitude = 49.894107, .longitude = -97.138545};
    MKPointAnnotation *annotationForCurrentLocation = [[MKPointAnnotation alloc] init];
    [annotationForCurrentLocation setCoordinate:coordForPin];
    [annotationForCurrentLocation setTitle:@"Current location"];
    [_mainMapView addAnnotation:annotationForCurrentLocation];
    _mainMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
}










//- (id) initWithFrame:(CGRect) frame
//{
//    self = [super initWithFrame:frame];
//    if (self != nil)
//    {
//        //mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        mapView.showsUserLocation = NO;
//        [mapView setDelegate:self];
//        [self addSubview:mapView];
//    }
//    return self;
//}

- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        //printf("[%f,", [latitude doubleValue]);
        //printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    //NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,&daddr=%@", saddr, daddr];
    //NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    self.apiUrlStr = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,&daddr=%@", saddr, daddr];
    //NSURL* apiUrl = [NSURL URLWithString:self.apiUrlStr];
    
    //NSLog(@"api url: %@", apiUrl);
    //NSError* error = nil;
    //NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
    //NSString *encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    
   // NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude, mapPoint.coordinate.latitude, mapPoint.coordinate.longitude];
//    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: apiUrlStr] options:@{} completionHandler:^(BOOL success) {}];
//    } else {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: apiUrlStr]];
//    }
    //return [self decodePolyLine:[encodedPoints mutableCopy]];
    return _placesFromSchedule;
}

-(void) centerMap
{
    MKCoordinateRegion region;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees minLon = 180.0;
   // Place *centerLocation = self.placesFromSchedule[0];
    //CLLocationCoordinate2D coordForPin = {.latitude = [centerLocation.coordinates[@"lat"] floatValue], .longitude = [centerLocation.coordinates[@"lng"] floatValue]};
    for(int idx = 0; idx < self.placesFromSchedule.count; idx++)
    {
        CLLocation* currentLocation = [routes objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    region.center.latitude     = (maxLat + minLat) / 2.0;
    region.center.longitude    = (maxLon + minLon) / 2.0;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    
    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
    [self.mainMapView setRegion:region animated:YES];
}

-(void) showRouteFrom: (MKPointAnnotation*) f to:(MKPointAnnotation*) t
{
    if(routes)
    {
        [self.mainMapView removeAnnotations:[self.mainMapView annotations]];
    }
    
    [self.mainMapView addAnnotation:f];
    [self.mainMapView addAnnotation:t];
    
    routes = [self calculateRoutesFrom:f.coordinate to:t.coordinate];
    NSInteger numberOfSteps = routes.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++)
    {
        //CLLocation *location = [self.arrayOfAnnotations objectAtIndex:index];
        Place *place = self.placesFromSchedule[index];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([place.coordinates[@"lat"] floatValue], [place.coordinates[@"lng"] floatValue]);
        //CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    //[self.mainMapView addOverlay:polyLine];
    //[self centerMap];
}

//#pragma mark MKPolyline delegate functions
//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
//{
//    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
//    polylineView.strokeColor = [UIColor purpleColor];
//    polylineView.lineWidth = 5.0;
//    return polylineView;
//}

@end


























/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//@end
