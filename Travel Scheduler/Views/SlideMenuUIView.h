//
//  SlideMenuUIView.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/22/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SlideMenuUIView : UIView
{
    NSArray *menuArray;
}

@property(strong, nonatomic) UITableView *slideInTableView;
@property(strong, nonatomic) UIButton *closeSlideInTableViewButton;

- (void) loadView;
- (void) createButtonToCloseSlideIn;

@end

NS_ASSUME_NONNULL_END
