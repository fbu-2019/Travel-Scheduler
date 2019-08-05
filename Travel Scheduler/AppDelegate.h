//
//  AppDelegate.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/15/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
@import GoogleSignIn;
@import FirebaseAuth;
@import FirebaseUI;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate, FUIAuthDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

