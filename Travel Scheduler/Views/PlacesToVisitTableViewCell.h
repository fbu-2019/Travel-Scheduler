//
//  PlacesToVisitTableViewCell.h
//  Travel Scheduler
//
//  Created by frankboamps on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import "PlacesToVisitCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PlacesToVisitTableViewCellDelegate;
@protocol PlacesToVisitTableViewCellSetSelectedProtocol;
@protocol PlacesToVisitTableViewCellGoToMoreOptionsDelegate;

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface PlacesToVisitTableViewCell : UITableViewCell

@property (strong, nonatomic) PlacesToVisitCollectionView *collectionView;
@property (strong, nonatomic) UILabel *labelWithSpecificPlaceToVisit;
@property (strong, nonatomic) UIImageView *arrowImageView;
@property (strong, nonatomic) NSString *titleOfTypeOfPlaceToVist;
@property (nonatomic, strong) NSString *typeOfPlaces;
@property (nonatomic, strong) NSMutableArray *arrayOfPlaces;
@property (nonatomic, strong) Place *hub;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, weak) id<PlacesToVisitTableViewCellDelegate> delegate;
@property (nonatomic, weak) id<PlacesToVisitTableViewCellSetSelectedProtocol> setSelectedDelegate;
@property (nonatomic, weak) id<PlacesToVisitTableViewCellGoToMoreOptionsDelegate> goToMoreOptionsDelegate;

- (void)setCollectionViewIndexPath:(NSIndexPath *)indexPath;
- (void)setUpCellOfType:(NSString *)type;
@end

@protocol PlacesToVisitTableViewCellDelegate
- (void)placesToVisitCell:(PlacesToVisitTableViewCell *)placeToVisitCell didTap:(Place *)place;
@end

@protocol PlacesToVisitTableViewCellSetSelectedProtocol
- (void)updateSelectedPlacesArrayWithPlace:(nonnull Place *)place;
@end

@protocol PlacesToVisitTableViewCellGoToMoreOptionsDelegate
- (void)goToMoreOptionsWithType:(NSString *)type;
@end

NS_ASSUME_NONNULL_END
