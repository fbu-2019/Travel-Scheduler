//
//  GoToMoreOptionsCell.h
//  Travel Scheduler
//
//  Created by gilemos on 8/2/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GoToMoreOptionsCellDelegate;

@interface GoToMoreOptionsCell : UICollectionViewCell
@property (strong, nonatomic) NSString *placeTypeString;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic)id<GoToMoreOptionsCellDelegate> delegate;
@property (strong, nonatomic) UILabel *titleLabel;
    
- (void)initWithType:(NSString *)type;
    
@end

@protocol GoToMoreOptionsCellDelegate
- (void)goToMoreOptionsWithType:(NSString *)type;
@end

NS_ASSUME_NONNULL_END
