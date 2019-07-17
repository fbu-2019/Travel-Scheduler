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
@import GooglePlaces;

@interface MoreOptionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation MoreOptionViewController {
    GMSPlacesClient *_placesClient;
}

/*
static void formatLayout(UICollectionView *collectionView) {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}*/

#pragma mark - MoreOptionViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createCollectionView];
    [self makeHeaderLabel: self.stringType];
    [self.collectionView reloadData];
    //formatLayout(self.collectionView);

    //Gi's place to write TESTING
    //[APITesting testCompleteInfo];
    //[APITesting photoTest];
    //[APITesting testCompleteInfoWithName];
    //[placeObjectTesting testInitWithName];
    //[placeObjectTesting testGetClosebyLocations];
    
    _placesClient = [GMSPlacesClient sharedClient];
    
    //end of Gi's place to write TESTING
}

#pragma mark - MoreOptionViewController loading helper functions

-(void) createCollectionView {
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    self.collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.collectionView];
}

- (void) makeHeaderLabel: (NSString *) text {
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(35, 75, 500, 50)];
    [label setFont: [UIFont fontWithName:@"Arial-BoldMT" size:50]];
    label.text = @"Attractions";
    label.numberOfLines = 1;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.minimumScaleFactor = 10.0f/12.0f;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:label];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UICollectionView delegate & data source

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];
    
    //TESTING
    cell.backgroundColor = [UIColor greenColor];
    //[cell setImage];
    [self getFirstPhotoWithId:@"ChIJR_oXUZa8j4ARk7FaWcK71KA" inCell:cell];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //return self.objects.count;
    //TESTING
    return 9;
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
@end
