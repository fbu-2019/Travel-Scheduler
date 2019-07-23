//
//  SlideMenuUIView.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/23/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SlideMenuUIView : UIView

{
    NSArray *menuArray;
}

@property(strong, nonatomic) UIButton *closeSlideInViewButton;
@property(strong, nonatomic) UITableView *slideInTableView;
- (void)loadView;
-(void) createButtonToCloseSlideInMenu;

@end

NS_ASSUME_NONNULL_END
