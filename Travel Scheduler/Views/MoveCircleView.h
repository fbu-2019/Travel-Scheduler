//
//  MoveCircleView.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/25/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceView.h"

@class PlaceView;

NS_ASSUME_NONNULL_BEGIN

@interface MoveCircleView : UIView

@property (strong, nonatomic) PlaceView *view;
@property (nonatomic) BOOL top;

- (instancetype)initWithView:(PlaceView *)view top:(BOOL)top;
- (void)updateFrame;

@end

NS_ASSUME_NONNULL_END
