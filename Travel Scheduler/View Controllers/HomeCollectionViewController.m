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
#import "DetailsViewController.h"
#import "Place.h"
#import "APITesting.h"
#import "PlaceObjectTesting.h"
@import GoogleMaps;
@import GooglePlaces;


@interface HomeCollectionViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, AttractionCollectionCellDelegate>

@property(strong, nonatomic) UITableView *homeTable;
@property(strong, nonatomic) UITableViewCell *placesToVisitCell;
@property(strong, nonatomic) NSArray *arrayOfTypes;
@property(nonatomic, strong) NSMutableDictionary *dictionaryOfLocationsArray;
@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (strong, nonatomic) UIButton *scheduleButton;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic)bool areWeInAttractions;
@property(nonatomic)bool areWeInLodging;
@property(nonatomic)bool areWeInRestaurant;



@end

static int tableViewBottomSpace = 300;

@implementation HomeCollectionViewController {
    GMSPlacesClient *_placesClient;
}

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
    [self.homeTable reloadData];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.homeTable addSubview: _refreshControl];
    [self.homeTable sendSubviewToBack: self.refreshControl];
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    [self.homeTable reloadData];
    [self.homeTable layoutIfNeeded];
    [refreshControl endRefreshing];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    PlacesToVisitTableViewCell *cell = (PlacesToVisitTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[PlacesToVisitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        CGRect myFrame = CGRectMake(10.0, 0.0, 220, 25.0);
        cell.labelWithSpecificPlaceToVisit = [[UILabel alloc] initWithFrame:myFrame];
        cell.hub = self.hub;
        cell.arrayOfPlaces = [[NSMutableArray alloc] init];
        if(indexPath.row == 0){
            self.areWeInAttractions = YES;
            self.areWeInLodging = NO;
            self.areWeInRestaurant = NO;
            cell.labelWithSpecificPlaceToVisit.text = @"Attractions";
            cell.typeOfPlaces = @"attractions";
            NSMutableSet *set = [NSMutableSet setWithArray:self.hub.dictionaryOfArrayOfPlaces[@"museum"]];
            [set addObjectsFromArray:self.hub.dictionaryOfArrayOfPlaces[@"park"]];
            cell.arrayOfPlaces = (NSMutableArray *)[set allObjects];
        }
        else if (indexPath.row == 1) {
            self.areWeInAttractions = NO;
            self.areWeInLodging = NO;
            self.areWeInRestaurant = YES;
            cell.labelWithSpecificPlaceToVisit.text = @"Restaurants";
            cell.typeOfPlaces = @"restaurant";
            cell.arrayOfPlaces = self.hub.dictionaryOfArrayOfPlaces[cell.typeOfPlaces];
        }
        else if (indexPath.row == 2){
            self.areWeInAttractions = NO;
            self.areWeInLodging = YES;
            self.areWeInRestaurant = NO;
            cell.labelWithSpecificPlaceToVisit.text = @"Hotels";
            cell.typeOfPlaces = @"lodging";
            cell.arrayOfPlaces = self.hub.dictionaryOfArrayOfPlaces[cell.typeOfPlaces];
        }
        cell.labelWithSpecificPlaceToVisit.font = [UIFont boldSystemFontOfSize:17.0];
        cell.labelWithSpecificPlaceToVisit.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:cell.labelWithSpecificPlaceToVisit];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(PlacesToVisitTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    NSInteger index = cell.placesToVisitCollectionView.indexPath.row;
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(PlacesToVisitTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat horizontalOffset = cell.collectionView.contentOffset.x;
    NSInteger index = cell.placesToVisitCollectionView.indexPath.row;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int cellNum = indexPath.row;
    MoreOptionViewController *moreOptionViewController = [[MoreOptionViewController alloc] init];
    if (cellNum == 0) {
        moreOptionViewController.stringType = @"Attractions";
    } else if (cellNum == 1) {
        moreOptionViewController.stringType = @"Restaurants";
    } else if (cellNum == 2) {
        moreOptionViewController.stringType = @"Hotels";
    }
    [self.navigationController pushViewController:moreOptionViewController animated:true];
    return indexPath;
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];

    cell.delegate = self;
    if (self.areWeInAttractions) {
        cell.place = self.hub.dictionaryOfArrayOfPlaces[@"restaurant"][indexPath.row];
    }
    else if(self.areWeInRestaurant) {
        cell.place = self.hub.dictionaryOfArrayOfPlaces[@"museum"][indexPath.row];
    }
    else {
    cell.place = self.hub.dictionaryOfArrayOfPlaces[@"lodging"][indexPath.row];
    }
    
    [cell setImage];
    //[cell setImage];
    
    //TESTING PURPOSES ONLY
    //cell.place = [[Place alloc] init];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    PlacesToVisitCollectionView *collectionView = (PlacesToVisitCollectionView *)scrollView;
    NSInteger index = collectionView.indexPath.item;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

#pragma mark - AttractionCollectionCell delegate


- (void)attractionCell:(AttractionCollectionCell *)attractionCell didTap:(Place *)place {
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] init];
    detailsViewController.place = attractionCell.place;
    [self.navigationController pushViewController:detailsViewController animated:true];
}

#pragma mark - segue to schedule

- (void)makeSchedule {
    [self.tabBarController setSelectedIndex: 1];
}

@end


