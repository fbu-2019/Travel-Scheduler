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
@import GooglePlaces;

@interface MoreOptionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, AttractionCollectionCellDelegate, UISearchBarDelegate, GMSAutocompleteFetcherDelegate>

@end

@implementation MoreOptionViewController
{
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
    UILabel *label = makeHeaderLabel(self.stringType);
    [self.view addSubview:label];
    [self.collectionView reloadData];
    self.scheduleButton = makeButton(@"Generate Schedule", CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), self.collectionView.frame.origin.y + CGRectGetHeight(self.collectionView.frame));
    [self.scheduleButton addTarget:self action:@selector(makeSchedule) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scheduleButton];
    [self createMoreOptionSearchBar];
    [self.view addSubview:self.moreOptionSearchBarAutoComplete];
    [self.view addSubview:self.scheduleButton];
    self.moreOptionSearchBarAutoComplete.delegate = self;
    [self.view addSubview:self.searchButton];
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
    self.moreOptionSearchBarAutoComplete = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 150, CGRectGetWidth(screenFrame) - 10, CGRectGetHeight(screenFrame)-850)];
    self.moreOptionSearchBarAutoComplete.backgroundColor = [UIColor blackColor];
    self.moreOptionSearchBarAutoComplete.autocorrectionType = UITextAutocorrectionTypeNo;
    self.moreOptionSearchBarAutoComplete.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.moreOptionSearchBarAutoComplete.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.moreOptionSearchBarAutoComplete.backgroundColor = [UIColor whiteColor];
    self.moreOptionSearchBarAutoComplete.searchBarStyle = UISearchBarStyleMinimal;
    self.moreOptionSearchBarAutoComplete.placeholder = @"Search destination of choice...";
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
}

#pragma mark - UICollectionView delegate & data source

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.place = self.places[indexPath.row];
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
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(5, 150, CGRectGetWidth(screenFrame) - 10, CGRectGetHeight(screenFrame) - 300) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
}

#pragma mark - segue to schedule

- (void)makeSchedule
{
    [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:TRUE];
    [self.tabBarController setSelectedIndex: 1];
}

@end
