//
//  MoreOptionViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MoreOptionViewController.h"
#import "AttractionCollectionCell.h"
#import "APITesting.h"
#import "placeObjectTesting.h"
#import "TravelSchedulerHelper.h"
#import "Date.h"
#import "DetailsViewController.h"
@import GooglePlaces;

@interface MoreOptionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, AttractionCollectionCellDelegate>
@end

@implementation MoreOptionViewController

#pragma mark - MoreOptionViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createCollectionView];
    UILabel *label = makeHeaderLabel(self.stringType);
    [self.view addSubview:label];
    [self.collectionView reloadData];
    self.scheduleButton = makeButton(@"Generate Schedule", CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), self.collectionView.frame.origin.y + CGRectGetHeight(self.collectionView.frame));
    [self.scheduleButton addTarget:self action:@selector(makeSchedule) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scheduleButton];
}

#pragma mark - UICollectionView delegate & data source
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.place = self.places[indexPath.row];
    [cell setImage];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return self.places.count;
    return 20; //TESTING
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - AttractionCollectionCell delegate

- (void)attractionCell:(AttractionCollectionCell *)attractionCell didTap:(Place *)place
{
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] init];
    detailsViewController.place = attractionCell.place;
    [self.navigationController pushViewController:detailsViewController animated:true];
}

#pragma mark - MoreOptionViewController helper functions

- (void)createCollectionView
{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    CGRect screenFrame = self.view.frame;
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(5, 150, CGRectGetWidth(screenFrame) - 10, CGRectGetHeight(screenFrame) - 300) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
}

#pragma mark - segue to schedule

- (void)makeSchedule {
    [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:TRUE];
    [self.tabBarController setSelectedIndex: 1];
}

@end
