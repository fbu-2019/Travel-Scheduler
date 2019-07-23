//
//  SlideMenuUIView.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/23/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "SlideMenuUIView.h"
#import "SlideMenuTableViewCell.h"

@interface SlideMenuUIView()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation SlideMenuUIView

- (void)loadView
{
    menuArray =[NSArray arrayWithObjects:@"Profile",@"Friends",@"Status",@"Settings",@"Logout",nil];
    self.slideInTableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame), 0, 0 , 4000)];
    self.slideInTableView.backgroundColor = [UIColor whiteColor];
    [self.slideInTableView setAutoresizesSubviews:YES];
    [self.slideInTableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    self.slideInTableView.delegate = self;
    self.slideInTableView.dataSource = self;
    [self addSubview: self.slideInTableView];
    [self createButtonToCloseSlideInMenu];
   // [self addSubview:self.closeSlideInViewButton];
}

-(void) createButtonToCloseSlideInMenu{
    self.closeSlideInViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeSlideInViewButton.backgroundColor = [UIColor whiteColor];
    [self.closeSlideInViewButton setFrame:CGRectMake(CGRectGetWidth(self.frame)-50, 90, 20 , 20)];
    [self.closeSlideInViewButton setBackgroundImage:[UIImage imageNamed:@"close_icon"] forState: UIControlStateNormal];
    self.closeSlideInViewButton.layer.cornerRadius = 10;
    self.closeSlideInViewButton.clipsToBounds = YES;
    [self.closeSlideInViewButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
}

- (void) buttonClicked: (id)sender
{
    [self animateViewBackwards];
}

- (void) animateViewBackwards{
    [UIView animateWithDuration: 0.75 animations:^{
        self.frame = CGRectMake(CGRectGetWidth(self.frame), 0, 0 , 400);
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SlideMenuTableViewCell";
    SlideMenuTableViewCell *cell = (SlideMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SlideMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor=[UIColor clearColor];
        cell.textLabel.textColor=[UIColor blackColor];
        UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(30, 0, 270, 1)];
        lineView.backgroundColor=[UIColor whiteColor];
        [cell.contentView addSubview:lineView];
    }
    cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return menuArray.count;
}

@end

