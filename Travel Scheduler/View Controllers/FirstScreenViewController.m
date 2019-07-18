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
@property(strong, nonatomic) UILabel *toSeperater;

@end

@implementation FirstScreenViewController

#pragma mark - Cell LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect screenFrame = self.view.frame;
    self.placesSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(2, CGRectGetHeight(screenFrame)/2, CGRectGetWidth(screenFrame) - 4, 50)];
    self.placesSearchBar.delegate = self;
    self.placesSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.placesSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.placesSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.placesSearchBar.backgroundColor = [UIColor blackColor];
    self.placesSearchBar.placeholder = @"Search destination of choice ...";
    [self.view addSubview:self.placesSearchBar];
    self.beginTripDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, CGRectGetHeight(screenFrame)/1.7, 200, 50)];
    self.beginTripDateTextField.backgroundColor = [UIColor whiteColor];
    self.beginTripDateTextField.placeholder = @"Enter start date";
    self.beginTripDateTextField.delegate = self;
    [self.view addSubview:self.beginTripDateTextField];
    self.beginTripDatePicker = [[UIDatePicker alloc] init];
    [self.beginTripDatePicker setDate:[NSDate date]];
    self.beginTripDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.beginTripDatePicker addTarget:self action:@selector(updateTextField :) forControlEvents:UIControlEventValueChanged];
    [self.beginTripDateTextField setInputView: self.beginTripDatePicker];
    self.toSeperater = [[UILabel alloc] initWithFrame:CGRectMake(170, CGRectGetHeight(screenFrame)/1.7, 200, 45)];
    self.toSeperater.backgroundColor = [UIColor whiteColor];
    self.toSeperater.text = @"     to";
    [self.view addSubview:self.toSeperater];
    self.endTripDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(245, CGRectGetHeight(screenFrame)/1.7, 200, 50)];
    self.endTripDateTextField.backgroundColor = [UIColor whiteColor];
    self.endTripDateTextField.textAlignment = NSTextAlignmentNatural;
    self.endTripDateTextField.placeholder = @"Enter end date";
    self.endTripDateTextField.delegate = self;
    [self.view addSubview:self.endTripDateTextField];
    self.endTripDatePicker = [[UIDatePicker alloc] init];
    self.endTripDatePicker.datePickerMode = UIDatePickerModeDate;
    [self.endTripDatePicker addTarget:self action:@selector(updateTextField :) forControlEvents:UIControlEventValueChanged];
    [self.endTripDateTextField setInputView: self.endTripDatePicker];
}

#pragma mark - updating UI

-(void)updateTextField:(UIDatePicker *)sender
{
    self.endTripDateTextField.text = [self.dateFormat stringFromDate:sender.date];
    [self.beginTripDatePicker setMaximumDate:[NSDate date]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSDate *evenStartDate = self.beginTripDatePicker.date;
    NSDate *eventEndDate = self.endTripDatePicker.date;
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString *dateString1 = [dateFormat stringFromDate:evenStartDate];
    NSString *dateString2 = [dateFormat stringFromDate:eventEndDate];
    self.beginTripDateTextField.text = [NSString stringWithFormat:@"%@",dateString1];
    self.endTripDateTextField.text = [NSString stringWithFormat:@"%@",dateString2];
    NSLog(@"%@", self.beginTripDateTextField.text);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - UISearchBar delegate method

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        //place API stuff like autocomplete here
    }
}

#pragma mark - UIPIckerView delegate methods

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 4;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 4;
}



@end
