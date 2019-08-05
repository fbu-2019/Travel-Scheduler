//
//  SignInPickerViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 8/4/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "SignInPickerViewController.h"
@import FirebaseAuth;

@interface SignInPickerViewController ()

@property(strong, nonatomic) UIView *backgroundView;
@property(strong, nonatomic) UIView *contentView;
@end

@implementation SignInPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.subviews[0].subviews[0].backgroundColor = [UIColor clearColor];
//    self.appPhotoImage = [[UIImageView alloc] initWithFrame:CGRectZero];
// //  _appPhotoImage.layer.contents = (id)[UIImage imageNamed:@"img.png"].CGImage;
//    [self.view insertSubview:self.appPhotoImage atIndex:0];
//    //[self.view addSubview:self.appPhotoImage];
//
//    UIScrollView *scrollView = self.view.subviews[0];
//    scrollView.backgroundColor =[UIColor clearColor];
//    UIView *contentView = scrollView.subviews[0];
//    contentView.backgroundColor = [UIColor clearColor];
//    //UIImage *backgroundImage = [UIImage imageNamed: ];
//   // self.appPhotoImage.image = []
//    self.appPhotoImage.backgroundColor=[UIColor blueColor];
//   // self.appPhotoImage.contentMode = UI scaletofill
//    [self.view insertSubview:self.appPhotoImage atIndex:0];
    
    //[super viewDidLoad];
    
   // _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
   // _backgroundView.layer.contents = (id)[UIImage imageNamed:@"img.png"].CGImage;

//    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
//    _backgroundView.layer.contents = (id)[UIImage imageNamed:@"img.png"].CGImage;
//    [self.view insertSubview:_backgroundView atIndex:0];

    _backgroundView = self.view.subviews[0];
    _backgroundView.backgroundColor=[UIColor clearColor];
    _contentView = _backgroundView.subviews[0];
    _contentView.backgroundColor = [UIColor clearColor];

    _appPhotoImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_background"]];
    [self.appPhotoImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.view.subviews[0].subviews[0] insertSubview:_appPhotoImage atIndex:0];
//
    
    
    
    
//    self.appPhotoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    self.appPhotoImage.image = [UIImage imageNamed:@"login_background"];
//    [self.appPhotoImage setContentMode:UIViewContentModeScaleAspectFill];
//    [self.view insertSubview:self.appPhotoImage atIndex:0];
    
   
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //_backgroundView.frame = self.view.bounds;
    _appPhotoImage.frame = self.view.bounds;
}

//- (void)viewWillLayoutSubviews{
//    [super viewDidLayoutSubviews];
//    _appPhotoImage.frame = self.view.bounds;
//   // self.appPhotoImage.frame = CGRectMake(10, 100, 200, 200);
//}

- (void)addPhotoToImageView{
    self.appPhotoImage.backgroundColor =[UIColor blueColor];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
