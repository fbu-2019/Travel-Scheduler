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

@interface ScheduleViewController () <UICollectionViewDelegate, UICollectionViewDataSource, DateCellDelegate, PlaceViewDelegate>

@property (strong, nonatomic) NSDictionary *scheduleDictionary;
@property (strong, nonatomic) NSArray *dayPath;
@end

static int startY = 35;
static int oneHourSpace = 100;
static int leftIndent = 75;

#pragma mark - View/Label creation
static UILabel* makeTimeLabel(int num)
{
    NSString *unit = @"AM";
    if (num > 12) {
        num = num - 12;
        if (num == 12) {
            unit = @"AM";
        } else {
            unit = @"PM";
        }
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
    PlaceView *view = [[PlaceView alloc] initWithFrame:CGRectMake(leftIndent + 10, yCoord + yShift, width - 10, height) andPlace:place];
    return view;
}

@implementation ScheduleViewController

#pragma mark - ScheduleViewController lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.startDate == nil) {
        self.startDate = [NSDate date];
        self.endDate = getNextDate(self.startDate, 10);
    }
    
    //TESTING
    self.numHours = 18; //Should be set by user in a settings page
    
    [self makeScheduleDictionary];
    [self makeDatesArray];
    self.view.backgroundColor = [UIColor whiteColor];
    self.header = makeHeaderLabel(getMonth(self.startDate));
    [self.view addSubview:self.header];
    [self createCollectionView];
    [self createScrollView];
    [self dateCell:nil didTap:removeTime(self.startDate)];
}

#pragma mark - UICollectionView delegate & data source
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.collectionView registerClass:[DateCell class] forCellWithReuseIdentifier:@"DateCell"];
    DateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DateCell" forIndexPath:indexPath];
    NSDate *date = self.dates[indexPath.item];
    date = removeTime(date);
    NSDate *startDateDefaultTime = removeTime(self.startDate);
    NSDate *endDateDefaultTime = removeTime(self.endDate);
    [cell makeDate:date givenStart:getNextDate(startDateDefaultTime, -1) andEnd:getNextDate(endDateDefaultTime, 1)];
    cell.delegate = self;
    if (cell.date != self.selectedDate) {
        [cell setUnselected];
    } else {
        [cell setSelected];
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dates.count;
}

#pragma mark - ScheduleViewController helper functions
- (void)createCollectionView
{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    CGRect screenFrame = self.view.frame;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.header.frame) + self.header.frame.origin.y + 15, CGRectGetWidth(screenFrame) + 7, 50) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor yellowColor]];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView reloadData];
}

- (void)makeDatesArray
{
    NSDate *startSunday = self.startDate;
    startSunday = getSunday(startSunday, -1);
    self.endDate = [[self.scheduleDictionary allKeys] lastObject];
    NSDate *endSunday = self.endDate;
    endSunday = getSunday(endSunday, 1);
    self.dates = [[NSMutableArray alloc] init];
    //while (startSunday < endSunday) {
    while ([startSunday compare:endSunday] == NSOrderedAscending) {
        [self.dates addObject:startSunday];
        startSunday = getNextDate(startSunday, 1);
    }
}

- (void)createScrollView
{
    int yCoord = self.header.frame.origin.y + CGRectGetHeight(self.header.frame) + 50;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, yCoord + 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - yCoord - 35)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = YES;
    [self makeDefaultViews];
    [self makePlaceSections];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 1215);
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

- (void)makePlaceSections
{
    int yShift = CGRectGetHeight(makeTimeLabel(12).frame) / 2;
    int width = CGRectGetWidth(self.scrollView.frame) - leftIndent - 5;
    for (Place *place in self.dayPath) {
        PlaceView *view = makePlaceView(place, 8, width, yShift);
        view.delegate = self;
        [self.scrollView addSubview:view];
    }
}

#pragma mark - DateCell delegate
- (void)dateCell:(nonnull DateCell *)dateCell didTap:(nonnull NSDate *)date
{
    self.selectedDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:date];
    [self.collectionView reloadData];
    int dayNum = getDayNumber(date);
    NSString *dateMonth = getMonth(date);
    self.header.text = dateMonth;
    self.dayPath = [self.scheduleDictionary objectForKey:date];
    [self createScrollView];
}

#pragma mark - PlaceView delegate
- (void)placeView:(PlaceView *)view didTap:(Place *)place
{
    DetailsViewController *detailsViewController = [[DetailsViewController alloc] init];
    detailsViewController.place = place;
    [self.navigationController pushViewController:detailsViewController animated:true];
}

#pragma mark - ScheduleViewController schedule helper function
- (void) makeScheduleDictionary
{
    Schedule *scheduleMaker = [[Schedule alloc] initWithArrayOfPlaces:nil withStartDate:self.startDate withEndDate:self.endDate];
    [scheduleMaker generateSchedule];
    self.scheduleDictionary = scheduleMaker.finalScheduleDictionary;
    testPrintSchedule(self.scheduleDictionary);
}

@end
