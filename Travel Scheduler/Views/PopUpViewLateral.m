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
    
    int spaceBetweenItems = 8;
    int buttonSize = 60;
    int messageLabelXCoord = self.imageView.frame.origin.x + self.imageView.frame.size.width + spaceBetweenItems;
    
    self.dismissButton.frame = CGRectMake(self.frame.size.width - buttonSize, 0, buttonSize, self.frame.size.height);
    self.messageLabel.frame = CGRectMake(messageLabelXCoord,0, self.frame.size.width - messageLabelXCoord - buttonSize, self.frame.size.height);
}

- (void)didTapDismiss
{
    [self.delegate didTapDismissPopUp];
}
@end
