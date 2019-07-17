//
//  HomeCollectionsViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "HomeCollectionsViewController.h"
#import "PlacesToVisitTableViewCell.h"
#import "HotelsTableViewCell.h"
#import "RestaurantsTableViewCell.h"
#import "AttractionsTableViewCell.h"


@interface HomeCollectionsViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>

@property(strong, nonatomic) UITableView *homeTable;
@property(strong, nonatomic) UITableViewCell *placesToVisitCell;

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation HomeCollectionsViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.homeTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.homeTable.delegate = self;
    self.homeTable.dataSource = self;
    self.homeTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.homeTable];
}


-(void) loadView{
    [super loadView];
    const NSInteger numberOfTableViewRows = 3;
    const NSInteger numberOfCollectionViewCells = 8;
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];
            [colorArray addObject:color];
        }
        [mutableArray addObject:colorArray];
    }
    self.colorArray = [NSArray arrayWithArray:mutableArray];
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}


#pragma mark - Setting Delegate functions

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.colorArray.count;
    //return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [self.homeTable dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(indexPath.row == 0) {
        static NSString *cellIdentifier1 = @"cellIdentifier";
        AttractionsTableViewCell *cell1 = (AttractionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        
        //PlacesToVisitTableViewCell *cell = [self.homeTable dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell1 == nil){
            cell1 = [[AttractionsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            CGRect myFrame = CGRectMake(10.0, 0.0, 220, 25.0);
            cell1.labelWithSpecificAttractionToVisit = [[UILabel alloc] initWithFrame:myFrame];
            cell1.labelWithSpecificAttractionToVisit.text = @"Attractions";
            cell1.labelWithSpecificAttractionToVisit.font = [UIFont boldSystemFontOfSize:17.0];
            cell1.labelWithSpecificAttractionToVisit.backgroundColor = [UIColor clearColor];
            [cell1.contentView addSubview:cell1.labelWithSpecificAttractionToVisit];
        }
        [cell1.buttonWithLabelShowingParticularAttractionToVisit setTitle:@"Attractions" forState:UIControlStateNormal];
        return cell1;
    }
    
    if(indexPath.row == 1){
        static NSString *cellIdentifier2 = @"restaurantsCellIdentifier";
        RestaurantsTableViewCell *cell2 = (RestaurantsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        //PlacesToVisitTableViewCell *cell = [self.homeTable dequeueReusableCellWithIdentifier:cellIdentifier];
        //UITableViewCell *cell = [self.homeTable dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell2 == nil){
            cell2 = [[RestaurantsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            CGRect myFrame = CGRectMake(10.0, 0.0, 220, 25.0);
            cell2.labelWithSpecificRestaurantToVisit = [[UILabel alloc] initWithFrame:myFrame];
            cell2.labelWithSpecificRestaurantToVisit.text = @"Restaurants";
            cell2.labelWithSpecificRestaurantToVisit.font = [UIFont boldSystemFontOfSize:17.0];
            cell2.labelWithSpecificRestaurantToVisit.backgroundColor = [UIColor clearColor];
            [cell2.contentView addSubview:cell2.labelWithSpecificRestaurantToVisit];
        }
        [cell2.buttonWithLabelShowingParticularRestaurantToVisit setTitle:@"Restaurants" forState:UIControlStateNormal];
        return cell2;
    }
    
    if (indexPath.row == 2){
        static NSString *cellIdentifier3 = @"hotelssCellIdentifier";
        HotelsTableViewCell *cell3 = (HotelsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
        //PlacesToVisitTableViewCell *cell = [self.homeTable dequeueReusableCellWithIdentifier:cellIdentifier];
        //UITableViewCell *cell = [self.homeTable dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell3 == nil){
            cell3 = [[HotelsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            CGRect myFrame = CGRectMake(10.0, 0.0, 220, 25.0);
            cell3.labelWithSpecificHotelToVisit = [[UILabel alloc] initWithFrame:myFrame];
            cell3.labelWithSpecificHotelToVisit.text = @"Hotels";
            cell3.labelWithSpecificHotelToVisit.font = [UIFont boldSystemFontOfSize:17.0];
            cell3.labelWithSpecificHotelToVisit.backgroundColor = [UIColor clearColor];
            [cell3.contentView addSubview:cell3.labelWithSpecificHotelToVisit];
        }
        [cell3.buttonWithLabelShowingParticularHotelToVisit setTitle:@"Hotels" forState:UIControlStateNormal];
        return cell3;
    }
    return cell;
}


//-(void)tableView:(UITableView *)tableView willDisplayCell:(UICollectionViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(indexPath.row == 0){
//        //cell = [[AttractionsTableViewCell alloc] init];
//    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
//    NSInteger index = cell.placesToVisitCollectionView.indexPath.row;
//    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
//    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
//    }
//}


-(void)tableView:(UITableView *)tableView
didEndDisplayingCell:(PlacesToVisitTableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat horizontalOffset = cell.collectionView.contentOffset.x;
    NSInteger index = cell.placesToVisitCollectionView.indexPath.row;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor clearColor];
    if ([tableView isEqual:self.homeTable]){
        UILabel *result = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, tableView.bounds.size.width, 30)];
        result.font = [UIFont boldSystemFontOfSize:24.0f];
        result.text = [NSString stringWithFormat:@"%@ ", @"Places To Visit"];
        result.backgroundColor = [UIColor clearColor];
        [headerView addSubview:result];
    }
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}



#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionViewArray = self.colorArray[[(AFIndexedCollectionView *)collectionView indexPath].row];
    return 8;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    NSArray *collectionViewArray = self.colorArray[[(AFIndexedCollectionView *)collectionView indexPath].row];
    cell.backgroundColor = collectionViewArray[indexPath.item];
    
    
    
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:100];
    //recipeImageView.image = [UIImage imageNamed:[recipeImages objectAtIndex:indexPath.row]];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo-frame.png"]];
    [self.view addSubview:recipeImageView];
    // cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:[recipeImages objectAtIndex:indexPath.row]]];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    AFIndexedCollectionView *collectionView = (AFIndexedCollectionView *)scrollView;
    NSInteger index = collectionView.indexPath.row;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
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


