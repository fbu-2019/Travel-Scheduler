//
//  CommuteDetailsViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 8/2/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "CommuteDetailsViewController.h"
#import "TravelStepCell.h"
#import "TravelSchedulerHelper.h"

@interface CommuteDetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) TravelStepCell *prototypeCell;
@property (strong, nonatomic) NSMutableDictionary *cellHeights;
@property (nonatomic) float commuteHeaderHeight;

@end

static UILabel *makeAndAddLabel(UITableViewCell *cell, NSString *string, float topY) {
    UILabel *label = makeSubHeaderLabel(string, 17);
    label.frame = CGRectMake(5, topY, 400, 50);
    [label sizeToFit];
    [cell.contentView addSubview:label];
    return label;
}

static const NSString *kTravelCellIdentifier = @"TravelStepCell";

@implementation CommuteDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePreferredContentSize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    self.cellHeights = [[NSMutableDictionary alloc] init];
    
    NSString *titleString = [NSString stringWithFormat:@"%@ to %@", self.commute.origin.name, self.commute.destination.name];
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
    self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, 10000);
}

- (void)viewDidLayoutSubviews
{
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    float tableViewHeight;
    float availableHeight = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.headerLabel.frame) - self.bottomLayoutGuide.length;
    float totalTableViewHeight = [[[self.cellHeights allValues] valueForKeyPath: @"@sum.self"] floatValue] + self.commuteHeaderHeight;
    if (availableHeight < totalTableViewHeight) {
        self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, availableHeight);
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.frame = CGRectMake(25, CGRectGetMaxY(self.headerLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 35, totalTableViewHeight);
        self.tableView.scrollEnabled = NO;
    }
}

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
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:kTravelCellIdentifier];
    }
    return _prototypeCell;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mapCellIdentifier"];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mapCellIdentifier"];
        }
        [self createCellContents:cell];
        return cell;
    }
    TravelStepCell *cell = (TravelStepCell *)[tableView dequeueReusableCellWithIdentifier:kTravelCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        if (indexPath.row == 1) {
            cell = [[TravelStepCell alloc] initWithPlace:self.commute.origin];
        } else if (indexPath.row == self.commute.arrayOfSteps.count + 2) {
            cell = [[TravelStepCell alloc] initWithPlace:self.commute.destination];
        } else {
            cell = [[TravelStepCell alloc] initWithStep:self.commute.arrayOfSteps[indexPath.row - 2]];
        }
    } else {
        if (indexPath.row == 1) {
            [cell setTravelPlace:self.commute.origin];
        } else if (indexPath.row == self.commute.arrayOfSteps.count + 2) {
            [cell setTravelPlace:self.commute.destination];
        } else {
            [cell setTravelStep:self.commute.arrayOfSteps[indexPath.row - 2]];
        }
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commute.arrayOfSteps.count + 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return self.commuteHeaderHeight;
    }
    if (indexPath.row == 1) {
        self.prototypeCell = [[TravelStepCell alloc] initWithPlace:self.commute.origin];
    } else if (indexPath.row == self.commute.arrayOfSteps.count + 2) {
        self.prototypeCell = [[TravelStepCell alloc] initWithPlace:self.commute.destination];
    } else {
        self.prototypeCell = [[TravelStepCell alloc] initWithStep:self.commute.arrayOfSteps[indexPath.row - 2]];
    }
    [self.prototypeCell layoutIfNeeded];
    CGFloat height = getMax(70, CGRectGetMaxY(self.prototypeCell.subLabel.frame) + 10);
    [self.cellHeights setObject:@(height) forKey:@(indexPath.row)];
    return height;
}

- (void)createCellContents:(UITableViewCell *)cell
{
    NSString *timeString = [NSString stringWithFormat:@"Time: %@", self.commute.durationString];
    UILabel *timeLabel = makeAndAddLabel(cell, timeString, 25);
    
    NSString *distString = [NSString stringWithFormat:@"Distance: %.01f km", [self.commute.distance floatValue] / 1000];
    UILabel *distLabel = makeAndAddLabel(cell, distString, CGRectGetMaxY(timeLabel.frame) + 10);
    
    NSString *cost = [self.commute.fare valueForKey:@"text"];
    NSString *costString = (cost) ? [NSString stringWithFormat:@"Cost: %@", cost] : @"Cost: free";
    UILabel *costLabel = makeAndAddLabel(cell, costString, CGRectGetMaxY(distLabel.frame) + 10);
    
    float xCoord = getMax(getMax(CGRectGetMaxX(timeLabel.frame), CGRectGetMaxX(distLabel.frame)), CGRectGetMaxX(costLabel.frame));
    UIView *mapView = [[UIView alloc] initWithFrame:CGRectMake(xCoord + 25, 0, CGRectGetWidth(self.view.frame) - xCoord - 20, CGRectGetMaxY(costLabel.frame) + 25)];
    mapView.backgroundColor = [UIColor grayColor];
    //TODO (Franklin): Add map image
    UITapGestureRecognizer *tappedMap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapSegue)];
    setupGRonImagewithTaps(tappedMap, mapView, 1);
    [cell addSubview:mapView];
    
    UILabel *commuteLabel = makeAndAddLabel(cell, @"Commute Details", CGRectGetMaxY(costLabel.frame) + 45);
    [commuteLabel setFont:[UIFont fontWithName:@"Gotham-Bold" size:20]];
    commuteLabel.frame = CGRectMake(commuteLabel.frame.origin.x, commuteLabel.frame.origin.y, CGRectGetWidth(self.view.frame), 50);
    [commuteLabel sizeToFit];
    self.commuteHeaderHeight = CGRectGetMaxY(commuteLabel.frame) + 5;
}

- (void)mapSegue
{
    //TODO (Franklin): make segue to map navigation
    //Note: here are the start and end places
    Place *startPlace = self.commute.origin;
    Place *endPlace = self.commute.destination;
}

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    [self.tableView setShowsVerticalScrollIndicator:NO];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[TravelStepCell class] forCellReuseIdentifier:kTravelCellIdentifier];
    [self.view addSubview:self.tableView];
}

@end
