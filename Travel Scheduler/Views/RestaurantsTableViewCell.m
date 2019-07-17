//
//  RestaurantsTableViewCell.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "RestaurantsTableViewCell.h"

@implementation RestaurantsTableViewCollectionView

@end

@implementation RestaurantsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.buttonWithLabelShowingParticularRestaurantToVisit = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        [self addSubview:self.buttonWithLabelShowingParticularRestaurantToVisit];
    }
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.restaurantsToVisitCollectionView = [[RestaurantsTableViewCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.restaurantsToVisitCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:RestaurantsCollectionViewCellIdentifier];
    self.restaurantsToVisitCollectionView.backgroundColor = [UIColor whiteColor];
    self.restaurantsToVisitCollectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.restaurantsToVisitCollectionView];
    
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.restaurantsToVisitCollectionView.frame = self.contentView.bounds;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.restaurantsToVisitCollectionView.dataSource = dataSourceDelegate;
    self.restaurantsToVisitCollectionView.delegate = dataSourceDelegate;
    self.restaurantsToVisitCollectionView.indexPath = indexPath;
    [self.restaurantsToVisitCollectionView setContentOffset:self.restaurantsToVisitCollectionView.contentOffset animated:NO];
    [self.restaurantsToVisitCollectionView reloadData];
}



@end
