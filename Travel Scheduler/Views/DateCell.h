//
//  DateCell.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DateCellDelegate;

@interface DateCell : UICollectionViewCell

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) UILabel *dayLabel;
@property (strong, nonatomic) UILabel *dayStringLabel;
@property (weak, nonatomic) id<DateCellDelegate> delegate;

- (void)makeDate:(NSDate *)date givenStart:(NSDate *)startDate andEnd:(NSDate *)endDate;
- (void)setUnselected;
- (void)setSelected;

@end

@protocol DateCellDelegate

- (void)dateCell:(DateCell *) dateCell didTap: (NSDate *)date;

@end

NS_ASSUME_NONNULL_END
