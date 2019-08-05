//
//  AppDelegate.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/15/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeCollectionViewController.h"
#import "MoreOptionViewController.h"
#import "ScheduleViewController.h"
#import "FirstScreenViewController.h"
#import "EditPlaceViewController.h"
#import "SignInViewController.h"
#import "SignInPickerViewController.h"
#import "SIgnInPickerViewController.h"
@import UIKit;
@import Firebase;
@import FirebaseUI;
@import FirebaseAuth;
@import GoogleMaps;
@import GooglePlaces;

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [FIRApp configure];
    FUIAuth *authUI = [FUIAuth defaultAuthUI];
    authUI.delegate = self;
   // self.handle = [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
   //                }];
    
    
//    NSArray<id<FUIAuthProvider>> *providers = @[
//                                               [[FUIEmailAuth alloc] init],
//                                               [[FUIGoogleAuth alloc] init],
//                                               [[FUIFacebookAuth alloc] init],
//                                              // [[FUITwitterAuth alloc] init],
//                                             //  [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]]
//                                                ];
//    authUI.providers = providers;
//    UINavigationController *authViewController = [authUI authViewController];
//
//
    FIRActionCodeSettings *actionCodeSettings = [[FIRActionCodeSettings alloc] init];
    actionCodeSettings.URL = [NSURL URLWithString:@"https://travellama.appspot.com"];
    actionCodeSettings.handleCodeInApp = YES;
    [actionCodeSettings setAndroidPackageName:@"com.firebase.example"
                        installIfNotAvailable:NO
                               minimumVersion:@"12"];
//
//    id<FUIAuthProvider> provider = [[FUIEmailAuth alloc] initAuthAuthUI:[FUIAuth defaultAuthUI] signInMethod:FIREmailLinkAuthSignInMethod forceSameDevice:NO allowNewEmailAccounts:YES actionCodeSetting:actionCodeSettings];
//
//   // [FUIAuth.defaultAuthUI handleOpenURL:url sourceApplication:sourceApplication];
//
//   // [FBSDKLoginManager.authType ] =[FIRApp defaultApp].options.clientID;
//
//
//    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
//    [GIDSignIn sharedInstance].delegate = self;
//
    [GMSServices provideAPIKey:@"AIzaSyBgacZ-FJamhQHLWZVQvyIiPnKltOH61H8"];
    [GMSPlacesClient provideAPIKey:@"AIzaSyBgacZ-FJamhQHLWZVQvyIiPnKltOH61H8"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SignInViewController *firstScreen = [[SignInViewController alloc] init];
    //FirstScreenViewController *firstScreen = [[FirstScreenViewController alloc] init];
    UINavigationController *firstNav = [[UINavigationController alloc] initWithRootViewController:firstScreen];
    
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor grayColor]}
                                           forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor blackColor]}
                                           forState:UIControlStateSelected];
    
    
    //[self.window setRootViewController:firstNav];
    [self.window setRootViewController:firstScreen];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[FIRAuth auth] APNSToken];
}


//- (BOOL)application:(nonnull UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *, id> *)options
//{
//    return [[GIDSignIn sharedInstance] handleURL:url
//                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
//                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
//}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken accessToken:authentication.accessToken];
    } else {
        NSLog(@"Sign In Failed");
    }
}

//- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
//    // Perform any operations when the user disconnects from app here.
//    // ...
//}



- (void)authUI:(FUIAuth *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error {
    // Implement this method to handle signed in user or error if any.
}

- (void)authUI:(FUIAuth *)authUI didSignInWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult error:(nullable NSError *)error {
    // Implement this method to handle signed in user (`authDataResult.user`) or error if any.
}


- (FUIAuthPickerViewController *)authPickerViewControllerForAuthUI:(FUIAuth *)authUI {
    return [[SignInPickerViewController alloc] initWithNibName:@"SignInPickerViewController" bundle:[NSBundle mainBundle] authUI:authUI];
}





//
//- (FUIEmailEntryViewController *)emailEntryViewControllerForAuthUI:(FUIAuth *)authUI {
//    return [[FUICustomEmailEntryViewController alloc] initWithNibName:@"FUICustomEmailEntryViewController"
//                                                               bundle:[NSBundle mainBundle]
//                                                               authUI:authUI];
//
//}
//
//- (FUIPasswordSignInViewController *)passwordSignInViewControllerForAuthUI:(FUIAuth *)authUI
//                                                                     email:(NSString *)email {
//    return [[FUICustomPasswordSignInViewController alloc] initWithNibName:@"FUICustomPasswordSignInViewController"
//                                                                   bundle:[NSBundle mainBundle]
//                                                                   authUI:authUI
//                                                                    email:email];
//
//}
//
//- (FUIPasswordSignUpViewController *)passwordSignUpViewControllerForAuthUI:(FUIAuth *)authUI
//                                                                     email:(NSString *)email {
//    return [[FUICustomPasswordSignUpViewController alloc] initWithNibName:@"FUICustomPasswordSignUpViewController"
//                                                                   bundle:[NSBundle mainBundle]
//                                                                   authUI:authUI
//                                                                    email:email];
//
//}
//
//- (FUIPasswordRecoveryViewController *)passwordRecoveryViewControllerForAuthUI:(FUIAuth *)authUI
//                                                                         email:(NSString *)email {
//    return [[FUICustomPasswordRecoveryViewController alloc] initWithNibName:@"FUICustomPasswordRecoveryViewController"
//                                                                     bundle:[NSBundle mainBundle]
//                                                                     authUI:authUI
//                                                                      email:email];
//
//}
//
//- (FUIPasswordVerificationViewController *)passwordVerificationViewControllerForAuthUI:(FUIAuth *)authUI
//                                                                                 email:(NSString *)email
//                                                                         newCredential:(FIRAuthCredential *)newCredential {
//    return [[FUICustomPasswordVerificationViewController alloc] initWithNibName:@"FUICustomPasswordVerificationViewController"
//                                                                         bundle:[NSBundle mainBundle]
//                                                                         authUI:authUI
//                                                                          email:email
//                                                                  newCredential:newCredential];
//}

@end

