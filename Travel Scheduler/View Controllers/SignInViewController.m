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
        }
    }];
    _backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Eiffel_5"]];
    [_backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:_backgroundImageView];
    _smallViewForButtons = [[UIView alloc] init];
    [self createsmallView];
    [self createSignUpButton];
    [self createProceedToHomeScreenButton];
}

#pragma matk - Layout Subviews

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _backgroundImageView.frame = self.view.bounds;
    self.signUpButton.frame = CGRectMake(self.view.frame.origin.x + 50, ((self.view.frame.size.height)/5) * 4 + 15, self.view.frame.size.width - 90, 40);
    self.proceedToHomePage.frame = CGRectMake(self.view.frame.origin.x + 35,((self.view.frame.size.height)/5) * 4 + 60, self.view.frame.size.width - 70, 40);
    self.smallViewForButtons.frame = CGRectMake(self.view.frame.origin.x, ((self.view.frame.size.height)/5) * 4 , self.view.frame.size.width, 200);
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

- (void)createsmallView
{
    _smallViewForButtons.center = self.view.center;
    [self.view addSubview:_smallViewForButtons];
    _smallViewForButtons.alpha = 0.7;
    _smallViewForButtons.backgroundColor = [UIColor whiteColor];
    self.smallViewForButtons.layer.cornerRadius = 10;
}

- (void)createProceedToHomeScreenButton
{
    self.proceedToHomePage = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.proceedToHomePage addTarget:self action:@selector(homeScreen :) forControlEvents:UIControlEventTouchUpInside];
    [self.proceedToHomePage setTitle:@"Skip for Now" forState:UIControlStateNormal];
    self.proceedToHomePage.backgroundColor = [UIColor clearColor];
    [self.proceedToHomePage sizeToFit];
    self.proceedToHomePage.center = self.view.center;
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
    [self.signUpButton setTitle:@"Login" forState:UIControlStateNormal];
    self.signUpButton.backgroundColor = getColorFromIndex(CustomColorRegularPink);
    [self.signUpButton sizeToFit];
    self.signUpButton.center = self.view.center;
    self.signUpButton.layer.cornerRadius = 10;
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
