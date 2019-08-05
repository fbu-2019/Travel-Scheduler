//
//  SignInViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 8/4/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleSignIn;
@import FirebaseUI;
@import Firebase;


NS_ASSUME_NONNULL_BEGIN

@interface SignInViewController : UIViewController <GIDSignInDelegate, GIDSignInUIDelegate, FUIAuthDelegate>

@property(strong, nonatomic) GIDSignInButton *googleSignInButton;
@property(strong, nonatomic) UIButton *signUpButton;
@property(strong, nonatomic) FUIGoogleAuth *signInToGoogle;
@property(strong, nonatomic) UIButton *proceedToHomePage;
@property(strong, nonatomic) UIImageView *backgroundImageView;

@end

NS_ASSUME_NONNULL_END
