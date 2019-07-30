//
//  HomeCollectionsViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "PlacesToVisitTableViewCell.h"
#import "AttractionCollectionCell.h"
#import "MoreOptionViewController.h"
#import "TravelSchedulerHelper.h"
#import "Date.h"
#import "DetailsViewController.h"
#import "Place.h"
#import "APITesting.h"
#import "PlaceObjectTesting.h"
#import "SlideMenuUIView.h"
#import "ScheduleViewController.h"
@import GoogleMaps;
@import GooglePlaces;

@interface HomeCollectionViewController () <UITableViewDelegate, UITableViewDataSource, PlacesToVisitTableViewCellDelegate, DetailsViewControllerSetSelectedProtocol, PlacesToVisitTableViewCellSetSelectedProtocol>

@property(nonatomic, strong) UIButton *buttonToMenu;
@property(nonatomic, strong) SlideMenuUIView *leftViewToSlideIn;
@property(nonatomic, strong) UIButton *closeLeft;

@end

static int tableViewBottomSpace = 300;

@implementation HomeCollectionViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    int tableViewHeight = CGRectGetHeight(self.view.frame) - tableViewBottomSpace;
    int tableViewY = 150;
    self.homeTable = [[UITableView alloc] initWithFrame:CGRectMake(5, tableViewY, CGRectGetWidth(self.view.frame) - 15, tableViewHeight) style:UITableViewStylePlain];
    self.homeTable.delegate = self;
    self.homeTable.dataSource = self;
    self.homeTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.homeTable setAllowsSelection:YES];
    [self.view addSubview:self.homeTable];
    UILabel *label = makeHeaderLabel(@"Places to Visit");
    [self.view addSubview:label];
    self.scheduleButton = makeButton(@"Generate Schedule", CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), tableViewY + tableViewHeight);
    [self.scheduleButton addTarget:self action:@selector(makeSchedule) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scheduleButton];
    [self makeCloseButton];
    [self.homeTable reloadData];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.homeTable addSubview: _refreshControl];
    [self.homeTable sendSubviewToBack: self.refreshControl];
    [self createButtonToMenu];
    [self.view addSubview:self.buttonToMenu];
    [self createInitialSlideView];
    if(self.arrayOfSelectedPlaces == nil) {
        self.arrayOfSelectedPlaces = [[NSMutableArray alloc] init];
    }
}

#pragma mark - Setting up refresh control

- (void)handleRefresh:(UIRefreshControl *)refreshControl
{
    [self.homeTable reloadData];
    [self.homeTable layoutIfNeeded];
    [refreshControl endRefreshing];
}

#pragma mark - Methods to Create Menu Button and Action

-(void) createButtonToMenu
{
    self.buttonToMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonToMenu.backgroundColor = [UIColor whiteColor];
    [self.buttonToMenu setFrame:CGRectMake(350, 100, 50, 40)];
    [self.buttonToMenu setBackgroundImage:[UIImage imageNamed:@"menu_icon"] forState: UIControlStateNormal];
    self.buttonToMenu.layer.cornerRadius = 10;
    self.buttonToMenu.clipsToBounds = YES;
    [self.buttonToMenu addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
}

- (void) buttonClicked: (id)sender
{
    [self animateView];
    [self.leftViewToSlideIn createButtonToCloseSlideIn];
}

#pragma mark - Method to create slide view

- (void) createInitialSlideView
{
    self.leftViewToSlideIn = [[SlideMenuUIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), 0, 0 , 400)];
    [self.leftViewToSlideIn loadView];
    self.leftViewToSlideIn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.leftViewToSlideIn];
}

#pragma mark - Method to animate slide in view

- (void) animateView
{
    [UIView animateWithDuration: 0.75 animations:^{
        self.leftViewToSlideIn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-300, 0, 300 , 4000);
    }];
}

- (void) makeCloseButton
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(returnToFirstScreen:)];
    [self.navigationItem setLeftBarButtonItem:item animated:YES];
}

- (void)returnToFirstScreen:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    PlacesToVisitTableViewCell *cell = (PlacesToVisitTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[PlacesToVisitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        CGRect myFrame = CGRectMake(10.0, 0.0, 220, 25.0);
        cell.labelWithSpecificPlaceToVisit = [[UILabel alloc] initWithFrame:myFrame];
        cell.hub = self.hub;
        if(indexPath.row == 0){
            [cell setUpCellOfType:@"attractions"];
        } else if (indexPath.row == 1) {
            [cell setUpCellOfType:@"restaurant"];
        } else if (indexPath.row == 2){
            [cell setUpCellOfType:@"lodging"];
        }
        cell.labelWithSpecificPlaceToVisit.font = [UIFont boldSystemFontOfSize:17.0];
        cell.labelWithSpecificPlaceToVisit.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:cell.labelWithSpecificPlaceToVisit];
    }
    cell.delegate = self;
    cell.setSelectedDelegate = self;
    [cell.collectionView reloadData];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(PlacesToVisitTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewIndexPath:indexPath];
    NSInteger index = indexPath.row;
    CGFloat horizontalOffset = [cell.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(PlacesToVisitTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat horizontalOffset = cell.collectionView.contentOffset.x;
    NSInteger index = indexPath.row;
    cell.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    long cellNum = indexPath.row;
    MoreOptionViewController *moreOptionViewController = [[MoreOptionViewController alloc] init];
    moreOptionViewController.places = [[NSMutableArray alloc]init];
    moreOptionViewController.hub = self.hub;
    if (cellNum == 0) {
        moreOptionViewController.stringType = @"Attractions";
        NSMutableSet *set = [NSMutableSet setWithArray:self.hub.dictionaryOfArrayOfPlaces[@"museum"]];
        [set addObjectsFromArray:self.hub.dictionaryOfArrayOfPlaces[@"park"]];
        moreOptionViewController.places = (NSMutableArray *)[set allObjects];
    } else if (cellNum == 1) {
        moreOptionViewController.stringType = @"Restaurants";
        moreOptionViewController.places = self.hub.dictionaryOfArrayOfPlaces[@"restaurant"];
    } else if (cellNum == 2) {
        moreOptionViewController.stringType = @"Hotels";
        moreOptionViewController.places = self.hub.dictionaryOfArrayOfPlaces[@"lodging"];
    }
    [self.navigationController pushViewController:moreOptionViewController animated:true];
    return indexPath;
}

#pragma mark - PlacesToVisitTableViewCell delegate
- (void)placesToVisitCell:(nonnull PlacesToVisitTableViewCell *)placeToVisitCell didTap:(nonnull Place *)place
{
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] init];
    detailsViewController.place = place;
    detailsViewController.setSelectedDelegate = self;
    [self.navigationController pushViewController:detailsViewController animated:true];
}

#pragma mark - segue to schedule

- (void)makeSchedule
{
    if(self.arrayOfSelectedPlaces.count > 0) {
        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:TRUE];
        ScheduleViewController *destView = (ScheduleViewController *)[[self.tabBarController.viewControllers objectAtIndex:1] topViewController];
        destView.selectedPlacesArray = self.arrayOfSelectedPlaces;
        destView.home = self.hub;
        [self.tabBarController setSelectedIndex: 1];
    }
}

#pragma mark - DetailsViewControllerSetSelectedProtocol
- (void)updateSelectedPlacesArrayWithPlace:(nonnull Place *)place
{
    if(place.selected) {
        place.selected = NO;
        [self.arrayOfSelectedPlaces removeObject:place];
    } else {
        place.selected = YES;
        [self.arrayOfSelectedPlaces addObject:place];
    }
    [self.homeTable reloadData];
}
    
#pragma mark - PlacesToVisitTableViewCellSetSelectedProtocol
- (void)updateSelectedPlacesArrayViaAttractionCellWithPlace:(nonnull Place *)place
{
    [self updateSelectedPlacesArrayWithPlace:place];
}
    
@end


