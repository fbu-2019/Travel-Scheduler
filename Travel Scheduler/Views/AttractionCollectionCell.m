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
    self.view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 70, 70)];
    UIImageView *pic =[[UIImageView alloc] initWithFrame:CGRectMake(10,10,50,50)];
    pic.image=[UIImage imageNamed:@"favor-icon-red"];
    [self.view addSubview:pic];
}

@end
