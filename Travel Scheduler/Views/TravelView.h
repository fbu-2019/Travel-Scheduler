//
//  TravelView.h
//  Travel Scheduler
//
//  Created by aliu18 on 8/1/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commute.h"
#import "Place.h"

@class Commute;
@class Place;

NS_ASSUME_NONNULL_BEGIN

@interface TravelView : UIView

@property (strong, nonatomic) CAShapeLayer *dashedLine;
@property (strong, nonatomic) Commute *commute;
@property (strong, nonatomic) UILabel *timeTravelLabel;

- (instancetype)initWithFrame:(CGRect)frame startPlace:(Place *)start endPlace:(Place *)end;

@end

NS_ASSUME_NONNULL_END
