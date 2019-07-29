//
//  CommentsCell.m
//  Travel Scheduler
//
//  Created by gilemos on 7/27/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "CommentsCell.h"
#import "Place.h"
#import "UIImageView+AFNetworking.h"

static UIImageView *makePlaceImage(int width)
{
    int leftEdge = 15;
    int imageHeight = 50;
    int imageWidth = 50;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftEdge, 20, imageWidth, imageHeight)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    return imageView;
}

static UILabel *makeNameLabel(NSString *text, int width, CGRect imageFrame)
{
    int quarterScreen = width / 4;
    int halfScreen = width / 2;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(quarterScreen, 20, halfScreen, 50)];
    [label setFont: [UIFont fontWithName:@"Arial-BoldMT" size:20]];
    label.text = text;
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 1;
    [label sizeToFit];
    return label;
}

static UILabel *makeCommentLabel(NSString *text, int width, CGRect labelFrame)
{
    int xCoord = labelFrame.origin.x;
    int yCoord = labelFrame.origin.y + CGRectGetHeight(labelFrame) + 10;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(xCoord, yCoord, 3 * (width/4) - 3 , 50)];
    label.text = text;
    [label setFont: [UIFont fontWithName:@"Arial" size:15]];
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 5;
    [label sizeToFit];
    return label;
}

@implementation CommentsCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
    
- (instancetype)initWithWidth:(int)width andComment:(NSDictionary *)commentDictionary
    {
        self = [super init];
        self.width = width;
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.dictionaryOfComments = commentDictionary;
        self.commentTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self makeLabels];
        [self customLayouts];
        return self;
    }

- (void)makeLabels
{
    self.userProfileImageUrlString = self.dictionaryOfComments[@"profile_photo_url"];
    self.username = self.dictionaryOfComments[@"author_name"];
    self.commentText = self.dictionaryOfComments[@"text"];
    self.commentTimeText = self.dictionaryOfComments[@"relative_time_description"];
}
    
- (void)customLayouts
    {
        self.userProfileImage = makePlaceImage(self.width);
        [self.userProfileImage setImageWithURL:[NSURL URLWithString:self.userProfileImageUrlString]];
        [self.contentView addSubview:self.userProfileImage];
        
        self.usernameLabel = makeNameLabel(self.username, self.width, self.userProfileImage.frame);
        [self.contentView addSubview:self.usernameLabel];
        
        self.commentTextLabel = makeCommentLabel(self.commentText, self.width, self.usernameLabel.frame);
        [self.contentView addSubview:self.commentTextLabel];
        
        int height = self.commentTextLabel.frame.origin.y + CGRectGetHeight(self.commentTextLabel.frame) + 25;
        self.contentView.frame = CGRectMake(0, 0, self.width, height);
    }
    
@end
