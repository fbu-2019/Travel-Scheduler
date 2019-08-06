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
    FIRActionCodeSettings *actionCodeSettings = [[FIRActionCodeSettings alloc] init];
    actionCodeSettings.URL = [NSURL URLWithString:@"https://travellama.appspot.com"];
    actionCodeSettings.handleCodeInApp = YES;
    [actionCodeSettings setAndroidPackageName:@"com.firebase.example"
                        installIfNotAvailable:NO
                               minimumVersion:@"12"];
    [GMSServices provideAPIKey:@"AIzaSyBgacZ-FJamhQHLWZVQvyIiPnKltOH61H8"];
    [GMSPlacesClient provideAPIKey:@"AIzaSyBgacZ-FJamhQHLWZVQvyIiPnKltOH61H8"];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SignInViewController *firstScreen = [[SignInViewController alloc] init];
    UINavigationController *firstNav = [[UINavigationController alloc] initWithRootViewController:firstScreen];
    
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor grayColor]}
                                           forState:UIControlStateNormal];
    [UITabBarItem.appearance setTitleTextAttributes:
     @{NSForegroundColorAttributeName : [UIColor blackColor]}
                                           forState:UIControlStateSelected];
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

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken accessToken:authentication.accessToken];
    } else {
        NSLog(@"Sign In Failed");
    }
}


- (void)authUI:(FUIAuth *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error {
    // Implement this method to handle signed in user or error if any.
}

- (void)authUI:(FUIAuth *)authUI didSignInWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult error:(nullable NSError *)error {
    // Implement this method to handle signed in user (`authDataResult.user`) or error if any.
}

@end

