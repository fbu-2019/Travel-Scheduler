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

@interface PlacesToVisitTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate>
@end

@implementation PlacesToVisitTableViewCell

#pragma mark - Initiation Methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self initAllProperties];
    [self setCollectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    return self;
}

- (void)initAllProperties
{
    self.labelWithSpecificPlaceToVisit = [[UILabel alloc] init];
    self.arrayOfPlaces = [[NSMutableArray alloc] init];
    self.contentOffsetDictionary = [[NSMutableDictionary alloc] init];
}

-(void)setCollectionViewIndexPath:(NSIndexPath *)indexPath {
    self.collectionView.indexPath = indexPath;
}

#pragma mark - Cell set up
- (void)setUpCellOfType:(NSString *)type {
    self.typeOfPlaces = type;
    if([type isEqualToString:@"attractions"]) {
        self.labelWithSpecificPlaceToVisit.text = @"Attractions";
        NSMutableSet *set = [NSMutableSet setWithArray:self.hub.dictionaryOfArrayOfPlaces[@"museum"]];
        [set addObjectsFromArray:self.hub.dictionaryOfArrayOfPlaces[@"park"]];
        self.arrayOfPlaces = (NSMutableArray *)[set allObjects];
    } else if ([type isEqualToString:@"restaurant"]) {
        self.labelWithSpecificPlaceToVisit.text = @"Restaurants";
        self.arrayOfPlaces = self.hub.dictionaryOfArrayOfPlaces[self.typeOfPlaces];
    } else {
        self.labelWithSpecificPlaceToVisit.text = @"Hotels";
        self.arrayOfPlaces = self.hub.dictionaryOfArrayOfPlaces[self.typeOfPlaces];
    }
}

#pragma mark - Layout methods
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.contentView.bounds;
    int yCoord = CGRectGetMaxY(self.labelWithSpecificPlaceToVisit.frame);
    self.collectionView.frame = CGRectMake(10, yCoord, CGRectGetWidth(frame),CGRectGetHeight(frame) - yCoord);
}

-(void)setCollectionViewLayout {
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

#pragma mark - setting up collection view delegate in cell

//- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
//{
//    self.placesToVisitCollectionView.dataSource = dataSourceDelegate;
//    self.placesToVisitCollectionView.delegate = dataSourceDelegate;
//    self.placesToVisitCollectionView.indexPath = indexPath;
//    [self.placesToVisitCollectionView setContentOffset:self.placesToVisitCollectionView.contentOffset animated:NO];
//    [self.placesToVisitCollectionView reloadData];
//}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];
    
    if ([self.typeOfPlaces isEqualToString:@"restaurant"]) {
        cell.place = self.hub.dictionaryOfArrayOfPlaces[@"restaurant"][indexPath.row];
    } else if([self.typeOfPlaces isEqualToString:@"attractions"]) {
        cell.place = self.hub.dictionaryOfArrayOfPlaces[@"museum"][indexPath.row];
    } else {
        cell.place = self.hub.dictionaryOfArrayOfPlaces[@"lodging"][indexPath.row];
    }
    
    [cell setImage];
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
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    PlacesToVisitCollectionView *collectionView = (PlacesToVisitCollectionView *)scrollView;
    NSInteger index = collectionView.indexPath.item;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

#pragma mark - Animations
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

@end
