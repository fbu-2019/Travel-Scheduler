//
//  SlideMenuUIView.m
//  Travel Scheduler
//
//  Created by frankboamps on 7/22/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "SlideMenuUIView.h"
#import "SlideMenuTableViewCell.h"
@import FirebaseUI;

@interface SlideMenuUIView()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation SlideMenuUIView

#pragma mark - Setting view implementation

- (void)loadView
{
    menuArray =[NSArray arrayWithObjects:@"Profile",@"Friends",@"Past Trips",@"Settings",@"Logout",nil];
    self.slideInTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.closeSlideInTableViewButton.frame), 300, menuArray.count * 40)];
    self.slideInTableView.backgroundColor = [UIColor whiteColor];
    [self.slideInTableView setAutoresizesSubviews:YES];
    [self.slideInTableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    self.slideInTableView.delegate = self;
    self.slideInTableView.dataSource = self;
    [self addSubview: self.slideInTableView];
    [self addSubview: self.closeSlideInTableViewButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.closeSlideInTableViewButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 50, 5, 33 , 33);
    self.slideInTableView.frame = CGRectMake(0, CGRectGetMaxY(self.closeSlideInTableViewButton.frame), 300, menuArray.count * 40);
}

#pragma mark - Button for slide in view

- (void)createButtonToCloseSlideIn
{
    self.closeSlideInTableViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeSlideInTableViewButton.backgroundColor = [UIColor whiteColor];
    [self.closeSlideInTableViewButton setFrame:CGRectZero];
    [self.closeSlideInTableViewButton setBackgroundImage:[UIImage imageNamed:@"close_icon"] forState: UIControlStateNormal];
    self.closeSlideInTableViewButton.layer.cornerRadius = 10;
    self.closeSlideInTableViewButton.clipsToBounds = YES;
    [self.closeSlideInTableViewButton addTarget: self action: @selector(buttonClicked:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview: self.closeSlideInTableViewButton];
    [self layoutIfNeeded];
}

- (void)buttonClicked:(id)sender
{
    [self.delegate animateViewBackwards:self];
}

#pragma mark - TableView DataSource methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SlideMenuTableViewCell";
    SlideMenuTableViewCell *cell = (SlideMenuTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SlideMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor=[UIColor clearColor];
        cell.textLabel.textColor=[UIColor grayColor];
        cell.textLabel.font = [UIFont fontWithName:@"Gotham-Light" size:20];
    }
    cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4){
        FIRAuth *auth = [FIRAuth auth];
        NSError *signOutError;
        BOOL status = [auth signOut:&signOutError];
        if (!status) {
            return;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

@end
