//
//  DetailHeaderCell.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailHeaderCell : UITableViewCell

@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) NSString *place;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *description;

- (void)makeCell;

@end

NS_ASSUME_NONNULL_END
