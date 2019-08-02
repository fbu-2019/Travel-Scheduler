//
//  PlaceWebsiteViewController.h
//  Travel Scheduler
//
//  Created by gilemos on 7/31/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlaceWebsiteViewController : UIViewController
    
@property(strong,nonatomic) WKWebView *webView;
@property (strong, nonatomic) NSString *websiteURL;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@end

NS_ASSUME_NONNULL_END
