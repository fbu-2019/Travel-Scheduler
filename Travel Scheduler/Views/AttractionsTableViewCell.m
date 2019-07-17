//
//  AttractionsTableViewCell.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "AttractionsTableViewCell.h"

@implementation AttractionsTableViewCollectionView

@end

@implementation AttractionsTableViewCell

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
        self.buttonWithLabelShowingParticularAttractionToVisit = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        [self addSubview:self.buttonWithLabelShowingParticularAttractionToVisit];
    }
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.attractionsToVisitCollectionView = [[AttractionsTableViewCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.attractionsToVisitCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:AttractionsCollectionViewCellIdentifier];
    self.attractionsToVisitCollectionView.backgroundColor = [UIColor whiteColor];
    self.attractionsToVisitCollectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.attractionsToVisitCollectionView];
    
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.attractionsToVisitCollectionView.frame = self.contentView.bounds;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.attractionsToVisitCollectionView.dataSource = dataSourceDelegate;
    self.attractionsToVisitCollectionView.delegate = dataSourceDelegate;
    self.attractionsToVisitCollectionView.indexPath = indexPath;
    [self.attractionsToVisitCollectionView setContentOffset:self.attractionsToVisitCollectionView.contentOffset animated:NO];
    [self.attractionsToVisitCollectionView reloadData];
}


@end
