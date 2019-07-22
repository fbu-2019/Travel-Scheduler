//
//  FirstScreenViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "FirstScreenViewController.h"


@interface FirstScreenViewController ()<UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property(strong, nonatomic) UISearchBar *placesSearchBar;
@property(strong, nonatomic) NSDateFormatter *dateFormat;
@property(strong, nonatomic) NSString *firstDateString;
@property(strong, nonatomic) NSString *userSpecifiedPlaceToVisit;
@property(strong, nonatomic) NSDate *userSpecifiedStartDate;
@property(strong, nonatomic) NSDate *userSpecifiedEndDate;

@end

@implementation FirstScreenViewController

#pragma mark - Cell LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.placesSearchBar.delegate = self;
    [self setUpPlacesSearchBar];
    [self.view addSubview:self.placesSearchBar];
    [self setUpBeginDateText];
    self.beginTripDateTextField.delegate = self;
    [self.view addSubview:self.beginTripDateTextField];
    [self setUpEndDateText];
    self.endTripDateTextField.delegate = self;
    [self.view addSubview:self.endTripDateTextField];
}

#pragma mark - Setting up search bar

-(void)setUpPlacesSearchBar{
    CGRect screenFrame = self.view.frame;
    self.placesSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(2, CGRectGetHeight(screenFrame)/2, CGRectGetWidth(screenFrame) - 4, 50)];
    self.placesSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.placesSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.placesSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.placesSearchBar.backgroundColor = [UIColor blackColor];
    self.placesSearchBar.placeholder = @"Search destination of choice ...";
}

#pragma mark - Setting up BeginDateTextField

-(void)setUpBeginDateText{
    CGRect screenFrame = self.view.frame;
    self.beginTripDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, CGRectGetHeight(screenFrame)/1.7, 200, 50)];
    self.beginTripDateTextField.backgroundColor = [UIColor whiteColor];
    self.beginTripDateTextField.text = nil;
    self.beginTripDateTextField.placeholder = @"Enter start date";
    self.beginTripDatePicker = [[UIDatePicker alloc] init];
    [self.beginTripDatePicker setDate:[NSDate date]];
    self.beginTripDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.beginTripDatePicker addTarget:self action:@selector(updateTextField :) forControlEvents:UIControlEventValueChanged];
    [self.beginTripDateTextField setInputView: self.beginTripDatePicker];
    self.endTripDateTextField.text = nil;
}

#pragma mark - Setting up EndDateTextField

-(void)setUpEndDateText{
    CGRect screenFrame = self.view.frame;
    self.endTripDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(245, CGRectGetHeight(screenFrame)/1.7, 200, 50)];
    self.endTripDateTextField.backgroundColor = [UIColor whiteColor];
    self.endTripDateTextField.textAlignment = NSTextAlignmentNatural;
    self.endTripDateTextField.text = nil;
    self.endTripDateTextField.placeholder = @"Enter end date";
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

#pragma mark - UIPIckerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 5;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}

@end
