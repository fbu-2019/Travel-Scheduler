//
//  PlacesToVisitTableViewCell.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PlacesToVisitTableViewCell.h"

@implementation PlacesToVisitCollectionView
@end

@implementation PlacesToVisitTableViewCell

#pragma mark - Selecting cell animation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}


#pragma mark - Setting up style of the cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.placesToVisitCollectionView = [[PlacesToVisitCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.placesToVisitCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.placesToVisitCollectionView.backgroundColor = [UIColor whiteColor];
    self.placesToVisitCollectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.placesToVisitCollectionView];
    self.labelWithSpecificPlaceToVisit = [[UILabel alloc] init];
    return self;
}

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

#pragma mark - Initiating subviews

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.contentView.bounds;
    int yCoord = CGRectGetMaxY(self.labelWithSpecificPlaceToVisit.frame);
    self.placesToVisitCollectionView.frame = CGRectMake(10, yCoord, CGRectGetWidth(frame),CGRectGetHeight(frame) - yCoord);
}

#pragma mark - setting up collection view delegate in cell

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.placesToVisitCollectionView.dataSource = dataSourceDelegate;
    self.placesToVisitCollectionView.delegate = dataSourceDelegate;
    self.placesToVisitCollectionView.indexPath = indexPath;
    [self.placesToVisitCollectionView setContentOffset:self.placesToVisitCollectionView.contentOffset animated:NO];
    [self.placesToVisitCollectionView reloadData];
}


@end
