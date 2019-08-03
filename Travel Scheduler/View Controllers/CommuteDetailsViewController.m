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
@property (nonatomic, strong) TravelStepCell *prototypeCell;
@property (strong, nonatomic) NSMutableDictionary *cellHeights;

@end

@implementation CommuteDetailsViewController

NSString *travelCellIdentifier = @"TravelStepCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePreferredContentSize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    self.cellHeights = [[NSMutableDictionary alloc] init];
    
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
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, 10000);
}

- (void)viewDidLayoutSubviews
{
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, [[[self.cellHeights allValues] valueForKeyPath: @"@sum.self"] floatValue]);
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [self.tableView reloadData];
//    [self.tableView layoutIfNeeded];
//    self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, [[[self.cellHeights allValues] valueForKeyPath: @"@sum.self"] floatValue]);
//}

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
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:travelCellIdentifier];
    }
    return _prototypeCell;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    TravelStepCell *cell = (TravelStepCell *)[tableView dequeueReusableCellWithIdentifier:travelCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        if (indexPath.row == 0) {
            cell = [[TravelStepCell alloc] initWithPlace:self.commute.origin];
        } else if (indexPath.row == self.commute.arrayOfSteps.count + 1) {
            cell = [[TravelStepCell alloc] initWithPlace:self.commute.destination];
        } else {
            cell = [[TravelStepCell alloc] initWithStep:self.commute.arrayOfSteps[indexPath.row - 1]];
        }
    } else {
        if (indexPath.row == 0) {
            [cell setTravelPlace:self.commute.origin];
        } else if (indexPath.row == self.commute.arrayOfSteps.count + 1) {
            [cell setTravelPlace:self.commute.destination];
        } else {
            [cell setTravelStep:self.commute.arrayOfSteps[indexPath.row - 1]];
        }
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commute.arrayOfSteps.count + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        self.prototypeCell = [[TravelStepCell alloc] initWithPlace:self.commute.origin];
    } else if (indexPath.row == self.commute.arrayOfSteps.count + 1) {
        self.prototypeCell = [[TravelStepCell alloc] initWithPlace:self.commute.destination];
    } else {
        self.prototypeCell = [[TravelStepCell alloc] initWithStep:self.commute.arrayOfSteps[indexPath.row - 1]];
    }
    [self.prototypeCell layoutIfNeeded];
    CGFloat height = getMax(70, CGRectGetMaxY(self.prototypeCell.subLabel.frame) + 10);
    [self.cellHeights setObject:@(height) forKey:@(indexPath.row)];
    return height;
}

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
