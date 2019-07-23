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
#import "SlideMenuUIView.h"
@import GoogleMaps;
@import GooglePlaces;


@interface HomeCollectionViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, AttractionCollectionCellDelegate>

@property(strong, nonatomic) UITableView *homeTable;
@property(strong, nonatomic) UITableViewCell *placesToVisitCell;
@property(strong, nonatomic)NSArray *arrayOfTypes;
@property(nonatomic, strong) NSMutableDictionary *dictionaryOfLocationsArray;
@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (strong, nonatomic) UIButton *scheduleButton;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) UIButton *buttonToMenu;
@property(nonatomic, strong) SlideMenuUIView *leftViewToSlideIn;


@end

static int tableViewBottomSpace = 300;

@implementation HomeCollectionViewController {
    GMSPlacesClient *_placesClient;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Testing
  
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
    self.scheduleButton = generateScheduleButton(CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), tableViewY + tableViewHeight);
    [self.scheduleButton addTarget:self action:@selector(makeSchedule) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scheduleButton];
    [self.homeTable reloadData];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.homeTable addSubview: _refreshControl];
    [self.homeTable sendSubviewToBack: self.refreshControl];
    [self createButtonToMenu];
    [self.view addSubview:self.buttonToMenu];
    [self createInitialSlideView];
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    [self.homeTable reloadData];
    [self.homeTable layoutIfNeeded];
    [refreshControl endRefreshing];
}


-(void) createButtonToMenu{
    self.buttonToMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonToMenu.backgroundColor = [UIColor whiteColor];
    [self.buttonToMenu setFrame:CGRectMake(350, 100, 50, 40)];
    [self.buttonToMenu setBackgroundImage:[UIImage imageNamed:@"menu_icon"] forState: UIControlStateNormal];
    self.buttonToMenu.layer.cornerRadius = 10;
    self.buttonToMenu.clipsToBounds = YES;
    [self.buttonToMenu addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
}

- (void) createInitialSlideView{
    self.leftViewToSlideIn = [[SlideMenuUIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), 0, 0 , 400)];
    [self.leftViewToSlideIn loadView];
    self.leftViewToSlideIn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.leftViewToSlideIn];
    
   // [self.leftViewToSlideIn createButtonToCloseSlideInMenu];
    //[self.leftViewToSlideIn addSubview:self.leftViewToSlideIn.closeSlideInViewButton];
}

- (void) buttonClicked: (id)sender
{
    [self animateView];
}

- (void) animateView{
    [UIView animateWithDuration: 0.75 animations:^{
        self.leftViewToSlideIn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-300, 0, 300 , 4000);
        [self.leftViewToSlideIn createButtonToCloseSlideInMenu];
        [self.leftViewToSlideIn addSubview:self.leftViewToSlideIn.closeSlideInViewButton];
    }];
}


- (void) didTapOnPageView:(UITapGestureRecognizer *)sender{
    // TODO: Call method on delegate
    [self animateViewBackwards];
    
}

- (void) animateViewBackwards{
    [UIView animateWithDuration: 0.75 animations:^{
        self.leftViewToSlideIn.frame = CGRectMake(CGRectGetWidth(self.view.frame), 0, 0 , 400);
    }];
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
        if(indexPath.row == 0){
            cell.labelWithSpecificPlaceToVisit.text = @"Attractions";
        }
        else if (indexPath.row == 1) {
            cell.labelWithSpecificPlaceToVisit.text = @"Restaurants";
        }
        else if (indexPath.row == 2){
            cell.labelWithSpecificPlaceToVisit.text = @"Hotels";
        }
        cell.labelWithSpecificPlaceToVisit.font = [UIFont boldSystemFontOfSize:17.0];
        cell.labelWithSpecificPlaceToVisit.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:cell.labelWithSpecificPlaceToVisit];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(PlacesToVisitTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    NSInteger index = cell.placesToVisitCollectionView.indexPath.row;
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(PlacesToVisitTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat horizontalOffset = cell.collectionView.contentOffset.x;
    NSInteger index = cell.placesToVisitCollectionView.indexPath.row;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // ----- HEEEEEREEEEE --------
    [collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];

    cell.delegate = self;
    [cell setImage:nil];
    
    //TESTING PURPOSES ONLY
    cell.place = [[Place alloc] init];
    
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


