//
//  EditPlaceViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/25/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "EditPlaceViewController.h"
#import "EditCell.h"
#import "Place.h"

@interface EditPlaceViewController () <UITableViewDelegate, UITableViewDataSource, EditCellDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *allEditInfo;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *doneButton;

@end

static NSArray *makeTimeBlockArray(Place *place)
{
    return (place.scheduledTimeBlock % 2 == 0) ? @[@"Breakfast", @"Lunch", @"Dinner"] : @[@"Morning", @"Afternoon", @"Evening"];
}

static UIButton *makeNavButton(NSString *string, int xCoord)
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:string forState:UIControlStateNormal];
    return button;
}

@implementation EditPlaceViewController

NSString *CellIdentifier = @"TableViewCell";
NSString *HeaderViewIdentifier = @"TableViewHeaderView";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self tableviewSetup];
    [self setupButton];
    NSArray *availableTimeBlocks = makeTimeBlockArray(self.place);
    self.allEditInfo = @[@[@"Date", self.allDates], @[@"Time of day", availableTimeBlocks], @[@"", @[]]];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.cancelButton.frame = CGRectMake(10, 35, 50, 35);
    self.doneButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 60, 35, 50, 35);
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.cancelButton.frame) + 25, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.cancelButton.frame));
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *editChoices = [self.allEditInfo[indexPath.section] lastObject];
    if (indexPath.section == 0) {
        NSDate *date = editChoices[indexPath.row];
        cell = [[EditCell alloc] initWithDate:date];
        if (self.place.tempDate == date) {
            [cell makeSelection:CGRectGetWidth(self.view.frame)];
        }
    } else {
        cell = [[EditCell alloc] initWithString:editChoices[indexPath.row]];
        cell.indexPath = indexPath.row;
        int index;
        index = (self.place.scheduledTimeBlock % 2 == 0) ? self.place.tempBlock / 2 : (self.place.tempBlock - 1) / 2;
        if (index == indexPath.row) {
            [cell makeSelection:CGRectGetWidth(self.view.frame)];
        }
    }
    cell.delegate = self;
    cell.place = self.place;
    cell.width = CGRectGetWidth(self.view.frame);
    [cell createAllProperties];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.allEditInfo.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.allEditInfo[section] lastObject] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewIdentifier];
    [[header subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addBackgroundView:header inSection:section];
    UILabel *label = [self addLabel:tableView forSection:section];
    [header addSubview:label];
    if (section == 0) {
        [self addPropertiesToHeader:header];
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView:tableView numberOfRowsInSection:section] == 0) {
        return CGRectGetHeight(self.view.frame) - 400;
    }
    return (section == 0) ? 150 : 65;
}

#pragma mark - EditPlaceViewController helper functions

- (void)tableviewSetup
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = false;
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderViewIdentifier];
    [self.view addSubview:self.tableView];
}

- (UILabel *)addLabel:(UITableView *)tableView forSection:(NSInteger) section
{
    UILabel *label = [[UILabel alloc] init];
    label.text = [self.allEditInfo[section] firstObject];
    UIFont *font = [UIFont systemFontOfSize:20];
    [label setFont:font];
    [label sizeToFit];
    int height = [self tableView:tableView heightForHeaderInSection:section];
    label.frame = CGRectMake(10, height - CGRectGetHeight(label.frame) - 10, CGRectGetWidth(self.view.frame), CGRectGetHeight(label.frame) + 5);
    return label;
}

- (void)setupButton
{
    self.cancelButton = makeNavButton(@"Cancel", 15);
    self.doneButton = makeNavButton(@"Done", CGRectGetWidth(self.view.frame) - 65);
    [self.cancelButton addTarget:self action:@selector(cancelNav) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton addTarget:self action:@selector(doneNav) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.doneButton];
}

#pragma mark - Action: Navigation

- (void)doneNav
{
    if (self.place.locked) {
        self.scheduleController.removeLockedDate = self.place.date;
        self.scheduleController.removeLockedTime = self.place.scheduledTimeBlock;
    }
    self.place.date = self.place.tempDate;
    self.place.scheduledTimeBlock = self.place.tempBlock;
    self.place.locked = YES;
    self.scheduleController.nextLockedPlace = self.place;
    [self.scheduleController setUpAllData];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancelNav
{
    self.place.tempDate = self.place.date;
    self.place.tempBlock = self.place.scheduledTimeBlock;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)addPropertiesToHeader:(UITableViewHeaderFooterView *)header
{
    UIImageView *imageView = makeImage(self.place.iconUrl);
    imageView.frame = CGRectMake(5, 5, 45, 45);
    [header addSubview:imageView];
    int xCoord = imageView.frame.origin.x + CGRectGetWidth(imageView.frame) + 10;
    UILabel *placeName = makeSubHeaderLabel(self.place.name, 30);
    [header addSubview:placeName];
    placeName.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 10, imageView.frame.origin.y + (CGRectGetHeight(imageView.frame) / 2) - (CGRectGetHeight(placeName.frame) / 2), CGRectGetWidth(self.view.frame) - CGRectGetMaxX(imageView.frame) - 20, CGRectGetHeight(placeName.frame));
    [placeName sizeToFit];
    placeName.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 10, imageView.frame.origin.y + (CGRectGetHeight(imageView.frame) / 2) - (CGRectGetHeight(placeName.frame) / 2), CGRectGetWidth(placeName.frame), CGRectGetHeight(placeName.frame));
    int height = getMax(CGRectGetMaxY(imageView.frame), CGRectGetMaxY(placeName.frame));
    header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y, CGRectGetWidth(header.frame), height);
}

- (void)addBackgroundView:(UITableViewHeaderFooterView *)header inSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), [self tableView:self.tableView heightForHeaderInSection:section])];
    view.backgroundColor = [UIColor colorWithRed: 150 green:100 blue:100 alpha:1];
    [header addSubview:view];
}

#pragma mark - EditCell delegate

- (void)editCell:(EditCell *)editCell didTap:(Place *)place
{
    if (editCell.date) {
        place.tempDate = editCell.date;
    } else {
        place.tempBlock = (place.scheduledTimeBlock % 2 == 0) ? (2 * editCell.indexPath) : (2 * editCell.indexPath + 1);
    }
    [self.tableView reloadData];
}

@end
