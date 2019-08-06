//
//  SignInViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 8/4/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "SignInViewController.h"
#import "HomeCollectionViewController.h"
#import "FirstScreenViewController.h"
@import Firebase;
@import FirebaseAuth;
@import GoogleSignIn;
@import FirebaseUI;

@interface SignInViewController ()
@property(strong, nonatomic) FUIAuth *authUI;

@end

@implementation SignInViewController{
    FIRAuthStateDidChangeListenerHandle authStateListenerHandle;
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.authUI = [FUIAuth defaultAuthUI];
    self.authUI.delegate = self;
    NSArray<id<FUIAuthProvider>> *providers = @[ [[FUIEmailAuth alloc] init],
                                                 [[FUIGoogleAuth alloc] init],
                                                 [[FUIFacebookAuth alloc] init]];
    self.authUI.providers = providers;
    authStateListenerHandle = [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
        if ([FIRAuth auth].currentUser) {
            //TODO: (Franklin) --> Load User history
        } else {
            NSLog(@"New User");
        }
    }];
    _backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_background"]];
    [_backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:_backgroundImageView];
    [self createSignUpButton];
    [self createProceedToHomeScreenButton];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma matk - Layout Subviews

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _backgroundImageView.frame = self.view.bounds;
    self.signUpButton.frame = CGRectMake(50.0, 450.0, 310.0, 40.0);
    self.googleSignInButton.frame = CGRectMake(80.0, 300.0, 160.0, 40.0);
    self.proceedToHomePage.frame = CGRectMake(50.0, 600.0, 310.0, 40.0);
}

#pragma mark - Setting Up Google Log In

- (void) signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken accessToken:authentication.accessToken];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
            FIRUser *user = authResult.user;
            if(user){
                NSString *welcomeMessage = [NSString stringWithFormat:@"Welcome to travellama %@", user.displayName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firebase" message:welcomeMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                self.googleSignInButton.enabled = false;
            }
        }];
    } else {
        NSString *welcomeMessage = [NSString stringWithFormat:@"Sign In Failed"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firebase" message:welcomeMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    }
}

#pragma mark - Creating Buttons and Actions

- (void)createProceedToHomeScreenButton
{
    self.proceedToHomePage = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.proceedToHomePage addTarget:self action:@selector(homeScreen :) forControlEvents:UIControlEventTouchUpInside];
    [self.proceedToHomePage setTitle:@"Proceed To Home Screen" forState:UIControlStateNormal];
    self.proceedToHomePage.backgroundColor = getColorFromIndex(CustomColorRegularPink);
    self.proceedToHomePage.layer.cornerRadius = 10;
    [self.proceedToHomePage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.proceedToHomePage];
}

- (void)homeScreen:(UIButton *)sender{
    FirstScreenViewController *homeViewController = [[FirstScreenViewController alloc] init];
    [self presentViewController:homeViewController animated:YES completion:nil];
}

- (void)createSignUpButton
{
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signUpButton addTarget:self action:@selector(SignUpAuth :) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton setTitle:@"Proceed to Log In" forState:UIControlStateNormal];
    self.signUpButton.backgroundColor = getColorFromIndex(CustomColorRegularPink);
    self.signUpButton.layer.cornerRadius = 10;
    [self.signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.signUpButton];
}

- (void)SignUpAuth:(UIButton *)sender
{
    FUIAuthPickerViewController *authViewController = [[FUIAuthPickerViewController alloc] initWithAuthUI: self.authUI];
    UINavigationController *SecondNav = [[UINavigationController alloc] initWithRootViewController: authViewController];
    [self presentViewController:SecondNav animated:YES completion:nil];
}

#pragma mark - Setting up user Sign In

- (void)authUI:(FUIAuth *)authUI didSignInWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult error:(nullable NSError *)error
{
    if (error != nil){
        NSLog(@"error");
    }
    if (authDataResult !=nil){
        FirstScreenViewController *homeView = [[FirstScreenViewController alloc]init];
        [self presentViewController:homeView animated:YES completion:nil];
    }
}

#pragma mark - FUIAuthDelegate methods for Google Auth

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    return [[FUIAuth defaultAuthUI] handleOpenURL:url sourceApplication:sourceApplication];
}

@end
