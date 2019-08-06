//
//  PopUpView.m
//  Travel Scheduler
//
//  Created by gilemos on 8/5/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PopUpView.h"
#import "TravelSchedulerHelper.h"

static void instantiateImageView(UIImageView *imageView)
{
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = 5;
    imageView.clipsToBounds = YES;
    [imageView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
}

static void instantiateMessageLabel(UILabel *messageLabel, NSString *messageString)
{
    [messageLabel setFont: [UIFont fontWithName:@"Gotham-Light" size:15]];
    messageLabel.text = messageString;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.numberOfLines = 2;
    [messageLabel sizeToFit];
}

@implementation PopUpView

- (instancetype)initWithMessage:(NSString *)message
{
    self = [super init];
    self.backgroundColor = getColorFromIndex(CustomColorRegularPink);
    self.imageView = [[UIImageView alloc] init];
    instantiateImageView(self.imageView);
    [self addSubview:self.imageView];
    
    self.messageString = message;
    self.messageLabel = [[UILabel alloc] init];
    instantiateMessageLabel(self.messageLabel, self.messageString);
    
    return self;
}
    
- (void)layoutSubviews
{
    self.imageView.frame = CGRectMake(self.frame.size.width/4 + 2,0,self.frame.size.width/4 - 5,self.frame.size.height);
    self.messageLabel.frame = CGRectMake(0,0, (3 * self.frame.size.width)/4, self.frame.size.height);
}

@end
