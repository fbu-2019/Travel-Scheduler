//
//  HotelsTableViewCell.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HotelsTableViewCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

static NSString *HotelsCollectionViewCellIdentifier = @"RestaurantsCollectionViewCellIdentifier";

@interface HotelsTableViewCell : UITableViewCell

@property (strong, nonatomic) UIButton *buttonWithLabelShowingParticularHotelToVisit;
@property(strong, nonatomic) HotelsTableViewCollectionView *hotelsToVisitCollectionView;
@property(strong, nonatomic) UILabel *labelWithSpecificHotelToVisit;
@property(strong, nonatomic) UIImage *imageViewToShowSpecificHotelToVisit;

@property (nonatomic, strong) HotelsTableViewCollectionView *collectionView;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;


@end

NS_ASSUME_NONNULL_END
