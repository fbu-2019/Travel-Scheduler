//
//  DetailsViewController.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "DetailsViewController.h"
#import "DetailHeaderCell.h"

@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation DetailsViewController

#pragma mark - DetailsViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.selectedPlacesArray == nil) {
        self.selectedPlacesArray = [[NSMutableArray alloc] init];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self tableViewIntiation];
}

#pragma mark - UITableView delegate & data source
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    DetailHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailHeaderCell"];
    int width = CGRectGetWidth(self.view.frame);
    if (!cell) {
        cell = [[DetailHeaderCell alloc] initWithWidth:width andPlace:self.place];
    }
    self.headerHeight = CGRectGetHeight(cell.contentView.frame);
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return self.headerHeight;
    }
    return 50;
}

#pragma mark - DetailsViewController helper
- (void)tableViewIntiation
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
}

@end
