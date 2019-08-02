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

@protocol TravelViewDelegate;

@interface TravelView : UIView

@property (strong, nonatomic) CAShapeLayer *dashedLine;
@property (strong, nonatomic) Commute *commute;
@property (strong, nonatomic) UILabel *timeTravelLabel;
@property (weak, nonatomic) id<TravelViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame startPlace:(Place *)start endPlace:(Place *)end;

@end

@protocol TravelViewDelegate

- (void)travelView:(TravelView *)travelView didTap:(Commute *)commute;

@end

NS_ASSUME_NONNULL_END
