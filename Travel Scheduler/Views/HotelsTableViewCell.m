//
//  HotelsTableViewCell.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "HotelsTableViewCell.h"

@implementation HotelsTableViewCollectionView
@end

@implementation HotelsTableViewCell

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
        self.buttonWithLabelShowingParticularHotelToVisit = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        [self addSubview:self.buttonWithLabelShowingParticularHotelToVisit];
    }
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.hotelsToVisitCollectionView = [[HotelsTableViewCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.hotelsToVisitCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:HotelsCollectionViewCellIdentifier];
    self.hotelsToVisitCollectionView.backgroundColor = [UIColor whiteColor];
    self.hotelsToVisitCollectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.hotelsToVisitCollectionView];
    
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.hotelsToVisitCollectionView.frame = self.contentView.bounds;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.hotelsToVisitCollectionView.dataSource = dataSourceDelegate;
    self.hotelsToVisitCollectionView.delegate = dataSourceDelegate;
    self.hotelsToVisitCollectionView.indexPath = indexPath;
    [self.hotelsToVisitCollectionView setContentOffset:self.hotelsToVisitCollectionView.contentOffset animated:NO];
    [self.hotelsToVisitCollectionView reloadData];
}


@end
