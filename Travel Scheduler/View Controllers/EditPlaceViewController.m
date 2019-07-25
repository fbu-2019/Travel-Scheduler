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

@interface EditPlaceViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *allEditInfo;

@end

static NSArray *makeTimeBlockArray(Place *place)
{
    if (place.scheduledTimeBlock % 2 == 0) {
        return @[@"Breakfast", @"Lunch", @"Dinner"];
    }
    return @[@"Morning", @"Afternoon", @"Evening"];
}

@implementation EditPlaceViewController

NSString *CellIdentifier = @"TableViewCell";
NSString *HeaderViewIdentifier = @"TableViewHeaderView";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self tableviewSetup];
    NSArray *availableTimeBlocks = makeTimeBlockArray(self.place);
    self.allEditInfo = @[@[@"Date", self.allDates], @[@"Time of day", availableTimeBlocks]];
    [self.tableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *editChoices = [self.allEditInfo[indexPath.section] lastObject];
    NSString *text;
    if (indexPath.section == 0) {
        NSDate *date = editChoices[indexPath.row];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEEE MM/dd/yyyy"];
        text = [dateFormat stringFromDate:date];
    } else {
        text = editChoices[indexPath.row];
    }
    cell = [[EditCell alloc] initWithString:text];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allEditInfo.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.allEditInfo[section] lastObject] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewIdentifier];
    header.textLabel.text = [self.allEditInfo[section] firstObject];
    return header;
}

#pragma mark - EditPlaceViewController helper functions

- (void)tableviewSetup
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[EditCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderViewIdentifier];
    [self.view addSubview:self.tableView];
}

@end
