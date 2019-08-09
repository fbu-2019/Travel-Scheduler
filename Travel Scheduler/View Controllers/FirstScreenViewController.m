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
#import "SignInViewController.h"

@import GooglePlaces;

@interface FirstScreenViewController ()<UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, GMSAutocompleteFetcherDelegate>

@property (nonatomic) BOOL showDates;

@end

static const int kDateFieldWidth = 155;
int kHorizontalPadding = 20;

static UISearchBar *setUpPlacesSearchBar()
{
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.placeholder = @"What city are we visiting?";
    return searchBar;
}

static UITextField *createDefaultTextField(NSString *text)
{
    UITextField *tripDateTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    tripDateTextField.backgroundColor = [UIColor whiteColor];
    tripDateTextField.text = nil;
    tripDateTextField.placeholder = text;
    tripDateTextField.alpha = 0;
    return tripDateTextField;
}

static UITabBarController *createTabBarController(UIViewController *homeTab, UIViewController *scheduleTab)
{
    homeTab.title = @"Home";
    UINavigationController *homeNav = [[UINavigationController alloc] initWithRootViewController:homeTab];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    shadow.shadowColor = [UIColor whiteColor];
    
    scheduleTab.title = @"Schedule";
    UINavigationController *scheduleNav = [[UINavigationController alloc] initWithRootViewController:scheduleTab];
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[homeNav, scheduleNav];
    [[[[tabBarController tabBar]items]objectAtIndex:1]setEnabled:FALSE];    UITabBarItem *tabBarItem0 = [tabBarController.tabBar.items objectAtIndex:0];
    [tabBarItem0 setImage:[[UIImage imageNamed:@"home_icon"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    UITabBarItem *tabBarItem1 = [tabBarController.tabBar.items objectAtIndex:1];
    [tabBarItem1 setImage:[[UIImage imageNamed:@"schedule_icon"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSShadowAttributeName:shadow,
       NSFontAttributeName:[UIFont fontWithName:@"Gotham-Light" size:17]
       }
     forState:UIControlStateNormal];
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

    self.arrayOfTypes = [[NSArray alloc]initWithObjects:@"park", @"museum", @"restaurant",@"shopping_mall", @"stadium", nil];
    self.showDates = false;
    self.isHudInitated = NO;
    self.hasLoadedHub = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.placesSearchBar = setUpPlacesSearchBar();
    self.placesSearchBar.delegate = self;
    [self.view addSubview:self.placesSearchBar];
    [self createButtonToGoToSignInViewController];
    
    [self createLabels];
    [self createButton];
    [self createFilterForGMSAutocomplete];
    [self createAutocompleteTableView];
    
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.dataSource = self;
    self.path = [UIBezierPath bezierPath];
    [self setUpImage];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect screenFrame = self.view.frame;
    self.buttonToGoToSignInViewController.frame = CGRectMake(10, self.topLayoutGuide.length + 10, 60 , 35);
    if (!self.showDates) {
        self.topIconImageView.frame = CGRectMake((CGRectGetWidth(screenFrame) / 2) - (75/2), self.view.frame.size.height / 5, 75, 75);
        self.searchLabel.frame = CGRectMake(30, CGRectGetMaxY(self.topIconImageView.frame) + 10, CGRectGetWidth(screenFrame) - 60, CGRectGetHeight(screenFrame) / 2 - 15);
        [self.searchLabel sizeToFit];
        self.searchLabel.frame = CGRectMake(30, self.searchLabel.frame.origin.y, CGRectGetWidth(screenFrame) - 60, CGRectGetHeight(self.searchLabel.frame));
        [self.path moveToPoint:CGPointMake(10.0, CGRectGetHeight(self.topIconImageView.frame))];
        [self.path addLineToPoint:CGPointMake(self.searchLabel.frame.size.width - 10, CGRectGetHeight(self.topIconImageView.frame))];
        [self makeAnimatedLine];
        self.placesSearchBar.frame = CGRectMake(12, CGRectGetMaxY(self.searchLabel.frame) + 45, self.view.frame.size.width - 25, 75);
        self.autocompleteTableView.frame = CGRectMake(self.placesSearchBar.frame.origin.x + 10, CGRectGetMaxY(self.placesSearchBar.frame) - 17, CGRectGetWidth(self.placesSearchBar.frame) - 20, [self.resultsArr count] * 44);
        self.dateLabel.frame = CGRectMake(30, 250, CGRectGetWidth(screenFrame) - 60, CGRectGetHeight(self.dateLabel.frame));
        [self.dateLabel sizeToFit];
        self.dateLabel.frame = CGRectMake(30, 250, CGRectGetWidth(screenFrame) - 60, CGRectGetHeight(self.dateLabel.frame));
    } else {
        self.placesSearchBar.frame = CGRectMake(12, CGRectGetMaxY(self.buttonToGoToSignInViewController.frame) - 17, CGRectGetWidth(screenFrame) - 25, 75);
        self.beginTripDateTextField.frame = CGRectMake(kHorizontalPadding, CGRectGetMaxY(self.dateLabel.frame) + 50, kDateFieldWidth, 50);
        self.endTripDateTextField.frame = CGRectMake((CGRectGetWidth(screenFrame) / 2) + 25, CGRectGetMaxY(self.dateLabel.frame) + 50, kDateFieldWidth, 50);
        self.button.frame = CGRectMake(25, CGRectGetMaxY(self.endTripDateTextField.frame) + 50, CGRectGetWidth(self.view.frame) - 50, 50);
    }
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
    self.beginTripDateTextField = createDefaultTextField(@"Enter start date");
    [self.beginTripDateTextField setFont: [UIFont fontWithName:@"Gotham-XLight" size:20]];
    if(self.firstDateString != nil) {
        self.beginTripDateTextField.text = self.firstDateString;
    }
    self.beginTripDatePicker = [[UIDatePicker alloc] init];
    [self.beginTripDatePicker setDate:[NSDate date]];
    self.beginTripDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.beginTripDatePicker addTarget:self action:@selector(updateTextField :) forControlEvents:UIControlEventValueChanged];
    [self.beginTripDateTextField setInputView: self.beginTripDatePicker];
    [self makeDoneButton:self.beginTripDateTextField];
    if(self.endDateString != nil) {
        self.endTripDateTextField.text = self.endDateString;
    } else {
        self.endTripDateTextField.text = nil;
    }
    int fieldHeight = 50;
    int fieldWidth = kDateFieldWidth;
    self.beginTripDateTextField.frame = CGRectMake(kHorizontalPadding, CGRectGetMaxY(self.dateLabel.frame) + 150, fieldWidth, fieldHeight);
    self.endTripDateTextField.frame = CGRectMake((CGRectGetWidth(self.view.frame) / 2) + 25, CGRectGetMaxY(self.dateLabel.frame) + 150, fieldWidth, fieldHeight);
    self.beginTripDateTextField.textAlignment = NSTextAlignmentCenter;
    self.endTripDateTextField.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - Setting up EndDateTextField

- (void)setUpEndDateText
{
    self.endTripDateTextField = createDefaultTextField(@"Enter end date");
    [self.endTripDateTextField setFont: [UIFont fontWithName:@"Gotham-XLight" size:20]];
    self.endTripDatePicker = [[UIDatePicker alloc] init];
    self.endTripDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.endTripDatePicker addTarget:self action:@selector(updateTextFieldEnd :) forControlEvents:UIControlEventValueChanged];
    [self.endTripDateTextField setInputView:self.endTripDatePicker];
    [self makeDoneButton:self.endTripDateTextField];
}

- (void)makeDoneButton:(UITextField *)textField
{
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(removeDatePicker)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    [textField setInputAccessoryView:toolBar];
}

- (void)removeDatePicker
{
    [self.endTripDateTextField endEditing:YES];
    [self.beginTripDateTextField endEditing:YES];
    self.button.enabled = YES;
    self.button.alpha = 1;
}

- (void)updateTextField:(UIDatePicker *)sender
{
    self.beginTripDatePicker.minimumDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventStartDate = self.beginTripDatePicker.date;
    self.userSpecifiedStartDate = eventStartDate;
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    self.firstDateString = [dateFormat stringFromDate:eventStartDate];
    self.beginTripDateTextField.text = [NSString stringWithFormat:@"%@",self.firstDateString];
    [self updateStatusOfButton];
    self.endTripDatePicker.minimumDate = [NSDate dateWithTimeInterval:1.0 sinceDate:self.beginTripDatePicker.date];
}

- (void)updateTextFieldEnd:(UIDatePicker *)sender
{
    self.endTripDatePicker.minimumDate = [NSDate dateWithTimeInterval:1.0 sinceDate:self.beginTripDatePicker.date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventEndDate = self.endTripDatePicker.date;
    self.userSpecifiedEndDate = eventEndDate;
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    self.endDateString = [dateFormat stringFromDate:eventEndDate];
    self.endTripDateTextField.text = [NSString stringWithFormat:@"%@",self.endDateString];
    [self updateStatusOfButton];
    self.beginTripDatePicker.maximumDate = [NSDate dateWithTimeInterval:1.0 sinceDate:self.endTripDatePicker.date];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)updateStatusOfButton
{
    if(self.userSpecifiedEndDate != nil && self.userSpecifiedStartDate != nil) {
        self.button.enabled = YES;
        self.button.alpha = 1;
    } else {
        self.button.enabled = NO;
        self.button.alpha = 0.5;
    }
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
        [self.autocompleteTableView layoutIfNeeded];
    }
    else if (searchText.length == 0){
        self.autocompleteTableView.alpha = 0;
        [self.autocompleteTableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    self.showDates = true;
    [self setUpDatePickers];
    [self animateDateIn];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    if (self.showDates) {
        [self animateDateOut];
        self.showDates = false;
    }
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
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectZero];
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
    self.searchLabel = makeHeaderLabel(@"CHOOSE A DESTINATION", 30);
    [self.view addSubview:self.searchLabel];
    self.dateLabel = makeHeaderLabel(@"CHOOSE YOUR TRIP DATES", 30);
    self.dateLabel.alpha = 0;
    [self.view addSubview:self.dateLabel];
}

- (void)createButton
{
    self.button = makeScheduleButton(@"Proceed to Schedule");
    self.button.alpha = 0;
    self.button.enabled = NO;
    [self.button addTarget:self action:@selector(segueToPlaces) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button];
}

- (void)createButtonToGoToSignInViewController
{
    self.buttonToGoToSignInViewController = [[UIButton alloc] init];
    [self.buttonToGoToSignInViewController setTitle:@"Back" forState:UIControlStateNormal];
    self.buttonToGoToSignInViewController.backgroundColor = [UIColor clearColor];
    self.buttonToGoToSignInViewController.layer.cornerRadius = 10;
    [self.buttonToGoToSignInViewController addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.buttonToGoToSignInViewController];
    [self.buttonToGoToSignInViewController setFont:[UIFont fontWithName:@"Gotham-Light" size:17.0]];
    [self.buttonToGoToSignInViewController setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (void) dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)BackToLogIn:(UIButton *)sender{
    SignInViewController *backToSignInController = [[SignInViewController alloc] init];
    [self showViewController:backToSignInController sender:sender];
}

- (void)makeAnimatedLine
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [self.path CGPath];
    UIColor *lightGrayColor = [UIColor colorWithRed:0.65 green:0.69 blue:0.76 alpha:0.8];
    shapeLayer.strokeColor = [lightGrayColor CGColor];
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
    self.topIconImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    topIcon = [UIImage imageNamed:@"llama.png"];
    self.topIconImageView.image = topIcon;
    self.topIconImageView.layer.shadowOffset = CGSizeMake(1, 0);
    self.topIconImageView.layer.shadowColor = getColorFromIndex(CustomColorRegularPink).CGColor;
    self.topIconImageView.layer.shadowRadius = 2;
    self.topIconImageView.layer.shadowOpacity = 0.8;
    self.topIconImageView.clipsToBounds = false;
    self.topIconImageView.layer.masksToBounds = false;
    [self.view addSubview:self.topIconImageView];
}

- (void)segueToPlaces
{
    [self.endTripDateTextField endEditing:YES];
    [self.beginTripDateTextField endEditing:YES];
    HomeCollectionViewController *homeTab = [[HomeCollectionViewController alloc] init];
    ScheduleViewController *scheduleTab = [[ScheduleViewController alloc] init];
    UITabBarController *tabBarController = createTabBarController(homeTab, scheduleTab);
    [self showHud];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[Place alloc]getHubWithName:self.userSpecifiedPlaceToVisit withArrayOfTypes:self.arrayOfTypes withCompletion:^(Place *place, NSError *error) {
            if(place) {
                self.hub = place;
                self.hasLoadedHub = YES;
                homeTab.hubPlaceName = self.userSpecifiedPlaceToVisit;
                homeTab.arrayOfTypes = self.arrayOfTypes;
                homeTab.hub = self.hub;
                homeTab.numberOfTravelDays = (int)[Date daysBetweenDate:self.userSpecifiedStartDate andDate:self.userSpecifiedEndDate] + 1;
                scheduleTab.startDate = self.userSpecifiedStartDate;
                scheduleTab.endDate = self.userSpecifiedEndDate;
                scheduleTab.selectedPlacesArray = self.selectedPlacesArray;
                [self presentViewController:tabBarController animated:YES completion:nil];  
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.hud hideWithAnimation:YES];
                });
            }
        }];
    });
}

#pragma mark - FirstScreenController animation helper methods

- (void)animateDateIn
{
    self.searchLabel.alpha = 0;
    self.autocompleteTableView.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.topIconImageView.alpha = 0.0;
    }];
    [UIView animateWithDuration:1.0 animations:^{
        self.placesSearchBar.frame = CGRectMake(12, CGRectGetMaxY(self.buttonToGoToSignInViewController.frame) - 17, CGRectGetWidth(self.view.frame) - 25, 75);
        self.beginTripDateTextField.frame = CGRectMake(kHorizontalPadding, CGRectGetMaxY(self.dateLabel.frame) + 50, kDateFieldWidth, 50);
        self.endTripDateTextField.frame = CGRectMake((CGRectGetWidth(self.view.frame) / 2) + 25, CGRectGetMaxY(self.dateLabel.frame) + 50, kDateFieldWidth, 50);
    }];
    [self performSelector:@selector(fadeIn) withObject:self afterDelay:1.0];
}

- (void)fadeIn
{
    [UIView animateWithDuration:0.75 animations:^{
        self.dateLabel.alpha = 1;
        self.beginTripDateTextField.alpha = 1;
        self.endTripDateTextField.alpha = 1;
        self.button.alpha = 0.6;
    }];
}

- (void)animateDateOut
{
    self.button.enabled = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.dateLabel.alpha = 0;
        self.beginTripDateTextField.alpha = 0;
        self.endTripDateTextField.alpha = 0;
        self.button.alpha = 0;
    }];
    [UIView animateWithDuration:1 animations:^{
        self.placesSearchBar.frame = CGRectMake(12, CGRectGetMaxY(self.searchLabel.frame) + 45, self.view.frame.size.width - 25, 75);
    }];
    [self performSelector:@selector(fadeSearchLabel) withObject:self afterDelay:0.75];
    [self performSelector:@selector(fadeInTableView) withObject:self afterDelay:0.75];
}

- (void)fadeSearchLabel
{
    [UIView animateWithDuration:0.5 animations:^{
        self.searchLabel.alpha = 1;
        self.topIconImageView.alpha = 1;
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
    self.hud.containerColor = [UIColor colorWithRed:0.37 green:0.15 blue:0.8 alpha:1];
    self.hud.containerCornerRadius = 5;
    self.hud.scaleFactor = 5.0;
    self.hud.minimumPadding = 16;
    self.hud.titleColor = [UIColor whiteColor];
    self.hud.detailTitleColor = [UIColor whiteColor];
    self.hud.titleFont = [UIFont fontWithName:@"Gotham-Light" size:20];
    self.hud.detailTitleFont = [UIFont fontWithName:@"Gotham-Light" size:16];
}

@end
