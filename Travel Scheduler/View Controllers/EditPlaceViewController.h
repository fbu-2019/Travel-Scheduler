//
//  EditPlaceViewController.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/25/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditPlaceViewController : UIViewController

@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) NSArray *allDates;

@end

NS_ASSUME_NONNULL_END
