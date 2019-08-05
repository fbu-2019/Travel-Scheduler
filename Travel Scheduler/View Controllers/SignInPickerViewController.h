//
//  SignInPickerViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 8/4/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <FirebaseUI/FirebaseUI.h>
@import FirebaseUI;

NS_ASSUME_NONNULL_BEGIN

@interface SignInPickerViewController : FUIAuthPickerViewController

@property (strong, nonatomic) UIImageView *appPhotoImage;

@end

NS_ASSUME_NONNULL_END
