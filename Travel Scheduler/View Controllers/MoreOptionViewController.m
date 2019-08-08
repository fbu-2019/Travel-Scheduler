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

@interface MoreOptionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, AttractionCollectionCellDelegate, UISearchBarDelegate, GMSAutocompleteFetcherDelegate, UIScrollViewDelegate, AttractionCollectionCellSetSelectedProtocol, DetailsViewControllerSetSelectedProtocol>

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
    self.view.backgroundColor = [UIColor whiteColor];
    [self createCollectionView];
    self.title = self.stringType;
    self.filteredPlaceToVisit = self.places;
    [self.collectionView reloadData];
    [self createMoreOptionSearchBar];
    [self.view addSubview:self.moreOptionSearchBarAutoComplete];
    self.moreOptionSearchBarAutoComplete.delegate = self;
    [self.view addSubview:self.searchButton];
    [self setUpInfiniteScrollIndicator];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.moreOptionSearchBarAutoComplete.frame = CGRectMake(5, self.topLayoutGuide.length + 10, CGRectGetWidth(self.view.frame) - 10, 60);
    self.collectionView.frame = CGRectMake(5, CGRectGetMaxY(self.moreOptionSearchBarAutoComplete.frame), CGRectGetWidth(self.view.frame) - 10, CGRectGetHeight(self.view.frame) - 100 - self.topLayoutGuide.length - 10);
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
        if(self.filteredPlaceToVisit.count == 0) {
            [self makePressEnterLabelWithText:@"Press enter to search for Places"];
        } else {
            if(self.pressEnterLabel != nil) {
                [self.pressEnterLabel setHidden:YES];
            }
        }
        [self.collectionView reloadData];
    }
    else {
        self.filteredPlaceToVisit = self.places;
        if(self.pressEnterLabel != nil) {
            [self.pressEnterLabel setHidden:YES];
        }
    }
    [self.collectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    if (![self.places containsObject:searchBar.text]){
        [self createNewCellsBasedOnName:searchBar.text];
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

#pragma mark - Methods for new cell creation based on search

- (void)createNewCellsBasedOnName:(NSString *)name
{
    [self.hub makeNewArrayOfPlacesOfType:self.correctType basedOnKeyword:name withCompletion:^(NSArray *arrayOfNewPlaces, NSError *error) {
        if(arrayOfNewPlaces) {
            self.filteredPlaceToVisit = (NSMutableArray *)arrayOfNewPlaces;
             dispatch_async(dispatch_get_main_queue(), ^{
             [self.pressEnterLabel setHidden:YES];
             });
        } else {
            [self makePressEnterLabelWithText:@"Sorry! No place found"];
        }
        [self addToPlacesArrayTheNewObjects:arrayOfNewPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

- (void)addToPlacesArrayTheNewObjects:(NSArray *)arrayOfNewPlaces
{
    for(Place *newPlace in arrayOfNewPlaces) {
        for(Place *oldPlace in self.places) {
            if([oldPlace.placeId isEqualToString:newPlace.placeId]) {
                break;
            }
        }
        [self.places addObject:newPlace];
    }
}
    
- (void)makePressEnterLabelWithText:(NSString *)text {
    if(self.pressEnterLabel == nil) {
    self.pressEnterLabel = makeSubHeaderLabel(text, 20);
    self.pressEnterLabel.frame = CGRectMake(8, self.moreOptionSearchBarAutoComplete.frame.origin.y + self.moreOptionSearchBarAutoComplete.frame.size.height + 10, CGRectGetWidth(self.view.frame) - 5, 50);
    self.pressEnterLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.pressEnterLabel];
    }
    else {
        self.pressEnterLabel.text = text;
        [self.pressEnterLabel setHidden:NO];
    }
}

#pragma mark - UICollectionView delegate & data source

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.setSelectedDelegate = self;
    cell.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    cell.imageView.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:@"output-onlinepngtools.png"];
    cell.place = self.places[indexPath.row];
    cell.place = (self.filteredPlaceToVisit != nil) ? self.filteredPlaceToVisit[indexPath.item] : self.places[indexPath.item];
    [cell setImage];
    [cell layoutSubviews];
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
    detailsViewController.setSelectedDelegate = self;
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
    [self.hub updateArrayOfNearbyPlacesWithType:self.correctType withCompletion:^(bool success, NSError * _Nonnull error) {
        if(success) {
            self.places = self.hub.dictionaryOfArrayOfPlaces[self.correctType];
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
    insets.bottom += InfiniteScrollActivityView.defaultHeight + self.bottomLayoutGuide.length;
    self.collectionView.contentInset = insets;
}
    
#pragma mark - Scroll View Protocol (for infinite scrolling)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
    
#pragma mark - AttractionCollectionCellSetSelectedProtocol and DetailsViewControllerSetSelectedProtocol
    
- (void)updateSelectedPlacesArrayWithPlace:(nonnull Place *)place
{
    [self.setSelectedDelegate updateSelectedPlacesArrayWithPlace:place];
    [self.collectionView reloadData];
}
    
@end
