//
//  AttractionsTableViewCell.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AttractionsTableViewCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

static NSString *AttractionsCollectionViewCellIdentifier = @"AttractionsCollectionViewCellIdentifier";

@interface AttractionsTableViewCell : UITableViewCell

@property (strong, nonatomic) UIButton *buttonWithLabelShowingParticularAttractionToVisit;
@property(strong, nonatomic) AttractionsTableViewCollectionView *attractionsToVisitCollectionView;
@property(strong, nonatomic) UILabel *labelWithSpecificAttractionToVisit;
@property(strong, nonatomic) UIImage *imageViewToShowSpecificAttractionToVisit;

@property (nonatomic, strong) AttractionsTableViewCollectionView *collectionView;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
