//
//  FirstScreenViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "FirstScreenViewController.h"
#import "TravelSchedulerHelper.h"
#import "Date.h"
#import "HomeCollectionViewController.h"
#import "ScheduleViewController.h"
#import <GIFProgressHUD.h>
#import <GooglePlaces/GooglePlaces.h>
#import "AutocompleteTableViewCell.h"

@import GooglePlaces;

@interface FirstScreenViewController ()<UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, GMSAutocompleteFetcherDelegate>

@end

static UISearchBar *setUpPlacesSearchBar(UISearchBar *searchBar, CGRect startFrame)
{
    searchBar = [[UISearchBar alloc] initWithFrame:startFrame];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.placeholder = @"Ready for your jorney? Choose a city!";
    return searchBar;
}

static UITextField *createDefaultTextField(NSString *text, CGRect startFrame)
{
    UITextField *tripDateTextField = [[UITextField alloc] initWithFrame:startFrame];
    tripDateTextField.backgroundColor = [UIColor whiteColor];
    tripDateTextField.text = nil;
    tripDateTextField.placeholder = text;
    tripDateTextField.alpha = 0;
    return tripDateTextField;
}

static UILabel *makeCenterLabel(NSString *text, CGRect screenFrame)
{
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(30, 100, CGRectGetWidth(screenFrame) - 60, CGRectGetHeight(screenFrame) / 2 - 15)];
    [label setFont: [UIFont fontWithName:@"Gotham-Bold" size:30]];
    label.text = text;
    UIColor *grayColor = [UIColor colorWithRed:0.33 green:0.36 blue:0.41 alpha:1];
    label.textColor = grayColor;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

static UITabBarController *createTabBarController(UIViewController *homeTab, UIViewController *scheduleTab)
{
    homeTab.title = @"Home";
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeTab];
    scheduleTab.title = @"Schedule";
    UINavigationController *scheduleNav = [[UINavigationController alloc] initWithRootViewController:scheduleTab];
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[homeNav, scheduleNav];
    [[[[tabBarController tabBar]items]objectAtIndex:1]setEnabled:FALSE];    UITabBarItem *tabBarItem0 = [tabBarController.tabBar.items objectAtIndex:0];
    [tabBarItem0 setImage:[[UIImage imageNamed:@"home_icon"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    UITabBarItem *tabBarItem1 = [tabBarController.tabBar.items objectAtIndex:1];
    [tabBarItem1 setImage:[[UIImage imageNamed:@"schedule_icon"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    return tabBarController;
}

@implementation FirstScreenViewController
{
    GMSAutocompleteFetcher *_fetcher;
}

#pragma mark - Cell LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isHudInitated = NO;
    self.hasLoadedHub = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpFrames];
    self.placesSearchBar = setUpPlacesSearchBar(self.placesSearchBar, self.searchBarStart);
    self.placesSearchBar.delegate = self;
    [self.view addSubview:self.placesSearchBar];
    [self createLabels];
    [self createButton];
    [self createFilterForGMSAutocomplete];
    [self createAutocompleteTableView];
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource = self;
    [self makeAnimatedLine];
    [self setUpImage];
}

- (void)makeAnimatedLine
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(10.0, self.searchLabel.frame.size.height - 170)];
    [path addLineToPoint:CGPointMake(self.searchLabel.frame.size.width - 10, self.searchLabel.frame.size.height - 170)];

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    UIColor *lightGrayColor = [UIColor colorWithRed:0.65 green:0.69 blue:0.76 alpha:0.8];
    shapeLayer.strokeColor = [lightGrayColor CGColor];
    [self.searchLabel.layer addSublayer:shapeLayer];
    shapeLayer.lineWidth = 3;
    shapeLayer.fillColor = [[UIColor yellowColor] CGColor];
    [self.searchLabel.layer addSublayer:shapeLayer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.5f;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.repeatCount = 1;
    pathAnimation.autoreverses = NO;
    [shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}
    
- (void)setUpImage
{
    UIImage *topIcon = [[UIImage alloc] init];
    self.topIconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width / 2) - (75/2), self.view.frame.size.height / 5 + 10,75,75)];
    topIcon = [UIImage imageNamed:@"iconfinder_traveling_icon_flat_outline-09_3405110.png"];
    self.topIconImageView.image = topIcon;
    [self.view addSubview:self.topIconImageView];
}
    
#pragma mark - GMSAutocompleteFetcherDelegate

- (void)didAutocompleteWithPredictions:(NSArray *)predictions
{
    self.resultsArr = [[NSMutableArray alloc] init];
    for (GMSAutocompletePrediction *prediction in predictions) {
        [self.resultsArr addObject:[prediction.attributedFullText string]];
    }
}

- (void)didFailAutocompleteWithError:(NSError *)error
{
    NSString *errorMessage = [NSString stringWithFormat:@"%@", error.localizedDescription];
    NSLog(@"%@", errorMessage);
}

#pragma mark - Autocomplete Delegate & TabeView DataSource Method

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AutocompleteTableViewCell";
    AutocompleteTableViewCell *cell = (AutocompleteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[AutocompleteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        cell.textLabel.textColor=[UIColor blackColor];
        [cell.textLabel setFont:[UIFont fontWithName:@"Gotham-Thin" size:15]];
    }
    cell.textLabel.text = [self.resultsArr objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultsArr.count;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AutocompleteTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.placesSearchBar.text = cell.textLabel.text;
    self.userSpecifiedPlaceToVisit = cell.textLabel.text;
    [self searchBarSearchButtonClicked: self.placesSearchBar];
    return indexPath;
}

#pragma mark - Setting up text fields

- (void)setUpBeginDateText
{
    self.beginTripDateTextField = createDefaultTextField(@"Enter start date", self.startDateFieldStart);
    [self.beginTripDateTextField setFont: [UIFont fontWithName:@"Gotham-XLight" size:20]];
    self.beginTripDatePicker = [[UIDatePicker alloc] init];
    [self.beginTripDatePicker setDate:[NSDate date]];
    self.beginTripDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.beginTripDatePicker addTarget:self action:@selector(updateTextField :) forControlEvents:UIControlEventValueChanged];
    [self.beginTripDateTextField setInputView: self.beginTripDatePicker];
    self.endTripDateTextField.text = nil;
}

#pragma mark - Setting up EndDateTextField

- (void)setUpEndDateText
{
    self.endTripDateTextField = createDefaultTextField(@"Enter end date", self.endDateFieldStart);
    [self.endTripDateTextField setFont: [UIFont fontWithName:@"Gotham-XLight" size:20]];
    self.endTripDatePicker = [[UIDatePicker alloc] init];
    self.endTripDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.endTripDatePicker addTarget:self action:@selector(updateTextFieldEnd :) forControlEvents:UIControlEventValueChanged];
    [self.endTripDateTextField setInputView: self.endTripDatePicker];
}

- (void)updateTextField:(UIDatePicker *)sender
{
    self.beginTripDatePicker.minimumDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventStartDate = self.beginTripDatePicker.date;
    self.userSpecifiedStartDate = eventStartDate;
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString1 = [dateFormat stringFromDate:eventStartDate];
    self.beginTripDateTextField.text = [NSString stringWithFormat:@"%@",dateString1];
}

- (void)updateTextFieldEnd:(UIDatePicker *)sender
{
    self.endTripDatePicker.minimumDate = [NSDate dateWithTimeInterval:1.0 sinceDate:self.beginTripDatePicker.date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventEndDate = self.endTripDatePicker.date;
    self.userSpecifiedEndDate = eventEndDate;
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString1 = [dateFormat stringFromDate:eventEndDate];
    self.endTripDateTextField.text = [NSString stringWithFormat:@"%@",dateString1];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - UISearchBar delegate method

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length != 0) {
        if (searchText.length == 1) {
            self.autocompleteTableView.alpha = 1;
        }
        [_fetcher sourceTextHasChanged:searchText];
        [self.view addSubview:self.autocompleteTableView];
        [self.autocompleteTableView reloadData];
    }
    else if (searchText.length == 0){
        //TODO(Franklin): place user default searches here
        self.autocompleteTableView.alpha = 0;
        [self.autocompleteTableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    [self setUpDatePickers];
    [self animateDateIn];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    if (!CGRectEqualToRect(searchBar.frame, self.searchBarStart)) {
        [self animateDateOut];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

#pragma mark - UIPIckerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView
{
    return 5;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 4;
}

#pragma mark - FirstScreenViewController Setup helper methods

- (void) createAutocompleteTableView
{
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(30, 450, 300, 190)];
}

- (void) createFilterForGMSAutocomplete
{
    CLLocationCoordinate2D neBoundsCorner = CLLocationCoordinate2DMake(-33.843366, 151.134002);
    CLLocationCoordinate2D swBoundsCorner = CLLocationCoordinate2DMake(-33.875725, 151.200349);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:neBoundsCorner coordinate:swBoundsCorner];
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterCity;
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds filter:filter];
    _fetcher.delegate = self;
}

#pragma mark - FirstScreenViewController Setup helper methods

- (void)setUpDatePickers
{
    [self setUpBeginDateText];
    self.beginTripDateTextField.delegate = self;
    [self.view addSubview:self.beginTripDateTextField];
    [self setUpEndDateText];
    self.endTripDateTextField.delegate = self;
    [self.view addSubview:self.endTripDateTextField];
}

- (void)createLabels
{
    self.searchLabel = makeCenterLabel(@"CHOOSE A DESTINATION", self.view.frame);
    [self.view addSubview:self.searchLabel];
    self.dateLabel = makeCenterLabel(@"CHOOSE YOUR TRIP DATES", self.view.frame);
    self.dateLabel.frame = CGRectMake(30, 150, CGRectGetWidth(self.view.frame) - 60, CGRectGetHeight(self.view.frame) / 2 - 15);
    self.dateLabel.alpha = 0;
    [self.view addSubview:self.dateLabel];
}

- (void)setUpFrames
{
    CGRect screenFrame = self.view.frame;
    self.searchBarStart = CGRectMake(12, CGRectGetHeight(screenFrame) / 2 - 75, self.view.frame.size.width - 25, 85);
    self.searchBarEnd = CGRectMake(2, 80, CGRectGetWidth(screenFrame) - 4, 75);
    self.startDateFieldStart = CGRectMake(45, CGRectGetHeight(screenFrame)/1.7, 200, 50);
    self.startDateFieldEnd = CGRectMake(45, CGRectGetHeight(screenFrame) / 2, 200, 50);
    self.endDateFieldStart = CGRectMake(240, CGRectGetHeight(screenFrame)/1.7, 200, 50);
    self.endDateFieldEnd = CGRectMake(240, CGRectGetHeight(screenFrame)/2, 200, 50);
}

- (void)createButton
{
    self.button = makeButton(@"Proceed to Schedule", CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 50);
    [self.button.titleLabel setFont:[UIFont fontWithName:@"Gotham-XLight" size:20]];
    self.button.frame = CGRectMake(25, CGRectGetHeight(self.view.frame) / 2 + 100, CGRectGetWidth(self.button.frame), 50);
    self.button.alpha = 0;
    UIColor *pinkColor = [UIColor colorWithRed:0.93 green:0.30 blue:0.40 alpha:1];
    self.button.backgroundColor = pinkColor;
    self.button.layer.cornerRadius = 2;
    self.button.clipsToBounds = YES;
    [self.button addTarget:self action:@selector(segueToPlaces) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (void)segueToPlaces
{
    HomeCollectionViewController *homeTab = [[HomeCollectionViewController alloc] init];
    ScheduleViewController *scheduleTab = [[ScheduleViewController alloc] init];
    UITabBarController *tabBarController = createTabBarController(homeTab, scheduleTab);
    [self showHud];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.hub = [[Place alloc] initHubWithName:self.userSpecifiedPlaceToVisit];
        self.hasLoadedHub = YES;
        homeTab.hubPlaceName = self.userSpecifiedPlaceToVisit;
        homeTab.hub = self.hub;
        scheduleTab.startDate = self.userSpecifiedStartDate;
        scheduleTab.endDate = self.userSpecifiedEndDate;
        scheduleTab.selectedPlacesArray = self.selectedPlacesArray;
        [self presentModalViewController:tabBarController animated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hideWithAnimation:YES];
        });
    });
}

#pragma mark - FirstScreenController animation helper methods

- (void)animateDateIn
{
    self.searchLabel.alpha = 0;
    self.autocompleteTableView.alpha = 0;
    [UIView animateWithDuration:0.75 animations:^{
        self.topIconImageView.alpha = 0.0;
        self.placesSearchBar.frame = self.searchBarEnd;
        self.beginTripDateTextField.frame = self.startDateFieldEnd;
        self.endTripDateTextField.frame = self.endDateFieldEnd;
    }];
    [self performSelector:@selector(fadeIn) withObject:self afterDelay:1.0];
}

- (void)fadeIn
{
    [UIView animateWithDuration:0.75
     animations:^{
        self.dateLabel.alpha = 1;
        self.beginTripDateTextField.alpha = 1;
        self.endTripDateTextField.alpha = 1;
        self.button.alpha = 1;
        [self.topIconImageView removeFromSuperview];
    }];
}

- (void)animateDateOut
{
    [UIView animateWithDuration:0.25 animations:^{
        self.dateLabel.alpha = 0;
        self.beginTripDateTextField.alpha = 0;
        self.endTripDateTextField.alpha = 0;
        self.button.alpha = 0;
    }];
    [UIView animateWithDuration:1 animations:^{
        self.placesSearchBar.frame = self.searchBarStart;
        self.beginTripDateTextField.frame = self.startDateFieldStart;
        self.endTripDateTextField.frame = self.endDateFieldStart;
    }];
    [self performSelector:@selector(fadeSearchLabel) withObject:self afterDelay:0.75];
    [self performSelector:@selector(fadeInTableView) withObject:self afterDelay:0.75];
}

- (void)fadeSearchLabel
{
    [UIView animateWithDuration:0.5 animations:^{
        self.searchLabel.alpha = 1;
    }];
}

- (void) fadeInTableView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.autocompleteTableView.alpha = 1;
    }];
}

#pragma mark - Methods for the llama HUD

- (void)showHud
{
    self.hud = [GIFProgressHUD showHUDWithGIFName:@"partyLhama" title:@"Next stop: the past!" detailTitle:@"Exploring museums and time machines in the area" addedToView:self.view animated:YES];
    self.hud.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.hud.containerColor = [UIColor colorWithRed:0.37 green:0.15 blue:0.8 alpha:0.8];
    self.hud.containerCornerRadius = 5;
    self.hud.scaleFactor = 5.0;
    self.hud.minimumPadding = 16;
    self.hud.titleColor = [UIColor whiteColor];
    self.hud.detailTitleColor = [UIColor whiteColor];
    self.hud.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    self.hud.detailTitleFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
}
    

@end
