//
//  PopUpViewVertical.m
//  Travel Scheduler
//
//  Created by gilemos on 8/6/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PopUpViewVertical.h"

static void instantiateButton(UIButton *button, NSString *text)
{
    [button.titleLabel setFont:[UIFont fontWithName:@"Gotham-Light" size:16]];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor whiteColor];
}

@implementation PopUpViewVertical
    
    
- (instancetype)initWithMessage:(NSString *)message
{
    self = [super initWithMessage:message];
    
    self.okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    instantiateButton(self.okButton, @"Yeah!");
    [self.okButton addTarget:self action:@selector(didTapOk) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.okButton];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    instantiateButton(self.cancelButton, @"Cancel");
    [self.cancelButton addTarget:self action:@selector(didTapCancel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelButton];
    
    return self;
}
    
- (void)layoutSubviews
{
    int imageWidth = (2 * self.frame.size.height/3) - 15;
    int spaceBetweenItems = 8;
    int horizontalPadding = 5;
    self.imageView.frame = CGRectMake(horizontalPadding,5,imageWidth,imageWidth);
    self.messageLabel.frame = CGRectMake(self.imageView.frame.origin.x + imageWidth + spaceBetweenItems,10, self.frame.size.width - (self.imageView.frame.origin.x + imageWidth + spaceBetweenItems), (self.frame.size.height/2) - 10);
    self.okButton.frame = CGRectMake(0, (2 * self.frame.size.height)/3, self.frame.size.width/2, self.frame.size.height/3);
    self.cancelButton.frame = CGRectMake(self.frame.size.width/2, (2 * self.frame.size.height)/3, self.frame.size.width/2, self.frame.size.height/3);
}
    
- (void)didTapOk
{
    [self.delegate didTapOk];
}
    
- (void)didTapCancel
{
    [self.delegate didTapCancel];
}

@end
