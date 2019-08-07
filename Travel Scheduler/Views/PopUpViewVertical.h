//
//  PopUpViewVertical.h
//  Travel Scheduler
//
//  Created by gilemos on 8/6/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PopUpView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PopUpViewVerticalDelegate;

@interface PopUpViewVertical : PopUpView
@property (strong, nonatomic)UIButton *okButton;
@property (strong, nonatomic)UIButton *cancelButton;
@property(weak, nonatomic)id<PopUpViewVerticalDelegate> delegate;
@end

@protocol PopUpViewVerticalDelegate
- (void)didTapOk;
- (void)didTapCancel;
@end

NS_ASSUME_NONNULL_END
