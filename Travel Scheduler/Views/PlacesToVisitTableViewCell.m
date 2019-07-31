//
//  PlacesToVisitTableViewCell.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PlacesToVisitTableViewCell.h"
#import "PlacesToVisitCollectionView.h"
#import "AttractionCollectionCell.h"
#import "DetailsViewController.h"

@interface PlacesToVisitTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate, AttractionCollectionCellDelegate, AttractionCollectionCellSetSelectedProtocol>
@end

@implementation PlacesToVisitTableViewCell

#pragma mark - Initiation Methods

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self createAllProperties];
    [self setCollectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    return self;
}

- (void)createAllProperties
{
    self.arrayOfPlaces = [[NSMutableArray alloc] init];
    self.contentOffsetDictionary = [[NSMutableDictionary alloc] init];
}

- (void)setCollectionViewIndexPath:(NSIndexPath *)indexPath
{
    self.collectionView.indexPath = indexPath;
}

#pragma mark - Cell set up

- (void)setUpCellOfType:(NSString *)type
{
    self.typeOfPlaces = type;
    if([type isEqualToString:@"attractions"]) {
        self.labelWithSpecificPlaceToVisit = makeSubHeaderLabel(@"Attractions", 20);
        NSMutableSet *set = [NSMutableSet setWithArray:self.hub.dictionaryOfArrayOfPlaces[@"museum"]];
        [set addObjectsFromArray:self.hub.dictionaryOfArrayOfPlaces[@"park"]];
        self.arrayOfPlaces = (NSMutableArray *)[set allObjects];
    } else if ([type isEqualToString:@"restaurant"]) {
        self.labelWithSpecificPlaceToVisit = makeSubHeaderLabel(@"Restaurants", 20);
        self.arrayOfPlaces = self.hub.dictionaryOfArrayOfPlaces[self.typeOfPlaces];
    } else {
        self.labelWithSpecificPlaceToVisit = makeSubHeaderLabel(@"Hotels", 20);
        self.arrayOfPlaces = self.hub.dictionaryOfArrayOfPlaces[self.typeOfPlaces];
    }
}

#pragma mark - Layout methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.contentView.bounds;
    self.labelWithSpecificPlaceToVisit.frame = CGRectMake(10, 10, CGRectGetWidth(self.contentView.frame), 30);
    [self.labelWithSpecificPlaceToVisit sizeToFit];
    self.labelWithSpecificPlaceToVisit.frame = CGRectMake(10, 10, CGRectGetWidth(self.labelWithSpecificPlaceToVisit.frame), CGRectGetHeight(self.labelWithSpecificPlaceToVisit.frame));
    int yCoord = CGRectGetMaxY(self.labelWithSpecificPlaceToVisit.frame);
    self.collectionView.frame = CGRectMake(10, yCoord, CGRectGetWidth(frame),CGRectGetHeight(frame) - yCoord);
}

- (void)setCollectionViewLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[PlacesToVisitCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.setSelectedDelegate = self;
    cell.place = self.arrayOfPlaces[indexPath.item];
    cell.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    cell.imageView.backgroundColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:@"output-onlinepngtools.png"];
    [cell setImage];
    [cell layoutSubviews];
    return cell;
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

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    PlacesToVisitCollectionView *collectionView = (PlacesToVisitCollectionView *)scrollView;
    NSInteger index = collectionView.indexPath.item;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

#pragma mark - AttractionCollectionCell delegate
- (void)attractionCell:(AttractionCollectionCell *)attractionCell didTap:(Place *)place
{
    [self.delegate placesToVisitCell:self didTap:attractionCell.place];
}

#pragma mark - AttractionCollectionCellSetSelectedProtocol
- (void)updateSelectedPlacesArrayWithPlace:(nonnull Place *)place
{
    [self.setSelectedDelegate updateSelectedPlacesArrayWithPlace:place];
}

#pragma mark - Animations
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
