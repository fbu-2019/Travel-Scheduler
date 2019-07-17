//
//  RestaurantsTableViewCell.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RestaurantsTableViewCollectionView : UICollectionView

@property (nonatomic, strong) NSIndexPath *indexPath;

@end

static NSString *RestaurantsCollectionViewCellIdentifier = @"RestaurantsCollectionViewCellIdentifier";

@interface RestaurantsTableViewCell : UITableViewCell

@property (strong, nonatomic) UIButton *buttonWithLabelShowingParticularRestaurantToVisit;
@property(strong, nonatomic) RestaurantsTableViewCollectionView *restaurantsToVisitCollectionView;
@property(strong, nonatomic) UILabel *labelWithSpecificRestaurantToVisit;
@property(strong, nonatomic) UIImage *imageViewToShowSpecificRestaurantToVisit;

@property (nonatomic, strong) RestaurantsTableViewCollectionView *collectionView;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
