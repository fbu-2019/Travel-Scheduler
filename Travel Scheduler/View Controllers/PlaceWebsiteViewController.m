//
//  PlaceWebsiteViewController.m
//  Travel Scheduler
//
//  Created by gilemos on 7/31/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "PlaceWebsiteViewController.h"

@interface PlaceWebsiteViewController () <WKNavigationDelegate>

@end

@implementation PlaceWebsiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:self.websiteURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    _webView.navigationDelegate = self;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.spinner setCenter:self.view.center];
    self.spinner.backgroundColor = [UIColor lightGrayColor];
    [self.spinner hidesWhenStopped];
    [_webView addSubview:self.spinner];
    [self.spinner startAnimating];
    [_webView loadRequest:request];
    _webView.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:_webView];
    
}
    
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
{
    [self.spinner stopAnimating];
}
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
