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

@property (strong, nonatomic) UITableView *tableView;

@end

#pragma mark - DetailsViewController lifecycle

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate & data source

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DetailHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailHeaderCell"];
    if (!cell) {
        cell = [[DetailHeaderCell alloc] init];
    }
    cell.contentView.frame = CGRectMake(10.0f, 0, CGRectGetWidth(self.tableView.frame), cell.frame.size.height);
    [cell makeCell];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 500;
    }
    return 50;
}

@end
