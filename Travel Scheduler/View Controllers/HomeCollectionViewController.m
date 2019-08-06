//
//  HomeCollectionsViewController.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "HomeCollectionViewController.h"
#import "PlacesToVisitTableViewCell.h"
#import "AttractionCollectionCell.h"
#import "MoreOptionViewController.h"
#import "TravelSchedulerHelper.h"
#import "Date.h"
#import "DetailsViewController.h"
#import "Place.h"
#import "APITesting.h"
#import "PlaceObjectTesting.h"
#import "SlideMenuUIView.h"
#import "ScheduleViewController.h"
@import GoogleMaps;
@import GooglePlaces;

@interface HomeCollectionViewController () <UITableViewDelegate, UITableViewDataSource, PlacesToVisitTableViewCellDelegate, SlideMenuUIViewDelegate, DetailsViewControllerSetSelectedProtocol, PlacesToVisitTableViewCellSetSelectedProtocol, MoreOptionViewControllerSetSelectedProtocol, PlacesToVisitTableViewCellGoToMoreOptionsDelegate>

@property (nonatomic, strong) UIButton *buttonToMenu;
@property (nonatomic, strong) SlideMenuUIView *leftViewToSlideIn;
@property (nonatomic, strong) UIButton *closeLeft;
@property (nonatomic) BOOL menuViewShow;

@end

static int kTableViewBottomSpace = 100;

@implementation HomeCollectionViewController

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.menuViewShow = NO;
    self.home = nil;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor darkGrayColor],
       NSFontAttributeName:[UIFont fontWithName:@"Gotham-Light" size:21]}];
    
    self.homeTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.homeTable.delegate = self;
    self.homeTable.dataSource = self;
    self.homeTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.homeTable setAllowsSelection:YES];
    [self.view addSubview:self.homeTable];
    
    self.scheduleButton = makeScheduleButton(@"Generate Schedule");
    self.scheduleButton.backgroundColor = getColorFromIndex(CustomColorLightPink);
    self.scheduleButton.enabled = NO;
    [self.scheduleButton addTarget:self action:@selector(makeSchedule) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scheduleButton];
    
    [self makeCloseButton];
    [self.homeTable reloadData];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.homeTable addSubview: _refreshControl];
    [self.homeTable sendSubviewToBack: self.refreshControl];
    
    [self createButtonToMenu];
    [self.navigationController.view addSubview:self.buttonToMenu];
    [self createInitialSlideView];
    if(self.arrayOfSelectedPlaces == nil) {
        self.arrayOfSelectedPlaces = [[NSMutableArray alloc] init];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    int tableViewHeight = CGRectGetHeight(self.view.frame) - kTableViewBottomSpace;
    self.homeTable.frame = CGRectMake(5, 0, CGRectGetWidth(self.view.frame) - 15, tableViewHeight);
    
    self.scheduleButton.frame = CGRectMake(25, CGRectGetHeight(self.view.frame) - self.bottomLayoutGuide.length - 60, CGRectGetWidth(self.view.frame) - 2 * 25, 50);
    self.buttonToMenu.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 55, self.navigationController.view.frame.origin.y + 45, 40, 40);
    self.leftViewToSlideIn.frame = (!self.menuViewShow) ? CGRectMake(CGRectGetWidth(self.view.frame), self.topLayoutGuide.length, 300, CGRectGetHeight(self.view.frame)) : CGRectMake(CGRectGetWidth(self.view.frame)-300, self.topLayoutGuide.length, 300, CGRectGetHeight(self.view.frame));
}

#pragma mark - Setting up refresh control

- (void)handleRefresh:(UIRefreshControl *)refreshControl
{
    [self.homeTable reloadData];
    [self.homeTable layoutIfNeeded];
    [refreshControl endRefreshing];
}

#pragma mark - Methods to Create Menu Button and Action

-(void) createButtonToMenu
{
    self.buttonToMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonToMenu setFrame:CGRectZero];
    [self.buttonToMenu setBackgroundImage:[UIImage imageNamed:@"menu_icon"] forState: UIControlStateNormal];
    self.buttonToMenu.layer.cornerRadius = 10;
    self.buttonToMenu.clipsToBounds = YES;
    [self.buttonToMenu addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
}

- (void) buttonClicked: (id)sender
{
    [self animateView];
    [self.leftViewToSlideIn createButtonToCloseSlideIn];
}

#pragma mark - Method to create slide view

- (void) createInitialSlideView
{
    self.leftViewToSlideIn = [[SlideMenuUIView alloc] initWithFrame:CGRectZero];
    self.leftViewToSlideIn.delegate = self;
    [self.leftViewToSlideIn loadView];
    self.leftViewToSlideIn.backgroundColor = [UIColor whiteColor];
    [self.navigationController.view addSubview:self.leftViewToSlideIn];
}

#pragma mark - Method to animate slide in view

- (void) animateView
{
    self.menuViewShow = YES;
    [UIView animateWithDuration: 0.75 animations:^{
        self.leftViewToSlideIn.frame = CGRectMake(CGRectGetWidth(self.view.frame)-300, self.topLayoutGuide.length, 300, CGRectGetHeight(self.view.frame));
        [self.leftViewToSlideIn layoutIfNeeded];
    }];
}

- (void) makeCloseButton
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(returnToFirstScreen:)];
    [item setTitleTextAttributes:@{
                                   NSFontAttributeName: [UIFont fontWithName:@"Gotham-Light" size:17.0],
                                   NSForegroundColorAttributeName: [UIColor blackColor]
                                   } forState:UIControlStateNormal];
    [self.navigationItem setLeftBarButtonItem:item animated:YES];
}

- (void)returnToFirstScreen:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayOfTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    PlacesToVisitTableViewCell *cell = (PlacesToVisitTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[PlacesToVisitTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        CGRect myFrame = CGRectMake(10.0, 0.0, 220, 25.0);
        cell.labelWithSpecificPlaceToVisit = [[UILabel alloc] initWithFrame:myFrame];
        //cell.hub = self.hub;
    }
        cell.hub = self.hub;
        [cell setUpCellOfType:self.arrayOfTypes[indexPath.row]];
        cell.labelWithSpecificPlaceToVisit.font = [UIFont boldSystemFontOfSize:17.0];
        cell.labelWithSpecificPlaceToVisit.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:cell.labelWithSpecificPlaceToVisit];
    cell.delegate = self;
    cell.setSelectedDelegate = self;
    cell.goToMoreOptionsDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.collectionView reloadData];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(PlacesToVisitTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewIndexPath:indexPath];
    NSInteger index = indexPath.row;
    CGFloat horizontalOffset = [cell.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(PlacesToVisitTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat horizontalOffset = cell.collectionView.contentOffset.x;
    NSInteger index = indexPath.row;
    cell.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self goToMoreOptionsViewControllerWithType:self.arrayOfTypes[indexPath.row]];
    return indexPath;
}

#pragma mark - PlacesToVisitTableViewCell delegate

- (void)placesToVisitCell:(nonnull PlacesToVisitTableViewCell *)placeToVisitCell didTap:(nonnull Place *)place
{
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] init];
    detailsViewController.place = place;
    detailsViewController.setSelectedDelegate = self;
    [self.navigationController pushViewController:detailsViewController animated:true];
}

#pragma mark - DetailsViewControllerSetSelectedProtocol and PlacesToVisitTableViewCellSetSelectedProtocol

- (void)updateSelectedPlacesArrayWithPlace:(nonnull Place *)place
{
    if(place.selected) {
        place.selected = NO;
        [self.arrayOfSelectedPlaces removeObject:place];
        if (self.arrayOfSelectedPlaces.count == 0) {
            self.scheduleButton.backgroundColor = getColorFromIndex(CustomColorLightPink);
            self.scheduleButton.enabled = NO;
        }
    } else {
        place.selected = YES;
        [self.arrayOfSelectedPlaces addObject:place];
        self.scheduleButton.backgroundColor = getColorFromIndex(CustomColorRegularPink);
        self.scheduleButton.enabled = YES;
    }
    [self sortArrayOfPlacesOfType:place.specificType];
    [self.homeTable reloadData];
}
    
#pragma mark - PlacesToVisitTableViewCellGoToMoreOptionsDelegate
- (void)goToMoreOptionsWithType:(NSString *)type
{
    [self goToMoreOptionsViewControllerWithType:type];
}

#pragma mark - SlideMenuUIView delegate

- (void) animateViewBackwards:(UIView *)view
{
    self.menuViewShow = false;
    [UIView animateWithDuration: 0.5 animations:^{
        view.frame = CGRectMake(CGRectGetMaxX(view.frame), self.topLayoutGuide.length, 300 , 4000);
        [view layoutIfNeeded];
    }];
}

#pragma mark - segue to schedule

- (void)makeSchedule
{
    if(self.arrayOfSelectedPlaces.count > 0) {
        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:TRUE];
        ScheduleViewController *destView = (ScheduleViewController *)[[self.tabBarController.viewControllers objectAtIndex:1] topViewController];
        bool isFirstSchedule = NO;
        if(destView.selectedPlacesArray == nil) {
            isFirstSchedule = YES;
        }
        destView.selectedPlacesArray = self.arrayOfSelectedPlaces;
        destView.regenerateEntireSchedule = true;
        destView.home = self.home ? self.home : self.hub;
        destView.hub = self.hub;
        if(!isFirstSchedule) {
            [destView scheduleViewSetup];
        }
        [self.tabBarController setSelectedIndex: 1];
    }
}
    
- (void)goToMoreOptionsViewControllerWithType:(NSString *)type {
    MoreOptionViewController *moreOptionViewController = [[MoreOptionViewController alloc] init];
    moreOptionViewController.places = [[NSMutableArray alloc]init];
    moreOptionViewController.hub = self.hub;
    moreOptionViewController.correctType = type;
    if ([moreOptionViewController.correctType isEqualToString:@"shopping_mall"]) {
        moreOptionViewController.stringType = @"Mall";
    } else {
        NSString *firstCharacterInString = [[moreOptionViewController.correctType substringToIndex:1] capitalizedString];
        NSString *capitalizedString = [moreOptionViewController.correctType stringByReplacingCharactersInRange:NSMakeRange(0,1) withString: firstCharacterInString];
        moreOptionViewController.stringType = capitalizedString;
    }
    moreOptionViewController.places = self.hub.dictionaryOfArrayOfPlaces[moreOptionViewController.correctType];
    moreOptionViewController.setSelectedDelegate = self;
    [self.navigationController pushViewController:moreOptionViewController animated:true];
}
    
#pragma mark - Sorting helper methods

- (void)sortArrayOfPlacesOfType:(NSString *)type {
    if(self.arrayOfSelectedPlaces.count == 0) {
        return;
    }
    NSMutableArray *arrayToBeSorted = self.hub.dictionaryOfArrayOfPlaces[type];
    for(int outerIndex = 1; outerIndex < (int)arrayToBeSorted.count; outerIndex++) {
        int innerIndex = outerIndex;
        Place *curPlace = arrayToBeSorted[innerIndex];
        while(innerIndex > 0) {
            Place *prevPlace = arrayToBeSorted[innerIndex - 1];
            if(!prevPlace.selected && curPlace.selected) {
                [self swapArrayOfPlaceOfType:type fromIndex:innerIndex toIndex:innerIndex - 1];
            }
            else {
                break;
            }
            innerIndex = innerIndex - 1;
        }
    }
}
    
- (void)swapArrayOfPlaceOfType:(NSString *)type fromIndex:(int)firstIndex toIndex:(int)secondIndex
{
    Place *elementToComeFirst = self.hub.dictionaryOfArrayOfPlaces[type][secondIndex];
    Place *elementToComeSecond = self.hub.dictionaryOfArrayOfPlaces[type][firstIndex];
    self.hub.dictionaryOfArrayOfPlaces[type][firstIndex] = elementToComeFirst;
    self.hub.dictionaryOfArrayOfPlaces[type][secondIndex] = elementToComeSecond;
}
@end


