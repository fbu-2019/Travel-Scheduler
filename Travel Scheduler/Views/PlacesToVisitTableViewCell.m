//
//  PlacesToVisitTableViewCell.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PlacesToVisitTableViewCell.h"

@implementation AFIndexedCollectionView

@end

@implementation PlacesToVisitTableViewCell



@synthesize buttonWithLabelShowingParticularPlaceToVisit = _buttonWithLabelShowingParticularPlaceToVisit;

#pragma mark - Cell lifeCycle

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Selecting cell animation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.buttonWithLabelShowingParticularPlaceToVisit = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        [self addSubview:self.buttonWithLabelShowingParticularPlaceToVisit];
    }
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.itemSize = CGSizeMake(44, 44);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.placesToVisitCollectionView = [[AFIndexedCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.placesToVisitCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    self.placesToVisitCollectionView.backgroundColor = [UIColor whiteColor];
    self.placesToVisitCollectionView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.placesToVisitCollectionView];

    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.placesToVisitCollectionView.frame = self.contentView.bounds;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.placesToVisitCollectionView.dataSource = dataSourceDelegate;
    self.placesToVisitCollectionView.delegate = dataSourceDelegate;
    self.placesToVisitCollectionView.indexPath = indexPath;
    [self.placesToVisitCollectionView setContentOffset:self.placesToVisitCollectionView.contentOffset animated:NO];
    [self.placesToVisitCollectionView reloadData];
}

@end
