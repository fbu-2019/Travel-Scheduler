//
//  DetailsViewController.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "DetailsViewController.h"
#import "DetailHeaderCell.h"
#import "APIManager.h"
#import "CommentsCell.h"

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
    [self makeArrayOfComments];
}

#pragma mark - UITableView delegate & data source

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    int width = CGRectGetWidth(self.view.frame);
   if(indexPath.row == 0) {
    DetailHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailHeaderCell"];
    if (!cell) {
        cell = [[DetailHeaderCell alloc] initWithWidth:width andPlace:self.place];
    }
    self.headerHeight = CGRectGetHeight(cell.contentView.frame);
    return cell;
  }
   CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentsCell"];
   if(!cell) {
       cell = [[CommentsCell alloc]initWithWidth:width andComment:self.arrayOfComments[indexPath.row - 1]];
       return cell;
    }
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayOfComments.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == 0) ? self.headerHeight : 150;
}

#pragma mark - Comment methods
- (void)makeArrayOfComments
{
    [[APIManager shared]getCompleteInfoOfLocationWithId:self.place.placeId withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            self.arrayOfComments = placeInfoDictionary[@"reviews"];
        } else {
            NSLog(@"problem here");
        }
        [self.tableView reloadData];
    }];
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
