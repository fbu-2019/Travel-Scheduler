//
//  PopUpViewLateral.m
//  Travel Scheduler
//
//  Created by gilemos on 8/6/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PopUpViewLateral.h"

static void instantiateDismissButton(UIButton *button)
{
    [button.titleLabel setFont:[UIFont fontWithName:@"Gotham-Light" size:16]];
    [button setTitle:@"OK" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
}

@implementation PopUpViewLateral

- (instancetype)initWithMessage:(NSString *)message
{
    self = [super initWithMessage:message];
    
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    instantiateDismissButton(self.dismissButton);
    [self.dismissButton addTarget:self action:@selector(didTapDismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.dismissButton];
    
    return self;
}
    
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    int imageWidth = self.frame.size.width/4;
    if(imageWidth >= self.frame.size.height) {
        imageWidth = self.frame.size.height - 5;
    }
    int spaceBetweenItems = 8;
    int horizontalPadding = 5;
    
    self.dismissButton.frame = CGRectMake((self.messageLabel.frame.origin.x + self.messageLabel.frame.size.width + spaceBetweenItems), 0, self.frame.size.width - (self.messageLabel.frame.origin.x + self.messageLabel.frame.size.width + spaceBetweenItems) - spaceBetweenItems , self.frame.size.height);
}

- (void)didTapDismiss
{
    [self.delegate didTapDismissPopUp];
}
@end
