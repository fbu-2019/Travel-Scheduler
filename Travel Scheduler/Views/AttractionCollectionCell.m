//
//  AttractionCollectionCell.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "AttractionCollectionCell.h"

@implementation AttractionCollectionCell

- (void) setImage {
    self.imageView =[[UIImageView alloc] initWithFrame:CGRectMake(10,10,50,50)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.image=[UIImage imageNamed:@"favor-icon-red"];
    [self.contentView addSubview:self.imageView];
}

@end
