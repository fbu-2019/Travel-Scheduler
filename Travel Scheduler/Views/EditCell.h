//
//  EditCell.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/25/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditCell : UITableViewCell

@property (strong, nonatomic) NSString *string;

- (instancetype)initWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
