//
//  CommentsCell.h
//  Travel Scheduler
//
//  Created by gilemos on 7/27/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentsCell : UITableViewCell
    
@property(strong, nonatomic) NSDictionary *dictionaryOfComments;
@property (strong, nonatomic) UILabel *commentTextLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) NSString *commentTimeText;
@property (strong, nonatomic) NSString *userProfileImageUrlString;
@property (strong, nonatomic) UIImageView *userProfileImage;
@property (nonatomic) int width;
    
- (instancetype)initWithWidth:(int)width andComment:(NSDictionary *)commentDictionary;

@end

NS_ASSUME_NONNULL_END
