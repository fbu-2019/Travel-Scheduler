//
//  FirstScreenViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "FirstScreenViewController.h"
#import "TravelSchedulerHelper.h"


@interface FirstScreenViewController ()<UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property(strong, nonatomic) UISearchBar *placesSearchBar;
@property(strong, nonatomic) NSDateFormatter *dateFormat;
@property(strong, nonatomic) NSString *firstDateString;
@property(strong, nonatomic) NSString *userSpecifiedPlaceToVisit;
@property(strong, nonatomic) NSDate *userSpecifiedStartDate;
@property(strong, nonatomic) NSDate *userSpecifiedEndDate;
@property(strong, nonatomic) UILabel *headerLabel;
@property(strong, nonatomic) UILabel *searchLabel;
@property(strong, nonatomic) UILabel *dateLabel;
@property(nonatomic) CGRect searchBarStart;
@property(nonatomic) CGRect searchBarEnd;
@property(nonatomic) CGRect startDateFieldStart;
@property(nonatomic) CGRect startDateFieldEnd;
@property(nonatomic) CGRect endDateFieldStart;
@property(nonatomic) CGRect endDateFieldEnd;

@end

static UISearchBar* setUpPlacesSearchBar(UISearchBar *searchBar, CGRect startFrame) {
    searchBar = [[UISearchBar alloc] initWithFrame:startFrame];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.backgroundColor = [UIColor whiteColor];
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.placeholder = @"Search destination of choice ...";
    return searchBar;
}

static UITextField* createDefaultTextField(NSString *text, CGRect startFrame) {
    UITextField *tripDateTextField = [[UITextField alloc] initWithFrame:startFrame];
    tripDateTextField.backgroundColor = [UIColor whiteColor];
    tripDateTextField.text = nil;
    tripDateTextField.placeholder = text;
    tripDateTextField.alpha = 0;
    return tripDateTextField;
}

static UILabel* makeCenterLabel(NSString *text, CGRect screenFrame) {
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(30, 100, CGRectGetWidth(screenFrame) - 60, CGRectGetHeight(screenFrame) / 2 - 15)];
    [label setFont: [UIFont systemFontOfSize:40]];
    label.text = text;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

@implementation FirstScreenViewController

#pragma mark - Cell LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect screenFrame = self.view.frame;
    self.searchBarStart = CGRectMake(2, CGRectGetHeight(screenFrame) / 2 - 75, CGRectGetWidth(screenFrame) - 4, 75);
    self.searchBarEnd = CGRectMake(2, 125, CGRectGetWidth(screenFrame) - 4, 75);
    self.startDateFieldStart = CGRectMake(50, CGRectGetHeight(screenFrame)/1.7, 200, 50);
    self.startDateFieldEnd = CGRectMake(50, CGRectGetHeight(screenFrame) / 2, 200, 50);
    self.endDateFieldStart = CGRectMake(245, CGRectGetHeight(screenFrame)/1.7, 200, 50);
    self.endDateFieldEnd = CGRectMake(245, CGRectGetHeight(screenFrame)/2, 200, 50);
    self.placesSearchBar = setUpPlacesSearchBar(self.placesSearchBar, self.searchBarStart);
    self.placesSearchBar.delegate = self;
    [self.view addSubview:self.placesSearchBar];
    [self initiateLabels];
}

#pragma mark - Setting up BeginDateTextField

-(void)setUpBeginDateText{
    self.beginTripDateTextField = createDefaultTextField(@"Enter start date", self.startDateFieldStart);
    self.beginTripDatePicker = [[UIDatePicker alloc] init];
    [self.beginTripDatePicker setDate:[NSDate date]];
    self.beginTripDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.beginTripDatePicker addTarget:self action:@selector(updateTextField :) forControlEvents:UIControlEventValueChanged];
    [self.beginTripDateTextField setInputView: self.beginTripDatePicker];
    self.endTripDateTextField.text = nil;
}

#pragma mark - Setting up EndDateTextField

-(void)setUpEndDateText{
    self.endTripDateTextField = createDefaultTextField(@"Enter end date", self.endDateFieldStart);
    self.endTripDatePicker = [[UIDatePicker alloc] init];
    self.endTripDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.endTripDatePicker addTarget:self action:@selector(updateTextFieldEnd :) forControlEvents:UIControlEventValueChanged];
    [self.endTripDateTextField setInputView: self.endTripDatePicker];
}

#pragma mark - updating UI

-(void)updateTextField:(UIDatePicker *)sender
{
    self.beginTripDatePicker.minimumDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *eventStartDate = self.beginTripDatePicker.date;
    self.userSpecifiedStartDate = eventStartDate;
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString1 = [dateFormat stringFromDate:eventStartDate];
    self.beginTripDateTextField.text = [NSString stringWithFormat:@"%@",dateString1];
}

-(void)updateTextFieldEnd:(UIDatePicker *)sender{
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        //TODO(Franklin): place API stuff like autocomplete here
        self.userSpecifiedPlaceToVisit = searchText;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    [self setUpDatePickers];
    self.searchLabel.alpha = 0;
    [UIView animateWithDuration:0.75 animations:^{
        searchBar.frame = self.searchBarEnd;
        self.beginTripDateTextField.frame = self.startDateFieldEnd;
        self.endTripDateTextField.frame = self.endDateFieldEnd;
        //self.beginTripDateTextField.alpha = 1;
        //self.endTripDateTextField.alpha = 1;
        self.headerLabel.alpha = 1;
        //self.dateLabel.frame = CGRectMake(30, 150, CGRectGetWidth(self.view.frame) - 60, CGRectGetHeight(self.view.frame) / 2 - 15);
        //self.dateLabel.alpha = 1;
    }];
    [self performSelector:@selector(fadeIn) withObject:self afterDelay:1.0];
}

- (void)fadeIn {
    [UIView animateWithDuration:0.75 animations:^{
        self.dateLabel.alpha = 1;
        self.beginTripDateTextField.alpha = 1;
        self.endTripDateTextField.alpha = 1;
    }];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    if (!CGRectEqualToRect(searchBar.frame, self.searchBarStart)) {
        [UIView animateWithDuration:0.25 animations:^{
            self.dateLabel.alpha = 0;
            self.beginTripDateTextField.alpha = 0;
            self.endTripDateTextField.alpha = 0;
            self.headerLabel.alpha = 0;
        }];
        [UIView animateWithDuration:1 animations:^{
            searchBar.frame = self.searchBarStart;
            self.beginTripDateTextField.frame = self.startDateFieldStart;
            self.endTripDateTextField.frame = self.endDateFieldStart;
        }];
        [self performSelector:@selector(fadeSearchLabel) withObject:self afterDelay:0.75];
    }
}

- (void)fadeSearchLabel {
    [UIView animateWithDuration:0.5 animations:^{
        self.searchLabel.alpha = 1;
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

#pragma mark - UIPIckerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 5;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

#pragma mark - FirstScreenViewController helper methods

- (void)setUpDatePickers {
    [self setUpBeginDateText];
    self.beginTripDateTextField.delegate = self;
    [self.view addSubview:self.beginTripDateTextField];
    [self setUpEndDateText];
    self.endTripDateTextField.delegate = self;
    [self.view addSubview:self.endTripDateTextField];
}

- (void)initiateLabels {
    self.headerLabel = makeHeaderLabel(@"Destination");
    self.headerLabel.frame = CGRectMake(15, 75, 500, 50);
    self.headerLabel.alpha = 0;
    [self.view addSubview:self.headerLabel];
    self.searchLabel = makeCenterLabel(@"Choose a destination:", self.view.frame);
    [self.view addSubview:self.searchLabel];
    self.dateLabel = makeCenterLabel(@"Choose a start and end date", self.view.frame);
    self.dateLabel.frame = CGRectMake(30, 150, CGRectGetWidth(self.view.frame) - 60, CGRectGetHeight(self.view.frame) / 2 - 15);
    self.dateLabel.alpha = 0;
    [self.view addSubview:self.dateLabel];
}

@end
