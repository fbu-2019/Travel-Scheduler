//
//  FirstScreenViewController.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hub.h"

NS_ASSUME_NONNULL_BEGIN

@interface FirstScreenViewController : UIViewController

@property (strong, nonatomic) NSString *placeTypedByUser;
@property (strong, nonatomic) UITextField *beginTripDateTextField;
@property (strong, nonatomic) UITextField *endTripDateTextField;
@property(strong, nonatomic) UIDatePicker *beginTripDatePicker;
@property(strong, nonatomic) UIDatePicker *endTripDatePicker;
@property(strong, nonatomic)Hub *hub;

@end

NS_ASSUME_NONNULL_END
