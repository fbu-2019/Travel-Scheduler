//
//  EditCell.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/25/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "EditCell.h"

@implementation EditCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    self.string = string;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(self.contentView.frame) - 20, CGRectGetHeight(self.contentView.frame))];
    label.text = string;
    [self.contentView addSubview:label];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
