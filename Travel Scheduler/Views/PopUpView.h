//
//  PopUpView.h
//  Travel Scheduler
//
//  Created by gilemos on 8/5/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopUpView : UIView
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) NSString *messageString;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *dismissButton;
@end

NS_ASSUME_NONNULL_END
