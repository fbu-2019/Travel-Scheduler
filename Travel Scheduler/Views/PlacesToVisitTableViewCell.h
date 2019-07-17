//
//  PlacesToVisitTableViewCell.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFIndexedCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface PlacesToVisitTableViewCell : UITableViewCell

//@property (strong, nonatomic)  UILabel *labelAtTopToShowTextPlacesToVisit;
@property (strong, nonatomic) UIButton *buttonWithLabelShowingParticularPlaceToVisit;
@property(strong, nonatomic) AFIndexedCollectionView *placesToVisitCollectionView;
@property(strong, nonatomic) UILabel *labelWithSpecificPlaceToVisit;
@property(strong, nonatomic) UIImage *imageViewToShowSpecificPlacesToVisit;


@property (nonatomic, strong) AFIndexedCollectionView *collectionView;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end


NS_ASSUME_NONNULL_END
