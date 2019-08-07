//
//  ScheduleViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "ScheduleViewController.h"
#import "TravelSchedulerHelper.h"
#import "HomeCollectionViewController.h"
#import "DateCell.h"
#import "Schedule.h"
#import "PlaceView.h"
#import "DetailsViewController.h"
#import "placeObjectTesting.h"
#import "Date.h"
#import "EditPlaceViewController.h"
#import "TravelView.h"
#import "CommuteDetailsViewController.h"
#import "CalendarEvent.h"
#import "MapViewController.h"

@interface ScheduleViewController () <UICollectionViewDelegate, UICollectionViewDataSource, DateCellDelegate, PlaceViewDelegate, TravelViewDelegate, HomeViewControllerDelegate>

@property (nonatomic) int dateCellHeight;

@end

static const int kStartY = 35;
static const int kOneHourSpace = 100;
static const int kLeftIndent = 75;
static const int kNumHoursInSchedule = 18;
static const int kScheduleStartTime = 8;

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
    UIFont *thinFont = [UIFont fontWithName:@"Gotham-XLight" size:14];
    [label setFont:thinFont];
    [label sizeToFit];
    return label;
}

static UIView *makeLine()
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}

static void createTravelView(float yCoord, float height, float width, Place *place, PlaceView *placeView, PlaceView *prevPlaceView)
{
    TravelView *travelView;
    if (placeView) {
        travelView = [[TravelView alloc] initWithFrame:CGRectMake(kLeftIndent + 10, yCoord, width - 10, height) startPlace:place.prevPlace endPlace:place];
        placeView.prevEvent = travelView;
    } else {
        travelView = [[TravelView alloc] initWithFrame:CGRectMake(kLeftIndent + 10, yCoord, width - 10, height) startPlace:prevPlaceView.place endPlace:place];
    }
    if (prevPlaceView) {
        prevPlaceView.nextEvent = travelView;
    }
}


static UIView *createBlankView(TimeBlock time, float startY, float endY, float width)
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kLeftIndent + 10, startY, width, endY - startY)];
    view.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
    UILabel *label = [[UILabel alloc] init];
    label.text = getStringFromTimeBlock(time);
    [label setFont: [UIFont fontWithName:@"Gotham-Light" size:15]];
    [label sizeToFit];
    label.frame = CGRectMake(CGRectGetWidth(view.frame) / 2 - CGRectGetWidth(label.frame) / 2, CGRectGetHeight(view.frame) / 2 - CGRectGetHeight(label.frame) / 2, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
    [view addSubview:label];
    return view;
}

static NSSet *checkAllPlacesVisited(NSArray *places)
{
    NSMutableSet *unvisitedTypes = [[NSMutableSet alloc] init];
    for (Place *place in places) {
        if (!place.hasAlreadyGone) {
            NSString *type = ([place.specificType isEqualToString:@"restaurant"]) ? @"restuarants" : @"attractions";
            [unvisitedTypes addObject:type];
        }
    }
    return (unvisitedTypes.count > 0) ? unvisitedTypes : nil;
}

@implementation ScheduleViewController

#pragma mark - ScheduleViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor darkGrayColor],
       NSFontAttributeName:[UIFont fontWithName:@"Gotham-Light" size:21]}];
    [self makeAddAllToCalendarButton];
    self.allEventsAdded = false;
    [self.tabBarController.tabBar setBackgroundColor:[UIColor whiteColor]];
    self.regenerateEntireSchedule = false;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self createCollectionView];
    self.collectionView.collectionViewLayout = [self makeCollectionViewLayout];
    self.view.backgroundColor = [UIColor whiteColor];
    self.header = makeThinHeaderLabel(getMonth(self.startDate), 35);
    [self.view addSubview:self.header];
    self.lockedDatePlaces = [[NSMutableDictionary alloc] init];
    [self scheduleViewSetup];
    [self createGoToMapButton];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.header.frame = CGRectMake(10, self.topLayoutGuide.length + 10, CGRectGetWidth(self.view.frame) - 10, 50);
    [self.header sizeToFit];
    self.header.frame = CGRectMake(10, self.topLayoutGuide.length + 10, CGRectGetWidth(self.header.frame), CGRectGetHeight(self.header.frame));
      self.buttonToGoToMap.frame = CGRectMake(self.view.frame.size.width - 50, self.topLayoutGuide.length + 10, 45, 40);
    self.collectionView.collectionViewLayout = [self makeCollectionViewLayout];
    self.collectionView.frame = CGRectMake(5, CGRectGetMaxY(self.header.frame) + 15, CGRectGetWidth(self.view.frame) - 10, self.dateCellHeight);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    int scrollViewYCoord = CGRectGetMaxY(self.collectionView.frame);
    self.scrollView.frame = CGRectMake(0, scrollViewYCoord, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 150 - self.bottomLayoutGuide.length);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), 1700);
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self makeDefaultViews];
    [self makePlaceSections];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.errorPlace) {
        [self handleErrorAlert:self.errorPlace forDate:self.errorDate forTime:self.errorTime];
    }
    self.errorPlace = nil;
}

- (void)scheduleViewSetup
{
    [self resetTravelToPlaces];
    [self makeScheduleDictionary];
    [self makeDatesArray];
    [self createScrollView];
    [self dateCell:nil didTap:removeTime(self.scheduleMaker.startDate)];
}

#pragma mark - Create Map Button

- (void) createGoToMapButton{
    UIColor *veryLightGray = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    self.buttonToGoToMap = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.buttonToGoToMap setFrame:CGRectZero];
    [self.buttonToGoToMap setImage:[UIImage imageNamed:@"formattedMap.png"] forState:UIControlStateNormal];
    self.buttonToGoToMap.backgroundColor = veryLightGray;
    self.buttonToGoToMap.layer.cornerRadius = 10;
    self.buttonToGoToMap.clipsToBounds = YES;
    self.buttonToGoToMap.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    self.buttonToGoToMap.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.buttonToGoToMap.layer.shadowRadius = 1.0;
    self.buttonToGoToMap.layer.shadowOpacity = 0.5;
    self.buttonToGoToMap.layer.masksToBounds = NO;
    [self.view addSubview:self.buttonToGoToMap];
    [self.buttonToGoToMap addTarget: self action: @selector(mapButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
}

- (void)mapButtonClicked: (id)sender
{
    if(self.dayPath.count > 0) {
        MapViewController *destView = [[MapViewController alloc] init];
        destView.placesFromSchedule = [[NSArray alloc]init];
        destView.placesFromSchedule = self.dayPath;
        destView.homeFromSchedule = self.home;
        [self.navigationController pushViewController:destView animated:true];
    }
}

#pragma mark - UICollectionView delegate & data source

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.collectionView registerClass:[DateCell class] forCellWithReuseIdentifier:@"DateCell"];
    DateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DateCell" forIndexPath:indexPath];
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSDate *date = self.allDates[indexPath.item];
    date = removeTime(date);
    NSDate *startDateRemovedTime = removeTime(self.startDate);
    NSDate *endDateRemovedTime = removeTime(self.endDate);
    [cell makeDate:date givenStart:getNextDate(startDateRemovedTime, -1) andEnd:getNextDate(endDateRemovedTime, 1)];
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
    NSDate *endSunday = getNextDate(self.endDate, 1);
    endSunday = getSunday(endSunday, 1);
    self.allDates = [[NSMutableArray alloc] init];
    self.dates = [[NSMutableArray alloc] init];
    while ([startSunday compare:endSunday] == NSOrderedAscending) {
        if (([startSunday compare:removeTime(self.endDate)] != NSOrderedDescending) && ([startSunday compare:removeTime(self.startDate)] != NSOrderedAscending)) {
            [self.dates addObject:startSunday];
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
    for (int i = 0; i < kNumHoursInSchedule; i++) {
        UILabel *timeLabel = makeTimeLabel(kScheduleStartTime + i);
        [timeLabel setFrame:CGRectMake(kLeftIndent - CGRectGetWidth(timeLabel.frame) - 5, kStartY + (i * kOneHourSpace), CGRectGetWidth(timeLabel.frame), CGRectGetHeight(timeLabel.frame))];
        [self.scrollView addSubview:timeLabel];
        UIView *line = makeLine();
        [line setFrame:CGRectMake(kLeftIndent, timeLabel.frame.origin.y + (CGRectGetHeight(timeLabel.frame) / 2), CGRectGetWidth(self.scrollView.frame) - kLeftIndent - 5, 0.5)];
        [self.scrollView addSubview:line];
    }
}

- (void)makePlaceSections {
    for (Place *place in self.dayPath) {
        if (place != self.home) {
            if (place.calendarEvent) {
                [place.calendarEvent updateEvent];
            }
            PlaceView *view = [self makePlaceView:place];
            view.delegate = self;
            [self.scrollView addSubview:view];
            if (view.prevEvent) {
                [self.scrollView addSubview:view.prevEvent];
                [self setViewDelegate:view.prevEvent];
            }
            if (view.nextEvent) {
                [self.scrollView addSubview:view.nextEvent];
                [self setViewDelegate:view.nextEvent];
            }
        } else if ([self.dayPath indexOfObject:place] == 5 && [self.dayPath objectAtIndex:4] != self.home) {
            Place *dinnerPlace = [self.dayPath objectAtIndex:TimeBlockDinner];
            getDistanceToHome(dinnerPlace, self.home);
            int height = (([dinnerPlace.travelTimeFromPlace floatValue] / 3600) + 10.0/60.0) * 100;
            int yDeparture = kStartY + (100 * (dinnerPlace.departureTime - kScheduleStartTime)) + CGRectGetHeight(makeTimeLabel(12).frame) / 2;
            createTravelView(yDeparture, height, CGRectGetWidth(self.scrollView.frame) - kLeftIndent - 15, self.home, nil, dinnerPlace.placeView);
            if (!dinnerPlace.commuteFrom.durationString) {
                dinnerPlace.placeView.nextEvent.alpha = 0;
            }
            [self.scrollView addSubview:dinnerPlace.placeView.nextEvent];
        }
    }
}

- (void)setViewDelegate:(ScheduleEventView *)view
{
    if ([view isKindOfClass:[PlaceView class]]) {
        PlaceView *temp = (PlaceView *)view;
        temp.delegate = self;
    } else {
        TravelView *temp = (TravelView *)view;
        temp.delegate = self;
    }
}

- (PlaceView *)makePlaceView:(Place *)place
{
    int width = CGRectGetWidth(self.scrollView.frame) - kLeftIndent - 5;
    int yShift = CGRectGetHeight(makeTimeLabel(12).frame) / 2;
    float startTime = place.arrivalTime;
    float endTime = place.departureTime;
    float height = 100 * (endTime - startTime);
    float yCoord = kStartY + (100 * (startTime - kScheduleStartTime)) + yShift;
    PlaceView *view = [[PlaceView alloc] initWithFrame:CGRectMake(kLeftIndent + 10, yCoord, width - 10, height) andPlace:place];
    place.placeView = view;
    if (place.prevPlace && (place.prevPlace != self.hub)) {
        int prevPlaceYCoord = kStartY + (100 * (place.prevPlace.departureTime - kScheduleStartTime));
        createTravelView(prevPlaceYCoord + yShift, yCoord - prevPlaceYCoord - yShift, width - 10, place, place.placeView, place.prevPlace.placeView);
        if (!place.commuteTo.durationString) {
            place.placeView.prevEvent.alpha = 0;
        }
    } else if (place.scheduledTimeBlock == TimeBlockBreakfast) {
        createTravelView(kStartY + (100 * (9 - kScheduleStartTime)) + yShift, yCoord - (kStartY + (100 * (9 - kScheduleStartTime))) - yShift, width - 10, place, place.placeView, nil);
        if (!place.commuteTo.durationString) {
            place.placeView.prevEvent.alpha = 0;
        }
    } else if (place.indirectPrev && (place.scheduledTimeBlock == getNextTimeBlock(getNextTimeBlock(place.indirectPrev.scheduledTimeBlock)))) {
        float height = (([place.travelTimeToPlace floatValue] / 3600) + 10.0/60.0) * 100;
        float yDeparture = kStartY + (100 * (place.arrivalTime - kScheduleStartTime)) + yShift;
        createTravelView(yDeparture - height, height, width - 10, place, place.placeView, place.prevPlace.placeView);
        if (!place.commuteTo.durationString) {
            place.placeView.prevEvent.alpha = 0;
        }
        if (place.indirectPrev != self.home) {
            float yPrevDeparture = kStartY + (100 * (place.indirectPrev.departureTime - kScheduleStartTime)) + yShift;
            PlaceView *blankView = [[PlaceView alloc] initWithFrame:CGRectMake(kLeftIndent + 10, yPrevDeparture, width - 10, yDeparture - height - yPrevDeparture) timeBlock:getNextTimeBlock(place.indirectPrev.scheduledTimeBlock)];
            blankView.prevEvent = place.indirectPrev.placeView;
            place.indirectPrev.placeView.nextEvent = blankView;
            blankView.nextEvent = view.prevEvent;
            view.prevEvent.prevEvent = blankView;
            [self.scrollView addSubview:blankView];
        }
    }
    if (place.scheduledTimeBlock == TimeBlockEvening) {
        int height = (([place.travelTimeFromPlace floatValue] / 3600) + 10.0/60.0) * 100;
        int yDeparture = kStartY + (100 * (place.departureTime - kScheduleStartTime)) + yShift;
        createTravelView(yDeparture, height, width - 10, self.home, nil, place.placeView);
        if (!place.commuteFrom.durationString) {
            place.placeView.nextEvent.alpha = 0;
        }
    }
    if (place.locked && place.calendarEvent) {
        [place.calendarEvent updateEvent];
    }
    return view;
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

- (void)removeLockFromPlace:(Place *)place
{
    NSString *removeDate = getDateAsString(place.date);
    NSString *removeTime = [NSString stringWithFormat: @"%ld", (long)place.scheduledTimeBlock];
    NSMutableDictionary *lockedPlacesForDate = [self.lockedDatePlaces objectForKey:removeDate];
    [lockedPlacesForDate removeObjectForKey:removeTime];
}
#pragma mark - TravelView delegate

- (void)travelView:(TravelView *)view didTap:(Commute *)commute
{
    if (self.currSelectedView) {
        [self unselectView];
        
    } else {
        CommuteDetailsViewController *commuteDetailsViewController = [[CommuteDetailsViewController alloc] init];
        commuteDetailsViewController.commute = commute;
        [self.navigationController pushViewController:commuteDetailsViewController animated:true];
    }
}

#pragma mark - View manipulation methods

- (void)unselectView
{
    if (self.currSelectedView) {
        [self.currSelectedView unselect];
        self.currSelectedView = nil;
    }
}

- (void)sendViewForward:(UIView *)view
{
    [self.scrollView bringSubviewToFront:view];
    [view setNeedsDisplay];
}

#pragma mark - Error alert for locked places

- (void)handleErrorAlert:(Place *)place forDate:(NSDate *)date forTime:(TimeBlock)time
{
    NSString *stringTimeBlock = getStringFromTimeBlock(self.errorTime);
    NSString *stringDate = getDateAsString(self.errorDate);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"message:[NSString stringWithFormat:@"Unable to add %@ to %@ of %@", place.name, stringTimeBlock, stringDate] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (void)handleUnscheduledError:(NSArray *)types
{
    NSString *unscheduledTypesString = (types.count == 1) ? [types objectAtIndex:0] : @"attractions and restaurants";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"message:[NSString stringWithFormat:@"Unable to generate schedule because too many %@ were selected.", unscheduledTypesString] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:false];
        animateTabBarSwitch(self.tabBarController, 1, 0);
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:^{}];
}

#pragma mark - ScheduleViewController schedule helper function

- (void) makeScheduleDictionary
{
    self.scheduleMaker = [[Schedule alloc] initWithArrayOfPlaces:self.selectedPlacesArray withStartDate:self.startDate withEndDate:self.endDate withHome:self.home];
    self.scheduleMaker.hub = self.hub;
    self.scheduleMaker.scheduleView = self;
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

- (void)makeAddAllToCalendarButton
{
    self.addAllToCalendarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add calendar" style:UIBarButtonItemStylePlain target:self action:@selector(allEventsCalendarAction)];
    [self.addAllToCalendarButton setTitleTextAttributes:@{
                                                          NSFontAttributeName: [UIFont fontWithName:@"Gotham-Light" size:14.0],
                                                          NSForegroundColorAttributeName: [UIColor blackColor]
                                                          } forState:UIControlStateNormal];
    [self.addAllToCalendarButton setTitleTextAttributes:@{
                                                          NSFontAttributeName: [UIFont fontWithName:@"Gotham-Light" size:14.0],
                                                          } forState:UIControlStateSelected];
    [self.navigationItem setRightBarButtonItem:self.addAllToCalendarButton animated:YES];
}

- (void)allEventsCalendarAction
{
    if (self.allEventsAdded) {
        [self removeAllEvents];
    } else {
        [self addAllEvents];
    }
}

- (void)removeAllEvents
{
    for (NSDate *date in self.dates) {
        NSArray *dayPath = [self.scheduleDictionary objectForKey:date];
        for (Place *place in dayPath) {
            if (place.calendarEvent) {
                [place.calendarEvent removeFromCalendar];
                place.calendarEvent = nil;
                [place.placeView.calendarButton setTitle:@"Add to calendar" forState:UIControlStateNormal];
            }
        }
    }
    self.addAllToCalendarButton.title = @"Add calendar";
    self.allEventsAdded = false;
}

- (void)addAllEvents
{
    for (NSDate *date in self.dates) {
        NSArray *dayPath = [self.scheduleDictionary objectForKey:date];
        for (Place *place in dayPath) {
            if (place == self.home) {
                continue;
            }
            if (!place.calendarEvent) {
                [[CalendarEvent alloc] initWithPlace:place requestStatus:NO];
            }
            [place.placeView.calendarButton setTitle:@"Remove" forState:UIControlStateNormal];
        }
    }
    self.addAllToCalendarButton.title = @"Remove calendar";
    self.allEventsAdded = true;
}

#pragma mark - Data refreshing helper functions

- (void)resetTravelToPlaces
{
    for (Place *place in self.selectedPlacesArray) {
        place.hasAlreadyGone = NO;
        place.prevPlace = nil;
        place.indirectPrev = nil;
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
