//
//  CommuteDetailsViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 8/2/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "CommuteDetailsViewController.h"
#import "TravelStepCell.h"
#import "TravelSchedulerHelper.h"
#import "TravelSchedulerHelper.h"

@interface CommuteDetailsViewController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>
@property (nonatomic, strong) TravelStepCell *prototypeCell;
@property (nonatomic) CLLocationCoordinate2D coord1;
@property (nonatomic) CLLocationCoordinate2D coord2;

@end

static UILabel *makeAndAddLabel(UITableViewCell *cell, NSString *string, float topY) {
    UILabel *label = makeSubHeaderLabel(string, 17);
    label.frame = CGRectMake(5, topY, 400, 50);
    [label sizeToFit];
    [cell.contentView addSubview:label];
    return label;
}

static void instantiateImageViewTitle(UILabel *titleLabel)
{
    [titleLabel setFont: [UIFont fontWithName:@"Arial-BoldMT" size:15]];
    titleLabel.text = @"Tap For Navigation";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 0;
    titleLabel.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    titleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    titleLabel.layer.shadowRadius = 3.0;
    titleLabel.layer.shadowOpacity = 1;
    titleLabel.layer.masksToBounds = NO;
    [titleLabel sizeToFit];
    titleLabel.layer.shouldRasterize = YES;
}


static const NSString *kTravelCellIdentifier = @"TravelStepCell";

@implementation CommuteDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePreferredContentSize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    self.cellHeights = [[NSMutableDictionary alloc] init];
    NSString *titleString = [NSString stringWithFormat:@"%@ to %@", self.commute.origin.name, self.commute.destination.name];
    self.headerLabel = makeHeaderLabel(titleString, 22);
    [self.view addSubview:self.headerLabel];
    [self createTableView];
    [self.commuteMapView setDelegate:self];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.headerLabel.frame = CGRectMake(15, self.topLayoutGuide.length + 10, CGRectGetWidth(self.view.frame) - 30, CGRectGetHeight(self.view.frame));
    [self.headerLabel sizeToFit];
    self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, 10000);
}

- (void)viewDidLayoutSubviews
{
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    float tableViewHeight;
    float availableHeight = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.headerLabel.frame) - self.bottomLayoutGuide.length;
    float totalTableViewHeight = [[[self.cellHeights allValues] valueForKeyPath: @"@sum.self"] floatValue] + self.commuteHeaderHeight;
    if (availableHeight < totalTableViewHeight) {
        self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, availableHeight);
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, totalTableViewHeight);
        self.tableView.scrollEnabled = NO;
    }
   
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (TravelStepCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:kTravelCellIdentifier];
    }
    return _prototypeCell;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapCellIdentifier"];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mapCellIdentifier"];
        }
        self.commuteMapView = [[MKMapView alloc] init];
        [self.commuteMapView setDelegate:self];
        [self createMapAnnotations];
        self.viewForMap = [[UIView alloc] init];
        [self createCellContents:cell];
        gettingRouteFromApple(self.commute.origin, self.commute.destination, self.commuteMapView);
        self.commuteMapView.userInteractionEnabled = NO;
        setupGRonImagewithTaps(self.tappedMap, self.viewForMap, 1);
        self.viewForMap = self.commuteMapView;
        instantiateImageViewTitle(self.textOnMap);
        self.textOnMap.numberOfLines = 0;
        self.textOnMap.frame = CGRectMake(5, 0, self.viewForMap.frame.size.width - 10, self.viewForMap.frame.size.height/3);
        [self.textOnMap sizeToFit];
        self.textOnMap.frame = CGRectMake(5, CGRectGetHeight(self.viewForMap.frame) - CGRectGetHeight(self.textOnMap.frame), CGRectGetWidth(self.textOnMap.frame), CGRectGetHeight(self.textOnMap.frame));
        [self.viewForMap addSubview:self.textOnMap];
        return cell;
    }
    TravelStepCell *cell = (TravelStepCell *)[tableView dequeueReusableCellWithIdentifier:kTravelCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        if (indexPath.row == 1) {
            cell = [[TravelStepCell alloc] initWithPlace:self.commute.origin];
        } else if (indexPath.row == self.commute.arrayOfSteps.count + 2) {
            cell = [[TravelStepCell alloc] initWithPlace:self.commute.destination];
        } else {
            cell = [[TravelStepCell alloc] initWithStep:self.commute.arrayOfSteps[indexPath.row - 2]];
        }
    } else {
        if (indexPath.row == 1) {
            [cell setTravelPlace:self.commute.origin];
        } else if (indexPath.row == self.commute.arrayOfSteps.count + 2) {
            [cell setTravelPlace:self.commute.destination];
        } else {
            [cell setTravelStep:self.commute.arrayOfSteps[indexPath.row - 2]];
        }
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commute.arrayOfSteps.count + 3;
}

#pragma mark - Setting up Map

- (void)createMapAnnotations{
    self.coord1 = CLLocationCoordinate2DMake([self.commute.origin.coordinates[@"lat"] floatValue], [self.commute.origin.coordinates[@"lng"] floatValue]);
    self.coord2 = CLLocationCoordinate2DMake([self.commute.destination.coordinates[@"lat"] floatValue], [self.commute.destination.coordinates[@"lng"] floatValue]);
    MKPointAnnotation *marker1 = [[MKPointAnnotation alloc] init];
    MKPointAnnotation *marker2 = [[MKPointAnnotation alloc] init];
    
    CLLocationCoordinate2D coord = {.latitude = [self.commute.origin.coordinates[@"lat"] floatValue], .longitude = [self.commute.destination.coordinates[@"lng"] floatValue]};
    MKCoordinateSpan span = {.latitudeDelta = 0.050f, .longitudeDelta = 0.050f};
    MKCoordinateRegion region = {coord, span};
    [self.commuteMapView setRegion:region];
    
    MKMapPoint p1 = MKMapPointForCoordinate (self.coord1);
    MKMapPoint p2 = MKMapPointForCoordinate (self.coord2);
    MKMapRect mapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y));
    [self.commuteMapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(20.0f, 20.0f, 20.0f, 20.0f) animated:YES];
    
    [marker1 setCoordinate:self.coord1];
    [marker2 setCoordinate:self.coord2];
    [marker1 setTitle: [NSString stringWithFormat:@"%i. %@", 1, self.commute.origin.name]];
    [marker2 setTitle: [NSString stringWithFormat:@"%i. %@", 2, self.commute.destination.name]];
    
    [self.commuteMapView addAnnotation:marker1];
    [self.commuteMapView addAnnotation:marker2];
}

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

#pragma mark - TableView Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return self.commuteHeaderHeight;
    }
    if (indexPath.row == 1) {
        self.prototypeCell = [[TravelStepCell alloc] initWithPlace:self.commute.origin];
    } else if (indexPath.row == self.commute.arrayOfSteps.count + 2) {
        self.prototypeCell = [[TravelStepCell alloc] initWithPlace:self.commute.destination];
    } else {
        self.prototypeCell = [[TravelStepCell alloc] initWithStep:self.commute.arrayOfSteps[indexPath.row - 2]];
    }
    [self.prototypeCell layoutIfNeeded];
    CGFloat height = getMax(70, CGRectGetMaxY(self.prototypeCell.subLabel.frame) + 10);
    [self.cellHeights setObject:@(height) forKey:@(indexPath.row)];
    return height;
}

- (void)createCellContents:(UITableViewCell *)cell
{
    NSString *timeString = [NSString stringWithFormat:@"Time: %@", self.commute.durationString];
    UILabel *timeLabel = makeAndAddLabel(cell, timeString, 25);
    
    NSString *distString = [NSString stringWithFormat:@"Distance: %.01f km", [self.commute.distance floatValue] / 1000];
    UILabel *distLabel = makeAndAddLabel(cell, distString, CGRectGetMaxY(timeLabel.frame) + 10);
    
    NSString *cost = [self.commute.fare valueForKey:@"text"];
    NSString *costString = (cost) ? [NSString stringWithFormat:@"Cost: %@", cost] : @"Cost: free";
    UILabel *costLabel = makeAndAddLabel(cell, costString, CGRectGetMaxY(distLabel.frame) + 10);
    
    float xCoord = getMax(getMax(CGRectGetMaxX(timeLabel.frame), CGRectGetMaxX(distLabel.frame)), CGRectGetMaxX(costLabel.frame));
    self.viewForMap.frame = CGRectMake(xCoord + 25, 0, CGRectGetWidth(self.view.frame) - xCoord - 20, CGRectGetMaxY(costLabel.frame) + 25);
    self.commuteMapView.frame = CGRectMake(xCoord + 25, 0, CGRectGetWidth(self.view.frame) - xCoord - 20, CGRectGetMaxY(costLabel.frame) + 25);
    self.textOnMap = [[UILabel alloc] initWithFrame:CGRectMake(5,CGRectGetMaxY(costLabel.frame),self.viewForMap.bounds.size.width - 10,20)];
    
    _tappedMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapSegue)];
    
    self.viewForMap = self.commuteMapView;
    [cell addSubview:self.viewForMap];
    
    UILabel *commuteLabel = makeAndAddLabel(cell, @"Commute Details", CGRectGetMaxY(costLabel.frame) + 45);
    [commuteLabel setFont:[UIFont fontWithName:@"Gotham-Bold" size:20]];
    commuteLabel.frame = CGRectMake(commuteLabel.frame.origin.x, commuteLabel.frame.origin.y, CGRectGetWidth(self.view.frame), 50);
    [commuteLabel sizeToFit];
    self.commuteHeaderHeight = CGRectGetMaxY(commuteLabel.frame) + 5;
}

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[TravelStepCell class] forCellReuseIdentifier:kTravelCellIdentifier];
    [self.view addSubview:self.tableView];
}

#pragma mark - Segue to Navigation

- (void)mapSegue
{
    Place *startPlace = self.commute.origin;
    Place *endPlace = self.commute.destination;
    
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", self.coord1.latitude, self.coord1.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f",self.coord2.latitude, self.coord2.longitude];
    self.apiUrl = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,&daddr=%@&dirflg=d", saddr, daddr];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.apiUrl] options:@{} completionHandler:^(BOOL success) {}];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.apiUrl]];
    }
}

@end
