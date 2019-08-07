//
//  PopUpViewLateral.h
//  Travel Scheduler
//
//  Created by gilemos on 8/6/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PopUpView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PopUpViewLateralDelegate;

@interface PopUpViewLateral : PopUpView
@property(weak, nonatomic)id<PopUpViewLateralDelegate> delegate;
@property (strong, nonatomic) UIButton *dismissButton;
@end

@protocol PopUpViewLateralDelegate
- (void)didTapDismissPopUp;
@end


NS_ASSUME_NONNULL_END
