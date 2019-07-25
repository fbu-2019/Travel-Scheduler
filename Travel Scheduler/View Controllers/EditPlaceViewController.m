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
    self.allEditInfo = @[@[@"Date", self.allDates], @[@"Time of day", availableTimeBlocks], @[@"", @[]]];
    [self.tableView reloadData];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSArray *editChoices = [self.allEditInfo[indexPath.section] lastObject];
    if (indexPath.section == 0) {
        NSDate *date = editChoices[indexPath.row];
        cell = [[EditCell alloc] initWithDate:date];
        if (self.place.date == date) {
            [cell makeSelection:CGRectGetWidth(self.view.frame)];
        }
    } else {
        cell = [[EditCell alloc] initWithString:editChoices[indexPath.row]];
        cell.indexPath = indexPath.row;
        if (self.place.scheduledTimeBlock == indexPath.row) {
            [cell makeSelection:CGRectGetWidth(self.view.frame)];
        }
    }
    cell.delegate = self;
    cell.place = self.place;
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
    UILabel *label = [self addLabel:tableView forSection:section];
    [header addSubview:label];
    if (section == 0) {
        UIImageView *imageView = makeImage(self.place.iconUrl);
        imageView.frame = CGRectMake(10, 35, CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
        [header addSubview:imageView];
        int xCoord = imageView.frame.origin.x + CGRectGetWidth(imageView.frame) + 10;
        UILabel *placeName = makeLabel(70, 35, self.place.name, self.view.frame, [UIFont systemFontOfSize:30]);
        placeName.frame = CGRectMake(70, imageView.frame.origin.y + (CGRectGetHeight(imageView.frame) / 2) - (CGRectGetHeight(placeName.frame) / 2), CGRectGetWidth(placeName.frame), CGRectGetHeight(placeName.frame));
        [header addSubview:placeName];
        int height = getMax(150, placeName.frame.origin.y + CGRectGetHeight(placeName.frame));
        header.frame = CGRectMake(header.frame.origin.x, header.frame.origin.y, CGRectGetWidth(header.frame), height);
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView numberOfRowsInSection:section] == 0) {
        return CGRectGetHeight(self.view.frame) - 400;
    }
    if (section == 0) {
        return 150;
    } else {
        return 65;
    }
}

#pragma mark - EditPlaceViewController helper functions

- (void)tableviewSetup
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
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

#pragma mark - EditCell delegate

- (void)editCell:(EditCell *)editCell didTap:(Place *)place {
    if (editCell.date) {
        place.date = editCell.date;
    } else {
        place.scheduledTimeBlock = editCell.indexPath;
    }
    [self.tableView reloadData];
}

@end
