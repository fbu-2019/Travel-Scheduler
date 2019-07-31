//
//  MapViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/29/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MapViewController.h"
@import MapboxCoreNavigation;
@import MapboxNavigation;
@import MapboxDirections;
@import Mapbox;

@interface MapViewController ()<MKMapViewDelegate, MGLMapViewDelegate>
@property (nonatomic) MBNavigationMapView *mapView;
@property (nonatomic) MBRoute *directionsRoute;

@end

@implementation MapViewController

#pragma mark - View Controller LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView = [[MBNavigationMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MGLUserTrackingModeFollow animated:YES];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.mapView addGestureRecognizer:longPress];
}

#pragma mark - UIGesture Recognizer for creating map point

- (void)didLongPress:(UITapGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint point = [sender locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    MGLPointAnnotation *annotation = [MGLPointAnnotation alloc];
    annotation.coordinate = coordinate;
    annotation.title = @"Start navigation";
    [self.mapView addAnnotation:annotation];
    [self calculateRoutefromOrigin:self.mapView.userLocation.coordinate toDestination:annotation.coordinate completion:^(MBRoute * _Nullable route, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error calculating route: %@", error);
        }
    }];
    
}

#pragma mark - calculating route from location

- (void)calculateRoutefromOrigin:(CLLocationCoordinate2D)origin toDestination:(CLLocationCoordinate2D)destination completion:(void(^)(MBRoute *_Nullable route, NSError *_Nullable error))completion
{
    MBWaypoint *originWaypoint = [[MBWaypoint alloc] initWithCoordinate:origin coordinateAccuracy:-1 name:@"Start"];
    MBWaypoint *destinationWaypoint = [[MBWaypoint alloc] initWithCoordinate:destination coordinateAccuracy:-1 name:@"Finish"];
    MBNavigationRouteOptions *options = [[MBNavigationRouteOptions alloc] initWithWaypoints:@[originWaypoint, destinationWaypoint] profileIdentifier:MBDirectionsProfileIdentifierAutomobileAvoidingTraffic];
    (void)[[MBDirections sharedDirections] calculateDirectionsWithOptions:options completionHandler:^(NSArray<MBWaypoint *> *waypoints, NSArray<MBRoute *> *routes, NSError *error) {
        if (!routes.firstObject) {
            return;
        }
        MBRoute *route = routes.firstObject;
        self.directionsRoute = route;
        CLLocationCoordinate2D *routeCoordinates = malloc(route.coordinateCount * sizeof(CLLocationCoordinate2D));
        [route getCoordinates:routeCoordinates];
        [self drawRoute:routeCoordinates];
    }];
}

#pragma mark - Drawing Map Route

- (void)drawRoute:(CLLocationCoordinate2D *)route
{
    if (self.directionsRoute.coordinateCount == 0) {
        return;
    }
    MGLPolylineFeature *polyline = [MGLPolylineFeature polylineWithCoordinates:route count:self.directionsRoute.coordinateCount];
    if ([self.mapView.style sourceWithIdentifier:@"route-source"]) {
        MGLShapeSource *source = (MGLShapeSource *)[self.mapView.style sourceWithIdentifier:@"route-source"];
        source.shape = polyline;
    } else {
        MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"route-source" shape:polyline options:nil];
        MGLLineStyleLayer *lineStyle = [[MGLLineStyleLayer alloc] initWithIdentifier:@"route-style" source:source];
        lineStyle.lineColor = [NSExpression expressionForConstantValue:[UIColor blueColor]];
        lineStyle.lineWidth = [NSExpression expressionForConstantValue:@3];
        [self.mapView.style addSource:source];
        [self.mapView.style addLayer:lineStyle];
    }
}

#pragma mark - Making Anotations

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation
{
    return true;
}

- (void)mapView:(MGLMapView *)mapView tapOnCalloutForAnnotation:(id<MGLAnnotation>)annotation
{
    MBNavigationViewController *navigationViewController = [[MBNavigationViewController alloc] initWithRoute:self.directionsRoute options:nil];
    [self presentViewController:navigationViewController animated:YES completion:nil];
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
