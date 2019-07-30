//
//  EditCell.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/25/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EditCellDelegate;

@interface EditCell : UITableViewCell

@property (strong, nonatomic) NSString *string;
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) UIView *tapView;
@property (strong, nonatomic) NSDate *date;
@property (nonatomic) int indexPath;
@property (nonatomic) int width;
@property (nonatomic, weak) id<EditCellDelegate> delegate;

- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithDate:(NSDate *)date;
- (void)makeSelection:(int)width;
- (void)createAllProperties;

@end

@protocol EditCellDelegate
- (void)editCell:(EditCell *)editCell didTap:(Place *)place;
@end

NS_ASSUME_NONNULL_END
