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
    imageView.image = [UIImage imageNamed:@"llama.png"];
    [imageView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
}

static void instantiateMessageLabel(UILabel *messageLabel, NSString *messageString)
{
    [messageLabel setFont: [UIFont fontWithName:@"Gotham-Light" size:15]];
    messageLabel.text = messageString;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.numberOfLines = 0;
    [messageLabel sizeToFit];
}

@implementation PopUpView

- (instancetype)initWithMessage:(NSString *)message
{
    self = [super init];
    self.backgroundColor = getColorFromIndex(CustomColorLightPink);
    self.layer.cornerRadius = 5;
    [self.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    self.layer.borderWidth = 0.5;
    self.clipsToBounds = YES;
    
    self.imageView = [[UIImageView alloc] init];
    instantiateImageView(self.imageView);
    [self addSubview:self.imageView];
    
    self.messageString = message;
    self.messageLabel = [[UILabel alloc] init];
    instantiateMessageLabel(self.messageLabel, self.messageString);
    [self addSubview:self.messageLabel];

    return self;
}
    
- (void)layoutSubviews
{
    int imageWidth = self.frame.size.width/4;
    if(imageWidth >= self.frame.size.height) {
        imageWidth = self.frame.size.height - 5;
    }
    int spaceBetweenItems = 8;
    int horizontalPadding = 5;
    self.imageView.frame = CGRectMake(horizontalPadding,(self.frame.size.height - imageWidth)/2,imageWidth,imageWidth);
    self.messageLabel.frame = CGRectMake(self.imageView.frame.origin.x + imageWidth + spaceBetweenItems,0, 2 * imageWidth, self.frame.size.height);
}
@end
