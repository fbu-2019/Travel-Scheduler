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

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface PlacesToVisitTableViewCell : UITableViewCell

@property (strong, nonatomic) PlacesToVisitCollectionView *collectionView;
@property (strong, nonatomic) UILabel *labelWithSpecificPlaceToVisit;
@property (strong, nonatomic) NSString *titleOfTypeOfPlaceToVist;
@property (nonatomic, strong) NSString *typeOfPlaces;
@property (nonatomic, strong) NSMutableArray *arrayOfPlaces;
@property (nonatomic, strong) Place *hub;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, weak) id<PlacesToVisitTableViewCellDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *selectedPlacesArray;

- (void)setCollectionViewIndexPath:(NSIndexPath *)indexPath;
- (void)setUpCellOfType:(NSString *)type;
@end

@protocol PlacesToVisitTableViewCellDelegate
- (void)placesToVisitCell:(PlacesToVisitTableViewCell *)placeToVisitCell didTap:(Place *)place;
@end


NS_ASSUME_NONNULL_END
