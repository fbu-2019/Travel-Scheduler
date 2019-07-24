//
//  PlacesToVisitTableViewCell.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "PlacesToVisitCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface PlacesToVisitTableViewCell : UITableViewCell
@property(strong, nonatomic) PlacesToVisitCollectionView *collectionView;   
@property(strong, nonatomic) UILabel *labelWithSpecificPlaceToVisit;
@property(strong, nonatomic) NSString *titleOfTypeOfPlaceToVist;
//@property(strong, nonatomic) NSArray *arrayOfPhotosOfTypeOfPlaceToVisit;
//@property (nonatomic, strong) PlacesToVisitCollectionView *collectionView;
@property(nonatomic, strong)NSString *typeOfPlaces;
@property(nonatomic, strong)NSMutableArray *arrayOfPlaces;
@property(nonatomic, strong)Place *hub;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
//- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;
-(void)setCollectionViewIndexPath:(NSIndexPath *)indexPath;
- (void)setUpCellOfType:(NSString *)type;
@end


NS_ASSUME_NONNULL_END
