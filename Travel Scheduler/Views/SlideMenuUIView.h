//
//  SlideMenuUIView.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/22/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SlideMenuUIViewDelegate;

@interface SlideMenuUIView : UIView
{
    NSArray *menuArray;
}

@property(strong, nonatomic) UITableView *slideInTableView;
@property(strong, nonatomic) UIButton *closeSlideInTableViewButton;
@property(weak, nonatomic) id<SlideMenuUIViewDelegate> delegate;

- (void) loadView;
- (void) createButtonToCloseSlideIn;

@end

@protocol SlideMenuUIViewDelegate

- (void)animateViewBackwards:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
