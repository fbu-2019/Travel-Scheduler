//
//  DetailHeaderCell.h
//  Travel Scheduler
//
//  Created by aliu18 on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DetailsViewSetSelectedPlaceProtocol;

@interface DetailHeaderCell : UITableViewCell

@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) NSString *placeName;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UIImageView *mapImageView;
@property (strong, nonatomic) NSMutableArray *arrayOfStarImageViews;
@property (strong, nonatomic) NSMutableArray *arrayOfTypeLabels;
@property (strong, nonatomic) NSArray *colorArray;
@property (strong, nonatomic) UILabel *placeNameLabel;
@property (strong, nonatomic) UIButton *goingButton;
@property (strong, nonatomic) UIButton *websiteButton;
@property (strong, nonatomic) Place *place;
@property (nonatomic) int width;
@property (nonatomic, weak)id<DetailsViewSetSelectedPlaceProtocol>selectedPlaceProtocolDelegate;

- (instancetype)initWithWidth:(int)width andPlace:(Place *)givenPlace;
@end

@protocol DetailsViewSetSelectedPlaceProtocol
- (void)updateSelectedPlacesArrayWithPlace:(Place *)place;
@end

NS_ASSUME_NONNULL_END
