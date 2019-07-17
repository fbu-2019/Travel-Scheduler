//
//  DetailsViewController.m
//  Travel Scheduler
//
//  Created by gilemos on 7/16/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "DetailsViewController.h"
#import "DetailHeaderCell.h"

@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end
/*
static UILabel* makeHeaderLabel(NSString *text, CGRect frameSize, CGRect imageFrame) {
    int halfScreen = CGRectGetWidth(frameSize) / 2;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(halfScreen, imageFrame.origin.y, halfScreen, 50)];
    [label setFont: [UIFont fontWithName:@"Arial-BoldMT" size:50]];
    label.text = text;
    label.textColor = [UIColor blackColor];
    
    //setUpDefaultLabel(label);
    label.numberOfLines = 0;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.minimumScaleFactor = 10.0f/12.0f;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

static UILabel* makeLocationLabel(NSString *text, CGRect labelFrame) {
    int xCoord = labelFrame.origin.x;
    int yCoord = labelFrame.origin.y + CGRectGetHeight(labelFrame);
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(xCoord, yCoord, CGRectGetWidth(labelFrame), 50)];
    label.text = text;
    [label setFont: [UIFont fontWithName:@"Arial" size:30]];
    label.textColor = [UIColor grayColor];
    
    //setUpDefaultLabel(label);
    label.numberOfLines = 0;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.minimumScaleFactor = 10.0f/12.0f;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

static UILabel* makeDescriptionLabel(NSString *text, CGRect imageFrame, CGRect screenFrame) {
    int xCoord = imageFrame.origin.x;
    int yCoord = imageFrame.origin.y + CGRectGetHeight(imageFrame);
    int width = CGRectGetWidth(screenFrame) - xCoord * 2;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(xCoord, yCoord, width, 500)];
    label.text = text;
    [label setFont: [UIFont fontWithName:@"Arial" size:30]];
    label.textColor = [UIColor blackColor];
    [label setLineBreakMode:UILineBreakModeWordWrap];

    //setUpDefaultLabel(label);
    label.numberOfLines = 0;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.minimumScaleFactor = 10.0f/12.0f;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}
 
 static UIImageView* makeImage(CGRect screenFrame) {
 int leftEdge = 15;
 int imageHeight = 175;
 int imageWidth = CGRectGetWidth(screenFrame)/2 - leftEdge * 2;
 UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftEdge, 100, imageWidth, imageHeight)];
 imageView.contentMode = UIViewContentModeScaleAspectFill;
 imageView.clipsToBounds = YES;
 imageView.image = [UIImage imageNamed:@"heart3"];
 return imageView;
 }
 */
 
 
 
 
/*
static void setUpDefaultLabel(UILabel *label) {
    label.numberOfLines = 0;
    label.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    label.minimumScaleFactor = 10.0f/12.0f;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
}
*/

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    /*CGRect screenFrame = self.view.frame;
    UIImageView *image = makeImage(screenFrame);
    [self.view addSubview:image];
    UILabel *placeNameLabel = makeHeaderLabel(@"PLACE", screenFrame, image.frame);
    [self.view addSubview:placeNameLabel];
    UILabel *locationLabel = makeLocationLabel(@"location", placeNameLabel.frame);
    [self.view addSubview:locationLabel];
    UILabel *descriptionLabel = makeDescriptionLabel(@"Description a;slkdjf;ak alsdkjf asfj;kla flkasf sfj as;fkj a;sf jaslfj asl;fj as;kfj askf asjf asj f;alskjf asjkf ;asf ;askj f;askjf asfkj aslkfj a;sfk asfj s ", image.frame, screenFrame);
    [self.view addSubview:descriptionLabel];*/
    // Do any additional setup after loading the view.
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //[self.tableView registerClass:[DetailHeaderCell class] forCellWithReuseIdentifier:@"DetailHeaderCell"];
    //UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DetailHeaderCell"];
    
    DetailHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailHeaderCell"];
    if (!cell) {
        cell = [[DetailHeaderCell alloc] init];
    }
    cell.contentView.frame = CGRectMake(10.0f, 0, CGRectGetWidth(self.tableView.frame), cell.frame.size.height);
    [cell makeCell];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 500;
    }
    return 50;
}

@end
