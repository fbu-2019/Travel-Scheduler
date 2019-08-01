//
//  MapViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/31/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MapViewController.h"
#import "Place.h"

@interface MapViewController ()
@property (strong, nonatomic) MKMapView *mainMapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadMapView];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
   // for (Place *place1 in self.placesFromSchedule){
        Place *centerLocation = self.placesFromSchedule[0];
 //   }
    CLLocationCoordinate2D coordForPin = {.latitude = [centerLocation.coordinates[@"lat"] floatValue], .longitude = [centerLocation.coordinates[@"lng"] floatValue]};
    //CLLocationCoordinate2D coordForPin = {.latitude = 49.894107, .longitude = -97.138545};
    [annotation setCoordinate:coordForPin];
    [annotation setTitle:@"Pin Here"];
    [_mainMapView addAnnotation:annotation];
    self.view = _mainMapView;
    [_mainMapView setDelegate:self];
    for (Place *place in self.placesFromSchedule){
        [self addingPlaceMarkers:place withColor: [UIColor redColor]];
    }
    [self drawRoute:self.placesFromSchedule];
}


- (void) loadMapView
{
    _mainMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    CLLocationCoordinate2D coord = {.latitude = 49.894107, .longitude = -97.138545};
    MKCoordinateSpan span = {.latitudeDelta = 0.050f, .longitudeDelta = 0.050f};
    MKCoordinateRegion region = {coord, span};
    [_mainMapView setRegion:region];
}

- (void) addingPlaceMarkers: (Place *) place withColor: (UIColor *)color
{
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([place.coordinates[@"lat"] floatValue], [place.coordinates[@"lng"] floatValue]);
    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
    [marker setCoordinate:position];
    [marker setTitle:place.name];
    [_mainMapView addAnnotation:marker];
   // [_mainMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f) animated:animated];
   // [_mainMapView showAnnotations:marker animated:YES];
}


- (void) drawRoute:(NSArray *) path {
    NSInteger numberOfSteps = path.count;
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        Place *placeLocation = [path objectAtIndex:index];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([placeLocation.coordinates[@"lat"] floatValue], [placeLocation.coordinates[@"lng"] floatValue]);
        //CLLocationCoordinate2D coordinate = placeLocation.coordinates;
        coordinates[index] = coordinate;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [_mainMapView addOverlay:polyLine];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 1.0;
    
    return polylineView;
}

- (void) creatingTripPath
{
    
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
