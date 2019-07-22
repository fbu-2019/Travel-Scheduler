//
//  HomeCollectionViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "Hub.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeCollectionViewController : UIViewController

@property(strong, nonatomic) NSString *hubPlaceName;
@property(strong, nonatomic)Hub *hub;

@end

NS_ASSUME_NONNULL_END
