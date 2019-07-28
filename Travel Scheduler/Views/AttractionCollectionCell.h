//
//  AttractionCollectionCell.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AttractionCollectionCellDelegate;

@interface AttractionCollectionCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) NSMutableArray *selectedPlacesArray;
@property (nonatomic, weak) id<AttractionCollectionCellDelegate> delegate;

- (void)setImage;

@end

@protocol AttractionCollectionCellDelegate

- (void)attractionCell:(AttractionCollectionCell *)attractionCell didTap:(Place *)place;

@end

NS_ASSUME_NONNULL_END
