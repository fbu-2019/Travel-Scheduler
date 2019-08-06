//
//  SignInViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 8/4/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "SignInViewController.h"
#import "SignInPickerViewController.h"
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


- (void)viewDidLoad {
    [super viewDidLoad];
    self.authUI = [FUIAuth defaultAuthUI];
    self.authUI.delegate = self;
    NSArray<id<FUIAuthProvider>> *providers = @[ [[FUIEmailAuth alloc] init],
                                                 [[FUIGoogleAuth alloc] init],
                                                 [[FUIFacebookAuth alloc] init]];
    //[[FUITwitterAuth alloc] init],
    //     [[FUIPhoneAuth alloc] initWithAuthUI:[FUIAuth defaultAuthUI]]];
    self.authUI.providers = providers;
    authStateListenerHandle = [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
        if ([FIRAuth auth].currentUser) {
            FirstScreenViewController *firstUserScreen = [[FirstScreenViewController alloc] init];
            UINavigationController *Nav = [[UINavigationController alloc] initWithRootViewController:firstUserScreen];
            //[self showViewController:authViewController sender:sender];
            //[self presentViewController:Nav animated:YES completion:nil];
        } else {
            // No user is signed in.
            // ...
        }
    }];
    //self.authUI = [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
    
    
    //[self.authUI signInWithProviderUI:FUIOAuth presentingViewController:FUIAuthPickerViewController defaultValue:nil];
    _backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_background"]];
    [_backgroundImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.view addSubview:_backgroundImageView];
    [self createSignUpButton];
    [self createProceedToHomeScreenButton];
    //    self.googleSignInButton = [[GIDSignInButton alloc] init];
    //    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    //    [GIDSignIn sharedInstance].delegate = self;
    //    [GIDSignIn sharedInstance].uiDelegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    //    [self.view addSubview:self.googleSignInButton];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _backgroundImageView.frame = self.view.bounds;
    self.signUpButton.frame = CGRectMake(50.0, 450.0, 310.0, 40.0);
    self.googleSignInButton.frame = CGRectMake(80.0, 300.0, 160.0, 40.0);
    self.proceedToHomePage.frame = CGRectMake(50.0, 600.0, 310.0, 40.0);
}

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
        // ...
    }
}


- (void)viewWillAppear:(BOOL)animated{
  //  [[FIRAuth auth] removeAuthStateDidChangeListener:_handle];
}

- (void)createProceedToHomeScreenButton
{
    self.proceedToHomePage = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.proceedToHomePage addTarget:self action:@selector(homeScreen :) forControlEvents:UIControlEventTouchUpInside];
    [self.proceedToHomePage setTitle:@"Proceed To Home Screen" forState:UIControlStateNormal];
    self.proceedToHomePage.backgroundColor = getColorFromIndex(CustomColorRegularPink);
    self.proceedToHomePage.layer.cornerRadius = 10;
    [self.proceedToHomePage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   // self.proceedToHomePage.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.proceedToHomePage];
}

- (void)homeScreen:(UIButton *)sender{
    FirstScreenViewController *homeViewController = [[FirstScreenViewController alloc] init];
    // UINavigationController *SecondNav = [[UINavigationController alloc] initWithRootViewController: homeViewController];
   // UINavigationController *SecondNav = [[UINavigationController alloc] initWithRootViewController: homeViewController];
    //[SecondNav pushViewController:homeViewController animated:YES];
    [self showViewController:homeViewController sender:sender];
    //[self presentViewController:homeViewController animated:YES completion:nil];
    
    
    // self.present(authViewController!, animated: true, completion: nil)
    // [[FIRAuth auth] signInWithCustomToken:customToken completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {}];
}


- (void)createSignUpButton
{
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signUpButton addTarget:self action:@selector(SignUpAuth :) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton setTitle:@"Proceed to Log In" forState:UIControlStateNormal];
    self.signUpButton.backgroundColor = getColorFromIndex(CustomColorRegularPink);
    self.signUpButton.layer.cornerRadius = 10;
    [self.signUpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   // self.signUpButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.signUpButton];
}

- (void)SignUpAuth:(UIButton *)sender{
    //SignInPickerViewController *authViewController = [[SignInPickerViewController alloc] initWithAuthUI: self.authUI];
   // SIgnInSelectorViewController *authViewController = [[SignInPickerViewController alloc] initWithAuthUI: self.authUI];
    FUIAuthPickerViewController *authViewController = [[FUIAuthPickerViewController alloc] initWithAuthUI: self.authUI];
    UINavigationController *SecondNav = [[UINavigationController alloc] initWithRootViewController: authViewController];
    //[self showViewController:authViewController sender:sender];
    [self presentViewController:SecondNav animated:YES completion:nil];
    //[self.navigationController setVi firstScreen];
   // [self makeKeyAndVisible];
    // self.present(authViewController!, animated: true, completion: nil)
    // [[FIRAuth auth] signInWithCustomToken:customToken completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {}];
   // self.present(authViewController!, animated: true, completion: nil)
   // [[FIRAuth auth] signInWithCustomToken:customToken completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {}];
}

- (void)authUI:(FUIAuth *)authUI didSignInWithAuthDataResult:(nullable FIRAuthDataResult *)authDataResult
         error:(nullable NSError *)error {
    // Implement this method to handle signed in user (`authDataResult.user`) or error if any.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    return [[FUIAuth defaultAuthUI] handleOpenURL:url sourceApplication:sourceApplication];
}


- (FUIAuthPickerViewController *)authPickerViewControllerForAuthUI:(FUIAuth *)authUI {
    return [[SignInPickerViewController alloc] initWithNibName:@"SignInPickerViewController" bundle:[NSBundle mainBundle] authUI:authUI];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



//- (void)viewDidLoad {
//    [super viewDidLoad];
//    NSLog(@"%s","viewDidLoad");
//    authUI = [FUIAuth defaultAuthUI];
//    authUI.delegate = self;
//    NSArray<id<FUIAuthProvider>> *providers = @[[[FUIGoogleAuth alloc] init],[[FUIFacebookAuth alloc] init]];
//    authUI.providers = providers;
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    NSLog(@"%s","viewDidAppear");
//    NSLog([self isUserSignedIn] ? @"YES":@"NO");
//    if([self isUserSignedIn] == false){
//        [self showLoginView];
//    }
//}
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//-(BOOL)isUserSignedIn{
//    NSLog(@"%s","isUserSignedIn");
//
//    FIRUser *currentUser = [[FIRAuth auth] currentUser];
//    NSLog(@"%@",currentUser);
//    if(currentUser == NULL){
//        return false;
//    }
//    else{
//        return true;
//    }
//
//}
//-(void)showLoginView{
//    NSLog(@"%s","showLoginView");
//    UINavigationController *controller = [authUI authViewController];
//    if(controller){
//        [self presentViewController:controller animated:YES completion:nil];
//    }
//}
//- (void)authUI:(FUIAuth *)authUI didSignInWithUser:(nullable FIRUser *)user error:(nullable NSError *)error {
//    if (error == nil) {
//        NSLog(@"%@",user.email);
//        NSLog(@"%@",user.displayName);
//    }
//    else{
//        NSLog(@"%@",error);
//    }
//}
//- (IBAction)signOut:(id)sender {
//    NSError *signOutError;
//    BOOL status = [[FIRAuth auth] signOut:&signOutError];
//    if (!status) {
//        NSLog(@"Error signing out: %@", signOutError);
//        return;
//    }
//    else{
//        NSLog(@"SignedOut");
//    }
//}

@end
