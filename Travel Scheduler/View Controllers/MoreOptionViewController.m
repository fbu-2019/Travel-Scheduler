//
//  MoreOptionViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "MoreOptionViewController.h"
#import "AttractionCollectionCell.h"

@interface MoreOptionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

static UILabel* makeHeaderLabel(NSString *text) {
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(35, 75, 500, 50)];
    [label setFont: [UIFont fontWithName:@"Arial-BoldMT" size:50]];
    //label.text = text;
    label.text = @"Attractions"; //TESTING
    label.numberOfLines = 1;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.minimumScaleFactor = 10.0f/12.0f;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

@implementation MoreOptionViewController

#pragma mark - MoreOptionViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createCollectionView];
    UILabel *label = makeHeaderLabel(self.stringType);
    [self.view addSubview:label];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView delegate & data source

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.collectionView registerClass:[AttractionCollectionCell class] forCellWithReuseIdentifier:@"AttractionCollectionCell"];
    AttractionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttractionCollectionCell" forIndexPath:indexPath];
    //Place *place = self.places[indexPath.item];
    //[cell setImage:place];
    [cell setImage]; //TESTING
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //return self.places.count;
    return 20; //TESTING
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (collectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - MoreOptionViewController helper functions

- (void)createCollectionView {
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    CGRect screenFrame = self.view.frame;
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(5, 150, CGRectGetWidth(screenFrame) - 10, CGRectGetHeight(screenFrame) - 100) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.collectionView];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
