//
//  DetailHeaderCell.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "DetailHeaderCell.h"
#import "Place.h"
#import "UIImageView+AFNetworking.h"

#pragma mark - UI creation helpers

static UILabel* makePlaceLabel(NSString *text, int width, CGRect imageFrame)
{
    int halfScreen = width / 2;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(halfScreen, imageFrame.origin.y, halfScreen, 60)];
    [label setFont: [UIFont fontWithName:@"Arial-BoldMT" size:25]];
    label.text = text;
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 2;
    [label sizeToFit];
    return label;
}

static UILabel* makeLocationLabel(NSString *text, CGRect labelFrame)
{
    int xCoord = labelFrame.origin.x;
    int yCoord = labelFrame.origin.y + CGRectGetHeight(labelFrame) + 10;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(xCoord, yCoord, CGRectGetWidth(labelFrame), 60)];
    label.text = text;
    [label setFont: [UIFont fontWithName:@"Arial" size:20]];
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

//static UILabel* makeDescriptionLabel(NSString *text, CGRect imageFrame, int width)
//{
//    int xCoord = imageFrame.origin.x;
//    int yCoord = imageFrame.origin.y + CGRectGetHeight(imageFrame) + 25;
//    int objectWidth = width - xCoord * 2;
//    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(xCoord, yCoord, objectWidth, 250)];
//    label.text = text;
//    [label setFont: [UIFont fontWithName:@"Arial" size:20]];
//    label.textColor = [UIColor blackColor];
//    [label setLineBreakMode:UILineBreakModeWordWrap];
//    label.numberOfLines = 0;
//    [label sizeToFit];
//    return label;
//}

static UIImageView* makeStarImageView(int starNumber, CGRect locationImageFrame, int width)
{
    int xCoordForFirstStar = locationImageFrame.origin.x;
    int yCoord = locationImageFrame.origin.y + CGRectGetHeight(locationImageFrame) + 15;
    int objectWidth = 30;
    UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xCoordForFirstStar + ((objectWidth + 3) * (starNumber - 1)), yCoord, objectWidth, objectWidth)];
    starImageView.contentMode = UIViewContentModeScaleAspectFill;
    starImageView.clipsToBounds = YES;
    starImageView.image = [UIImage imageNamed:@"star.png"];
    return starImageView;
}

static UIImageView* makeSquareImage(int width)
{
//    int leftEdge = 15;
//    int imageHeight = 175;
//    int imageWidth = width/2 - leftEdge * 2;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, (width * 3)/4)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    return imageView;
}

static UIButton* makeGoingButton(NSString *text, UIImageView *leftFrame, UILabel *topFrame, int width)
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    int xCoord = topFrame.frame.origin.x;
    int height = 30;
    int buttonReference = leftFrame.frame.origin.y + CGRectGetHeight(leftFrame.frame) - height;
    int topLabelReference = topFrame.frame.origin.y + CGRectGetHeight(topFrame.frame) + 15;
    int yCoord;
    yCoord = (buttonReference > topLabelReference) ? buttonReference : topLabelReference;
    button.frame = CGRectMake(xCoord, yCoord, width / 4, height);
    button.titleLabel.numberOfLines = 1;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByClipping;
    button.layer.cornerRadius = 10;
    button.clipsToBounds = YES;
    return button;
}

static void setButtonState(UIButton *button, Place *place)
{
    if (place.selected) {
        [button setTitle:@"Going" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor greenColor];
    } else {
        [button setTitle:@"Not going" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor lightGrayColor];
    }
}

@implementation DetailHeaderCell

#pragma mark - DetailHeaderCell lifecycle
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (instancetype)initWithWidth:(int)width andPlace:(Place *)givenPlace
{
    self = [super init];
    self.place = givenPlace;
    self.width = width;
    self.contentView.backgroundColor = [UIColor whiteColor];
    //self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.placeNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.goingButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.arrayOfStarImageViews = [[NSMutableArray alloc] init];
    [self customLayouts];
    return self;
}

- (void)customLayouts
{
    self.image = makeSquareImage(self.width);
    [self.image setImageWithURL:self.place.photoURL];
    [self.contentView addSubview:self.image];
    self.placeNameLabel = makePlaceLabel(self.place.name, self.width, self.image.frame);
    [self.contentView addSubview:self.placeNameLabel];
    self.locationLabel = makeLocationLabel(self.place.address, self.placeNameLabel.frame);
    [self.contentView addSubview:self.locationLabel];
    int rating = [self.place.rating intValue];
    for(int i = 1; i <= rating; ++i) {
        if(self.arrayOfStarImageViews == nil) {
            self.arrayOfStarImageViews = [[NSMutableArray alloc] init];
        }
        UIImageView *curImageView = makeStarImageView(i, self.image.frame, self.width);
        [self.arrayOfStarImageViews addObject:curImageView];
        [self.contentView addSubview:curImageView];
    }
    self.goingButton = makeGoingButton(@"Not going", self.image, self.locationLabel, self.width);
    setButtonState(self.goingButton, self.place);
    [self.goingButton addTarget:self action:@selector(selectPlace) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.goingButton];
    int height = self.image.frame.origin.y + CGRectGetHeight(self.image.frame) + 30 + 25;
    self.contentView.frame = CGRectMake(0, 0, self.width, height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)selectPlace
{
    [self.selectedPlaceProtocolDelegate updateSelectedPlacesArrayWithPlace:self.place];
    setButtonState(self.goingButton, self.place);
}

@end
