//
//  ScheduleViewController.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "ScheduleViewController.h"
#import "TravelSchedulerHelper.h"

@interface ScheduleViewController ()

@property (strong, nonatomic) UILabel *header;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.header = makeHeaderLabel(@"Schedule");
    [self.view addSubview:self.header];
}

@end
