//
//  CommuteDetailsViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 8/2/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "CommuteDetailsViewController.h"
#import "TravelStepCell.h"

@interface CommuteDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation CommuteDetailsViewController

NSString *travelCellIdentifier = @"TravelStepCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *titleString = [NSString stringWithFormat:@"To %@", self.commute.destination.name];
    self.headerLabel = makeHeaderLabel(titleString, 22);
    [self.view addSubview:self.headerLabel];
    
    [self createTableView];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.headerLabel.frame = CGRectMake(15, self.topLayoutGuide.length + 10, CGRectGetWidth(self.view.frame) - 30, CGRectGetHeight(self.view.frame));
    [self.headerLabel sizeToFit];
    self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, CGRectGetHeight(self.view.frame) - (CGRectGetMaxY(self.headerLabel.frame) + 15));
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    TravelStepCell *cell = [tableView dequeueReusableCellWithIdentifier:travelCellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell = [[TravelStepCell alloc] initWithPlace:self.commute.origin];
    } else if (indexPath.row == self.commute.arrayOfSteps.count + 1) {
        cell = [[TravelStepCell alloc] initWithPlace:self.commute.destination];
    } else {
        cell = [[TravelStepCell alloc] initWithStep:self.commute.arrayOfSteps[indexPath.row - 1]];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commute.arrayOfSteps.count + 2;
}

//- (NSInteger)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
//{
//    return UITableViewAutomaticDimension;
//}

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[TravelStepCell class] forCellReuseIdentifier:travelCellIdentifier];
    [self.view addSubview:self.tableView];
}

@end
