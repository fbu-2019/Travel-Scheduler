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
#import "DetailsViewController.h"
#import "Place.h"

@import GooglePlaces;

@interface MoreOptionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, AttractionCollectionCellDelegate, UISearchBarDelegate, GMSAutocompleteFetcherDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIButton *scheduleButton;
@property (strong, nonnull) UISearchBar *moreOptionSearchBarAutoComplete;
@property (strong, nonatomic) NSArray *filteredPlaceToVisit;
@property (strong, nonatomic) UIButton *searchButton;

@end

@implementation MoreOptionViewController {
    GMSPlacesClient *_placesClient;
    GMSAutocompleteFetcher *_fetcher;
}

#pragma mark - MoreOptionViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createCollectionView];
    UILabel *label = makeHeaderLabel(self.stringType);
    [self.view addSubview:label];
    [self.collectionView reloadData];
    self.scheduleButton = makeButton(@"Generate Schedule", CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), self.collectionView.frame.origin.y-47 + CGRectGetHeight(self.collectionView.frame));
    [self.scheduleButton addTarget:self action:@selector(makeSchedule) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scheduleButton];
    _placesClient = [GMSPlacesClient sharedClient];
    [self createMoreOptionSearchBar];
    [self.view addSubview:self.moreOptionSearchBarAutoComplete];
    [self.view addSubview:self.scheduleButton];
    self.moreOptionSearchBarAutoComplete.delegate = self;
    [self createSearchButton];
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

#pragma  mark - creating search bar

- (void)createMoreOptionSearchBar{
    CGRect screenFrame = self.view.frame;
    self.moreOptionSearchBarAutoComplete = [[UISearchBar alloc] initWithFrame:CGRectMake(5, 150, CGRectGetWidth(screenFrame) - 100, CGRectGetHeight(screenFrame)-850)];
    self.moreOptionSearchBarAutoComplete.backgroundColor = [UIColor blackColor];
}

#pragma mark - Methods to Create Menu Button and Action

- (void) createSearchButton
{
    CGRect screenFrame = self.view.frame;
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.backgroundColor = [UIColor blueColor];
    [self.searchButton setFrame:CGRectMake(320, 150, CGRectGetWidth(screenFrame) - 360, CGRectGetHeight(screenFrame)-850)];
    self.searchButton.titleLabel.text = @"Search";
    //[self.searchButton setBackgroundImage:[UIImage imageNamed:@"menu_icon"] forState: UIControlStateNormal];
    self.searchButton.layer.cornerRadius = 10;
    self.searchButton.clipsToBounds = YES;
    [self.searchButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            NSLog(@"%@", evaluatedObject);
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredPlaceToVisit = [self.places filteredArrayUsingPredicate:predicate];
        [self.collectionView reloadData];
    }
    else {
        self.filteredPlaceToVisit = self.places;
    }
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView delegate & data source

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];
    
    //Gi's testing
    //[self getFirstPhotoWithId:@"ChIJR_oXUZa8j4ARk7FaWcK71KA" inCell:cell];
    
    //TODO:
    //Place *place = self.places[indexPath.item];
    //NOTE: this method is required for segues.
    [cell setImage:nil]; //TESTING: put in real place later
    
    //TESTING PURPOSES ONLY
    cell.place = [[Place alloc] init];
    
    cell.delegate = self;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //return self.places.count;
    // return (self.filteredPlaceToVisit != nil) ?  self.filteredPlaceToVisit.count : self.places.count;// will uncomment when I get access to all code
    return 20; //TESTING
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

#pragma mark - Testing retrieve photos

- (void)getFirstPhotoWithId:(NSString *)id inCell:(AttractionCollectionCell *)cell{
    GMSPlaceField fields = (GMSPlaceFieldPhotos);
    
    [_placesClient fetchPlaceFromPlaceID:id placeFields:fields sessionToken:nil callback:^(GMSPlace * _Nullable place, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"An error occurred %@", [error localizedDescription]);
            return;
        }
        if (place != nil) {
            GMSPlacePhotoMetadata *photoMetadata = [place photos][0];
            [self->_placesClient loadPlacePhoto:photoMetadata callback:^(UIImage * _Nullable photo, NSError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error loading photo metadata: %@", [error localizedDescription]);
                    return;
                } else {
                    cell.imageView =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,cell.contentView.bounds.size.width,cell.contentView.bounds.size.height)];
                    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                    cell.imageView.clipsToBounds = YES;
                    cell.imageView.image = photo;
                    [cell.contentView addSubview:cell.imageView];
                    
                }
            }];
        }
    }];
    
}

#pragma mark - AttractionCollectionCell delegate

- (void)attractionCell:(AttractionCollectionCell *)attractionCell didTap:(Place *)place {
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] init];
    detailsViewController.place = attractionCell.place;
    [self.navigationController pushViewController:detailsViewController animated:true];
}

#pragma mark - MoreOptionViewController helper functions

- (void)createCollectionView {
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    CGRect screenFrame = self.view.frame;
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(5, 200, CGRectGetWidth(screenFrame) - 10, CGRectGetHeight(screenFrame) - 300) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
}

#pragma mark - segue to schedule

- (void)makeSchedule {
    [self.tabBarController setSelectedIndex: 1];
}


NSMutableArray *resultsArr;
- (void)didAutocompleteWithPredictions:(NSArray *)predictions
{
    resultsArr = [[NSMutableArray alloc] init];
    for (GMSAutocompletePrediction *prediction in predictions) {
        [resultsArr addObject:[prediction.attributedFullText string]];
    }
}

- (void)didFailAutocompleteWithError:(NSError *)error
{
    NSString *errorMessage = [NSString stringWithFormat:@"%@", error.localizedDescription];
    NSLog(@"%@", errorMessage);
}


@end
