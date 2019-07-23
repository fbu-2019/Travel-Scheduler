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

@interface ScheduleViewController () <UICollectionViewDelegate, UICollectionViewDataSource, DateCellDelegate>

@property (strong, nonatomic) UILabel *header;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *dates;
@property (strong, nonatomic) NSDate *selectedDate;
@property (nonatomic) int numHours;

@end

static int startY = 35;
static int oneHourSpace = 100;
static int leftIndent = 75;

#pragma mark - View/Label creation

static UILabel* makeTimeLabel(int num) {
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

static UIView* makeLine() {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

//NOTE: Times are formatted so that 12.5 = 12:30 and 12.25 = 12:15
//NOTE: Times must also be in military time
static UIView* makePlaceView(float startTime, float endTime, float overallStart, int width, int yShift) {
    float height = 100 * (endTime - startTime);
    int yCoord = startY + (100 * (startTime - overallStart));
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(leftIndent + 10, yCoord + yShift, width - 10, height)];
    view.backgroundColor = [UIColor blueColor];
    view.alpha = 0.25;
    return view;
}

static NSDate* getSunday(NSDate *date, int offset) {
    NSString *dayOfWeek = getDayOfWeek(date);
    while (![dayOfWeek isEqualToString:@"Sunday"]) {
        date = getNextDate(date, offset);
        dayOfWeek = getDayOfWeek(date);
    }
    return date;
}

#pragma mark - Removes time of dates for top sliding bar

static NSDate* removeTime(NSDate *date) {
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}

@implementation ScheduleViewController

#pragma mark - ScheduleViewController lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //TESTING
    self.numHours = 12; //Should be set by user in a settings page
    
    [self makeDatesArray];
    self.view.backgroundColor = [UIColor whiteColor];
    self.header = makeHeaderLabel(@"July");
    [self.view addSubview:self.header];
    [self createCollectionView];
    [self createScrollView];
}

#pragma mark - UICollectionView delegate & data source

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
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

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dates.count;
}

#pragma mark - ScheduleViewController helper functions

- (void)createCollectionView {
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    CGRect screenFrame = self.view.frame;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.header.frame) + self.header.frame.origin.y + 5, CGRectGetWidth(screenFrame) + 7, 50) collectionViewLayout:layout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor yellowColor]];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView reloadData];
}

- (void)makeDatesArray {
    NSDate *startSunday = self.startDate;
    startSunday = getSunday(startSunday, -1);
    NSDate *endSunday = self.endDate;
    endSunday = getSunday(endSunday, 1);
    self.dates = [[NSMutableArray alloc] init];
    //while (startSunday < endSunday) {
    while ([startSunday compare:endSunday] == NSOrderedAscending) {
        [self.dates addObject:startSunday];
        startSunday = getNextDate(startSunday, 1);
    }
}

- (void)createScrollView {
    int yCoord = self.header.frame.origin.y + CGRectGetHeight(self.header.frame) + 50;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, yCoord + 10, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - yCoord)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = YES;
    [self makeDefaultViews];
    [self makePlaceSections];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 1215);
    [self.view addSubview:self.scrollView];
}

- (void)makeDefaultViews {
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
    //TODO: Ideally this method would take in a list of places and reformat the places into
    //components and set the view/labels/imageViews separately for each place in a for loop...
    //But since there's no data, I'm just testing the background view part with arbitrary times.
    int yShift = CGRectGetHeight(makeTimeLabel(12).frame) / 2;
    UIView *view = makePlaceView(8.5, 10.25, 8, CGRectGetWidth(self.scrollView.frame) - leftIndent - 5, yShift); // 8:30 - 10:15
    [self.scrollView addSubview:view];
    UIView *view2 = makePlaceView(11, 13.5, 8, CGRectGetWidth(self.scrollView.frame) - leftIndent - 5, yShift); // 11 - 1:30
    [self.scrollView addSubview:view2];
    UIView *view3 = makePlaceView(15, 17.25, 8, CGRectGetWidth(self.scrollView.frame) - leftIndent - 5, yShift); // 3 - 5:15
    [self.scrollView addSubview:view3];
}

- (void)dateCell:(nonnull DateCell *)dateCell didTap:(nonnull NSDate *)date {
    //TODO: Ideally we should use the date to figure out the exact schedule
    //Probably will require a dictionary from each date to each day's list of places
    //TESTING to prove that I can change the schedule...
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, 50)];
    self.selectedDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:date];
    [self.collectionView reloadData];
    int dayNum = getDayNumber(date);
    label.text = [NSString stringWithFormat:@"Currently on day %d", dayNum];
    [self createScrollView];
    [self.scrollView addSubview:label];
}

@end
