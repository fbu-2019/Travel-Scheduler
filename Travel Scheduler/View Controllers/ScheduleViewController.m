//
//  ScheduleViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "ScheduleViewController.h"
#import "TravelSchedulerHelper.h"
#import "DateCell.h"
#import "Schedule.h"
#import "PlaceView.h"
#import "DetailsViewController.h"
#import "placeObjectTesting.h"
#import "Date.h"
#import "EditPlaceViewController.h"

@interface ScheduleViewController () <UICollectionViewDelegate, UICollectionViewDataSource, DateCellDelegate, PlaceViewDelegate>

@property (nonatomic) int dateCellHeight;

@end

static int startY = 35;
static int oneHourSpace = 100;
static int leftIndent = 75;

#pragma mark - View/Label creation

static UILabel *makeTimeLabel(int num)
{
    NSString *unit = @"AM";
    if (num > 12) {
        num = num - 12;
        unit = (num == 12) ? @"AM" : @"PM";
    } else if (num == 12) {
        unit = @"PM";
    }
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"%d:00 %@", num, unit];
    label.textColor = [UIColor grayColor];
    UIFont *thinFont = [UIFont systemFontOfSize:15 weight:UIFontWeightThin];
    [label setFont:thinFont];
    [label sizeToFit];
    return label;
}

static UIView* makeLine()
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

//NOTE: Times are formatted so that 12.5 = 12:30 and 12.25 = 12:15
//NOTE: Times must also be in military time
static PlaceView* makePlaceView(Place *place, float overallStart, int width, int yShift)
{
    float startTime = place.arrivalTime;
    float endTime = place.departureTime;
    float height = 100 * (endTime - startTime);
    float yCoord = startY + (100 * (startTime - overallStart));
    if (height < 50) {
        return nil;
    }
    PlaceView *view = [[PlaceView alloc] initWithFrame:CGRectMake(leftIndent + 10, yCoord + yShift, width - 10, height) andPlace:place];
    return view;
}

@implementation ScheduleViewController

#pragma mark - ScheduleViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.regenerateEntireSchedule = false;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self createCollectionView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.header = makeHeaderLabel(getMonth(self.startDate), 35);
    [self.view addSubview:self.header];
    self.lockedDatePlaces = [[NSMutableDictionary alloc] init];
    if (self.startDate == nil) {
        self.startDate = [NSDate date];
        self.endDate = getNextDate(self.startDate, 2);
    }
    self.numHours = 18;
    [self scheduleViewSetup];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.header.frame = CGRectMake(10, self.topLayoutGuide.length + 10, CGRectGetWidth(self.view.frame) - 10, 50);
    [self.header sizeToFit];
    self.collectionView.collectionViewLayout = [self makeCollectionViewLayout];
    self.collectionView.frame = CGRectMake(5, CGRectGetMaxY(self.header.frame) + 15, CGRectGetWidth(self.view.frame) - 10, self.dateCellHeight);
    int scrollViewYCoord = CGRectGetMaxY(self.collectionView.frame);
    self.scrollView.frame = CGRectMake(0, scrollViewYCoord, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 150 - self.bottomLayoutGuide.length);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 1500);
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self makeDefaultViews];
    [self makePlaceSections];
}

- (void)scheduleViewSetup
{
    [self resetTravelToPlaces];
    [self makeScheduleDictionary];
    [self makeDatesArray];
    [self createScrollView];
    [self dateCell:nil didTap:removeTime(self.scheduleMaker.startDate)];
}

#pragma mark - UICollectionView delegate & data source

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.collectionView registerClass:[DateCell class] forCellWithReuseIdentifier:@"DateCell"];
    DateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DateCell" forIndexPath:indexPath];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSDate *date = self.allDates[indexPath.item];
    date = removeTime(date);
    NSDate *startDateDefaultTime = removeTime(self.startDate);
    NSDate *endDateDefaultTime = removeTime(self.scheduleEndDate);
    [cell makeDate:date givenStart:getNextDate(startDateDefaultTime, -1) andEnd:getNextDate(endDateDefaultTime, 1)];
    cell.delegate = self;
    (cell.date != self.selectedDate) ? [cell setUnselected] : [cell setSelected];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allDates.count;
}

#pragma mark - ScheduleViewController helper functions

- (void)createCollectionView
{
    UICollectionViewLayout *layout = [self makeCollectionViewLayout];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor yellowColor]];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
}

- (UICollectionViewLayout *)makeCollectionViewLayout
{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 0;
    CGFloat cellsPerLine = 7;
    CGFloat itemWidth = (CGRectGetWidth(self.view.frame) - layout.minimumInteritemSpacing * (cellsPerLine - 1)) / cellsPerLine;
    CGFloat itemHeight = getMin(60, itemWidth);
    self.dateCellHeight = itemHeight;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    return layout;
}

- (void)makeDatesArray
{
    NSDate *startSunday = self.scheduleMaker.startDate;
    startSunday = getSunday(startSunday, -1);
    self.scheduleEndDate = [[self.scheduleDictionary allKeys] valueForKeyPath:@"@max.self"];
    NSDate *endSunday = getNextDate(self.scheduleEndDate, 1);
    endSunday = getSunday(endSunday, 1);
    self.allDates = [[NSMutableArray alloc] init];
    self.dates = [[NSMutableArray alloc] init];
    while ([startSunday compare:endSunday] == NSOrderedAscending) {
        if (([startSunday compare:removeTime(self.scheduleEndDate)] != NSOrderedDescending) && ([startSunday compare:removeTime(self.startDate)] != NSOrderedAscending)) {
            [self.dates  addObject:startSunday];
        }
        [self.allDates addObject:startSunday];
        startSunday = getNextDate(startSunday, 1);
    }
}

- (void)createScrollView
{
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.delaysContentTouches = NO;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unselectView)];
    singleTap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:singleTap];
    [self.view addSubview:self.scrollView];
}

- (void)makeDefaultViews
{
    for (int i = 0; i < self.numHours; i++) {
        UILabel *timeLabel = makeTimeLabel(8 + i);
        [timeLabel setFrame:CGRectMake(leftIndent - CGRectGetWidth(timeLabel.frame) - 5, startY + (i * oneHourSpace), CGRectGetWidth(timeLabel.frame), CGRectGetHeight(timeLabel.frame))];
        [self.scrollView addSubview:timeLabel];
        UIView *line = makeLine();
        [line setFrame:CGRectMake(leftIndent, timeLabel.frame.origin.y + (CGRectGetHeight(timeLabel.frame) / 2), CGRectGetWidth(self.scrollView.frame) - leftIndent - 5, 0.5)];
        [self.scrollView addSubview:line];
    }
}

- (void)makePlaceSections {
    int yShift = CGRectGetHeight(makeTimeLabel(12).frame) / 2;
    int width = CGRectGetWidth(self.scrollView.frame) - leftIndent - 5;
    for (Place *place in self.dayPath) {
        if (place != self.home) {
            PlaceView *view = makePlaceView(place, 8, width, yShift);
            view.delegate = self;
            [self.scrollView addSubview:view];
        }
    }
}

#pragma mark - DateCell delegate

- (void)dateCell:(nonnull DateCell *)dateCell didTap:(nonnull NSDate *)date
{
    self.selectedDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:date];
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    NSString *dateMonth = getMonth(date);
    self.header.text = dateMonth;
    self.dayPath = [self.scheduleDictionary objectForKey:date];
    [self createScrollView];
}

#pragma mark - PlaceView delegate

- (void)placeView:(PlaceView *)view didTap:(Place *)place
{
    if (view == self.currSelectedView || !self.currSelectedView) {
        DetailsViewController *detailsViewController = [[DetailsViewController alloc] init];
        detailsViewController.place = place;
        [self.navigationController pushViewController:detailsViewController animated:true];
    } else {
        [self unselectView];
    }
}

- (void)tappedEditPlace:(Place *)place forView:(UIView *)view
{
    if (view == self.currSelectedView || !self.currSelectedView) {
        EditPlaceViewController *editViewController = [[EditPlaceViewController alloc] init];
        editViewController.place = place;
        editViewController.allDates = self.dates;
        editViewController.scheduleController = self;
        [self.navigationController presentModalViewController:editViewController animated:true];
    } else {
        [self unselectView];
    }
}

- (void)unselectView
{
    if (self.currSelectedView) {
        [self.currSelectedView unselect];
        self.currSelectedView = nil;
    }
}

- (void)sendViewForward:(UIView *)view
{
    [self.view bringSubviewToFront:view];
    [view setNeedsDisplay];
}


#pragma mark - ScheduleViewController schedule helper function

- (void) makeScheduleDictionary
{
    self.scheduleMaker = [[Schedule alloc] initWithArrayOfPlaces:self.selectedPlacesArray withStartDate:self.startDate withEndDate:self.endDate withHome:self.home];
    if (self.nextLockedPlace) {
        [self makeLockedDict];
    }
    self.scheduleMaker.lockedDatePlaces = self.lockedDatePlaces;
    self.nextLockedPlace = nil;
    [self.scheduleMaker generateSchedule];
    self.scheduleDictionary = self.scheduleMaker.finalScheduleDictionary;
    testPrintSchedule(self.scheduleDictionary);
}

- (void)makeLockedDict
{
    if (self.removeLockedDate) {
        NSString *removeDate = getDateAsString(self.removeLockedDate);
        NSString *removeTime = [NSString stringWithFormat: @"%ld", (long)self.removeLockedTime];
        NSMutableDictionary *lockedPlacesForDate = [self.lockedDatePlaces objectForKey:removeDate];
        [lockedPlacesForDate removeObjectForKey:removeTime];
        self.removeLockedDate = nil;
        self.removeLockedTime = nil;
    }
    NSString *stringDate = getDateAsString(self.nextLockedPlace.date);
    NSString *stringTime = [NSString stringWithFormat: @"%ld", (long)self.nextLockedPlace.scheduledTimeBlock];
    NSMutableDictionary *lockedPlacesForDate = [self.lockedDatePlaces objectForKey:stringDate];
    if (lockedPlacesForDate) {
        Place *place = [lockedPlacesForDate valueForKey:stringTime];
        if (place) {
            place.locked = NO;
        }
        [lockedPlacesForDate setValue:self.nextLockedPlace forKey:stringTime];
    } else {
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
        [temp setValue:self.nextLockedPlace forKey:stringTime];
        [self.lockedDatePlaces setObject:temp forKey:stringDate];
    }
}

#pragma mark - Data refreshing helper functions

- (void)resetTravelToPlaces
{
    for (Place *place in self.selectedPlacesArray) {
        place.hasAlreadyGone = NO;
        place.prevPlace = nil;
        if (self.regenerateEntireSchedule) {
            place.locked = false;
        }
    }
    if (self.regenerateEntireSchedule) {
        self.lockedDatePlaces = [[NSMutableDictionary alloc] init];
    }
    self.regenerateEntireSchedule = false;
}

@end
