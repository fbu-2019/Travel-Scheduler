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
#import "PlaceWebsiteViewController.h"

@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource, DetailsViewSetSelectedPlaceProtocol, DetailsViewGoToWebsiteDelegate>

@property (nonatomic, strong) CommentsCell *prototypeCell;

@end

static const NSString *kCommentsCellIdentifier = @"CommentsCell";

@implementation DetailsViewController

#pragma mark - DetailsViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePreferredContentSize:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    [self tableViewIntiation];
    [self makeArrayOfComments];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (CommentsCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:kCommentsCellIdentifier];
    }
    return _prototypeCell;
}


#pragma mark - UITableView delegate & data source

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    int width = CGRectGetWidth(self.view.frame);
   if(indexPath.row == 0) {
    DetailHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailHeaderCell"];
    if (!cell) {
        cell = [[DetailHeaderCell alloc] initWithWidth:width andPlace:self.place];
        cell.isCommingFromSchedule = self.isCommingFromSchedule;
        [cell setGoingButtonState];
        cell.selectedPlaceProtocolDelegate = self;
        cell.goToWebsiteProtocolDelegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    self.headerHeight = CGRectGetHeight(cell.contentView.frame);
    return cell;
  }
   CommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentsCell"];
   if(!cell) {
       cell = [[CommentsCell alloc]initWithWidth:width andComment:self.arrayOfComments[indexPath.row - 1]];
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    if (indexPath.row == 0) {
        return self.headerHeight;
    }
    self.prototypeCell = [[CommentsCell alloc]initWithWidth:CGRectGetWidth(self.view.frame) andComment:self.arrayOfComments[indexPath.row - 1]];
    [self.prototypeCell layoutIfNeeded];
    return getMax(CGRectGetMaxY(self.prototypeCell.commentTextLabel.frame), CGRectGetMaxY(self.prototypeCell.userProfileImage.frame)) + 25;
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
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        });
    }];
}
    
#pragma mark - DetailsViewController helper

- (void)tableViewIntiation
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
}

#pragma mark - DetailsViewSetSelectedPlaceProtocol
- (void)updateSelectedPlacesArrayWithPlace:(nonnull Place *)place
{
    [self.setSelectedDelegate updateSelectedPlacesArrayWithPlace:self.place];
}
    
#pragma mark - DetailsViewGoToWebsiteDelegate
- (void)goToWebsiteWithLink:(NSString *)linkString
{
    PlaceWebsiteViewController *placeWebsiteViewController = [[PlaceWebsiteViewController alloc] init];
    placeWebsiteViewController.websiteURL = linkString;
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.navigationController pushViewController:placeWebsiteViewController animated:true];
    });
}
    
@end
