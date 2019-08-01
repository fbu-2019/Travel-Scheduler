//
//  TravelView.h
//  Travel Scheduler
//
//  Created by aliu18 on 8/1/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@class Place;

NS_ASSUME_NONNULL_BEGIN

@interface TravelView : UIView

@property (strong, nonatomic) CAShapeLayer *dashedLine;
@property (strong, nonatomic) Place *startPlace;
@property (strong, nonatomic) Place *endPlace;

- (instancetype)initWithFrame:(CGRect)frame startPlace:(Place *)start endPlace:(Place *)end;

@end

NS_ASSUME_NONNULL_END
