//
//  MoreOptionViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MoreOptionViewController.h"
#import "AttractionCollectionCell.h"
#import "APITesting.h"
#import "placeObjectTesting.h"
#import "TravelSchedulerHelper.h"
#import "Date.h"
#import "DetailsViewController.h"
#import "APIManager.h"
#import "InfiniteScrollActivityView.h"
#import "Place.h"
#import "UIImageView+AFNetworking.h"
@import GooglePlaces;

@interface MoreOptionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, AttractionCollectionCellDelegate, UISearchBarDelegate, GMSAutocompleteFetcherDelegate, UIScrollViewDelegate>

@end

@implementation MoreOptionViewController
{
    InfiniteScrollActivityView* loadingMoreView;
    GMSAutocompleteFetcher *_fetcher;
}

#pragma mark - MoreOptionViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.selectedPlacesArray == nil) {
        self.selectedPlacesArray = [[NSMutableArray alloc]init];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self createCollectionView];
    self.filteredPlaceToVisit = self.places;
    self.headerLabel = makeHeaderLabel(self.stringType, 35);
    [self.view addSubview:self.headerLabel];
    [self.collectionView reloadData];
    self.scheduleButton = makeScheduleButton(@"Generate Schedule");
    [self.scheduleButton addTarget:self action:@selector(makeSchedule) forControlEvents:UIControlEventTouchUpInside];
    [self createMoreOptionSearchBar];
    [self.view addSubview:self.moreOptionSearchBarAutoComplete];
    [self.view addSubview:self.scheduleButton];
    self.moreOptionSearchBarAutoComplete.delegate = self;
    [self.view addSubview:self.searchButton];
    [self setUpInfiniteScrollIndicator];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.headerLabel.frame = CGRectMake(5, self.navigationController.navigationBar.frame.size.height + 55, CGRectGetWidth(self.view.frame) - 10, 50);
    [self.headerLabel sizeToFit];
    self.headerLabel.frame = CGRectMake(5, self.navigationController.navigationBar.frame.size.height + 55, CGRectGetWidth(self.headerLabel.frame), CGRectGetHeight(self.headerLabel.frame));
    self.moreOptionSearchBarAutoComplete.frame = CGRectMake(5, CGRectGetMaxY(self.headerLabel.frame), CGRectGetWidth(self.view.frame) - 10, 60);
    self.collectionView.frame = CGRectMake(5, CGRectGetMaxY(self.moreOptionSearchBarAutoComplete.frame), CGRectGetWidth(self.view.frame) - 10, CGRectGetHeight(self.view.frame) - 100 - CGRectGetMaxY(self.headerLabel.frame));
    self.scheduleButton.frame = CGRectMake(25, CGRectGetHeight(self.view.frame) - self.tabBarController.tabBar.frame.size.height - 60, CGRectGetWidth(self.view.frame) - 2 * 25, 50);
}

#pragma mark - GMSAutocomplete set up

- (void) createFilterForGMSAutocomplete
{
    CLLocationCoordinate2D neBoundsCorner = CLLocationCoordinate2DMake(-33.843366, 151.134002);
    CLLocationCoordinate2D swBoundsCorner = CLLocationCoordinate2DMake(-33.875725, 151.200349);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:neBoundsCorner coordinate:swBoundsCorner];
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterCity;
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds filter:filter];
    _fetcher.delegate = self;
}

- (void)didAutocompleteWithPredictions:(NSArray *)predictions
{
    self.resultsArr = [[NSMutableArray alloc] init];
    for (GMSAutocompletePrediction *prediction in predictions) {
        [self.resultsArr addObject:[prediction.attributedFullText string]];
    }
}

- (void)didFailAutocompleteWithError:(NSError *)error
{
    NSString *errorMessage = [NSString stringWithFormat:@"%@", error.localizedDescription];
    NSLog(@"%@", errorMessage);
}


#pragma  mark - creating search bar

- (void)createMoreOptionSearchBar
{
    CGRect screenFrame = self.view.frame;
    self.moreOptionSearchBarAutoComplete = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.moreOptionSearchBarAutoComplete.backgroundColor = [UIColor blackColor];
    self.moreOptionSearchBarAutoComplete.autocorrectionType = UITextAutocorrectionTypeNo;
    self.moreOptionSearchBarAutoComplete.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.moreOptionSearchBarAutoComplete.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.moreOptionSearchBarAutoComplete.backgroundColor = [UIColor whiteColor];
    self.moreOptionSearchBarAutoComplete.searchBarStyle = UISearchBarStyleMinimal;
    self.moreOptionSearchBarAutoComplete.placeholder = @"Search place of choice";
}

#pragma mark - UI Search Bar Delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [[evaluatedObject valueForKey:@"_name"] localizedCaseInsensitiveContainsString:searchText];
        }];
        self.filteredPlaceToVisit = [self.places filteredArrayUsingPredicate:predicate];
        [self.collectionView reloadData];
    }
    else {
        self.filteredPlaceToVisit = self.places;
    }
    [self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    if (![self.places containsObject:searchBar.text]){
        //TODO (Giovanna) : When user enters valid search which is not already available
        //Might make use of GMSAutocomplete so did the set up for you
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self.filteredPlaceToVisit = self.places;
    [self.collectionView reloadData];
    [self setUpInfiniteScrollIndicator];
}

#pragma mark - UICollectionView delegate & data source

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.place = self.places[indexPath.row];
    cell.place = (self.filteredPlaceToVisit != nil) ? self.filteredPlaceToVisit[indexPath.item] : self.places[indexPath.item];
    [cell setImage];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (self.filteredPlaceToVisit != nil) ?  self.filteredPlaceToVisit.count : self.places.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - AttractionCollectionCell delegate

- (void)attractionCell:(AttractionCollectionCell *)attractionCell didTap:(Place *)place
{
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] init];
    detailsViewController.place = attractionCell.place;
    [self.navigationController pushViewController:detailsViewController animated:true];
}

#pragma mark - MoreOptionViewController helper functions

- (void)createCollectionView
{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    CGRect screenFrame = self.view.frame;
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
}
    
- (void)loadMoreData {
    NSString *correctType;
    if([self.stringType isEqualToString:@"Hotels"]) {
        correctType = @"lodging";
    } else if ([self.stringType isEqualToString:@"Restaurants"]) {
        correctType = @"restaurant";
    } else {
        correctType = @"park";
    }
    
    [self.hub updateArrayOfNearbyPlacesWithType:correctType withCompletion:^(bool success, NSError * _Nonnull error) {
        if(success) {
            self.places = self.hub.dictionaryOfArrayOfPlaces[correctType];
        }
        else {
            NSLog(@"did not work");
        }
        self.isMoreDataLoading = NO;
        [loadingMoreView stopAnimating];
        [self.collectionView reloadData];
    }];
}

#pragma mark - Infinite scrolling helper methods

- (void)setUpInfiniteScrollIndicator
{
    CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    loadingMoreView.hidden = true;
    [self.collectionView addSubview:loadingMoreView];
    
    UIEdgeInsets insets = self.collectionView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight + self.scheduleButton.frame.size.height;
    self.collectionView.contentInset = insets;
}
    
#pragma mark - Scroll View Protocol (for infinite scrolling)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.isMoreDataLoading) {
        int scrollViewContentHeight = self.collectionView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.collectionView.bounds.size.height;
        
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.collectionView.isDragging) {
            self.isMoreDataLoading = true;
            CGRect frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            loadingMoreView.frame = frame;
            [loadingMoreView startAnimating];
            
            [self loadMoreData];
        }
        
    }
}
    
#pragma mark - segue to schedule

- (void)makeSchedule
{
    [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:TRUE];
    [self.tabBarController setSelectedIndex: 1];
}

@end
