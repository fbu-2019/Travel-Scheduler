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
#import "QuartzCore/CALayer.h"
#import "APIManager.h"
#include <stdlib.h>

#pragma mark - UI creation helpers

static UILabel* makePlaceLabel(NSString *text, int width, CGRect imageFrame)
{
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(10, imageFrame.size.height - 50, width, 45)];
    [label setFont: [UIFont fontWithName:@"Gotham-Bold" size:25]];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    label.layer.shadowRadius = 3.0;
    label.layer.shadowOpacity = 1;
    label.layer.masksToBounds = NO;
    label.numberOfLines = 1;
    [label sizeToFit];
    label.layer.shouldRasterize = YES;
    return label;
}

static UILabel* makeLocationLabel(NSString *text, NSArray *arrayOfTypeLabels, int width)
{
    UILabel *lastTypeLabel = [arrayOfTypeLabels lastObject];
    int topDistance = 50;
    int rightDistance = 25;
    int xCoord = 15;
    int yCoord = lastTypeLabel.frame.origin.y + lastTypeLabel.frame.size.height + topDistance;
    int Labelwidth = (width / 2) - rightDistance;
    NSString *fullText = [NSString stringWithFormat:@"Address: %@", text];
    
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(xCoord, yCoord, Labelwidth, 60)];
    label.text = fullText;
    [label setFont: [UIFont fontWithName:@"Gotham-light" size:15]];
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 0;
    return label;
}

static UILabel* makeTypeLabel(NSString *type, int width, CGRect previousLabelFrame, NSArray *arrayOfColors)
{
    int xCoord;
    int yCoord;
    int LabelHeight = 25;
    int labelWidth = 90;
    int verticalSpacingBetweenLabels = 15;
    int horizontalSpacingBetweenLabels = 10;
    //Is the first label
    if(previousLabelFrame.size.width > (width * 3) /4) {
        yCoord = previousLabelFrame.origin.y + CGRectGetHeight(previousLabelFrame) + verticalSpacingBetweenLabels;
        xCoord = width/2;
        //Is not the first label
    } else {
        int expectedXCoord = previousLabelFrame.origin.x + previousLabelFrame.size.width + horizontalSpacingBetweenLabels;
        //The previous label reached the end of the screen
        if((expectedXCoord + labelWidth) > (width - 10)) {
            //Go to the next line
            xCoord = width/2;
            yCoord = previousLabelFrame.origin.y + previousLabelFrame.size.height + verticalSpacingBetweenLabels;
            //The previous label did not reach the end of the screen
        } else {
            xCoord = previousLabelFrame.origin.x + previousLabelFrame.size.width + horizontalSpacingBetweenLabels;
            yCoord = previousLabelFrame.origin.y;
        }
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(xCoord, yCoord, labelWidth, LabelHeight)];
    label.text = type;
    [label setFont: [UIFont fontWithName:@"Gotham-Light" size:12]];
    label.numberOfLines = 1;
    int randomColorIndex = arc4random_uniform((int)arrayOfColors.count - 1);
    UIColor *randomColor = (UIColor *) arrayOfColors[randomColorIndex];
    label.backgroundColor = randomColor;
    label.textColor = [UIColor blackColor];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 5;
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    label.layer.shadowRadius = 3.0;
    label.layer.shadowOpacity = 1;
    label.layer.shouldRasterize = YES;
    return label;
}

static UIImageView* makeStarImageView(int starNumber, CGRect locationImageFrame, int width, int rating)
{
    NSString *imageName;
    if(starNumber <= rating) {
        imageName = @"yellowStar.png";
    } else {
        imageName = @"grayStar.png";
        
    }
    int xCoordForFirstStar = 10;
    int lateralBordersSize = 12;
    int spacingBetweenStars = 3;
    int yCoord = locationImageFrame.origin.y + locationImageFrame.size.height + lateralBordersSize;
    int maximumWidthForAllFiveStars = width/2 - (2 * lateralBordersSize) - (4 * spacingBetweenStars);
    int maximumWidthForOneStar = maximumWidthForAllFiveStars / 5 - 3;
    int wantedWidthForOneStar = 25;
    int starSize;
    
    if(maximumWidthForOneStar > wantedWidthForOneStar) {
        starSize = maximumWidthForOneStar;
    } else {
        starSize = wantedWidthForOneStar;
    }
    
    UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xCoordForFirstStar + ((starSize + spacingBetweenStars) * (starNumber - 1)), yCoord, starSize, starSize)];
    starImageView.contentMode = UIViewContentModeScaleAspectFill;
    starImageView.clipsToBounds = YES;
    starImageView.image = [UIImage imageNamed:imageName];
    return starImageView;
}

static UIImageView* makeSquareImage(int width)
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, (width * 3)/4)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    return imageView;
}

static UIImageView* makeMapImageView(int width, NSArray *arrayOfTypeLabels)
{
    UILabel *lastTypeLabel = [arrayOfTypeLabels lastObject];
    int verticalSpacingFromTypeLabel = 20;
    int rightBorderSize = 20;
    int yCoord = lastTypeLabel.frame.origin.y + lastTypeLabel.frame.size.height + verticalSpacingFromTypeLabel;
    int xCoord = width / 2;
    int sidesSize = width/2 - rightBorderSize;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(xCoord, yCoord, sidesSize, sidesSize)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(0, 1);
    imageView.layer.shadowOpacity = 1;
    imageView.layer.shadowRadius = 3.0;
    imageView.clipsToBounds = NO;
    
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor blackColor].CGColor;
    imageView.layer.borderWidth = 1;
    
    //  imageView.clipsToBounds = YES;
    return imageView;
}

static UIButton* makeGoingButton(NSString *text, UIImageView *leftFrame, UIButton *topFrame, int width)
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    int xCoord = topFrame.frame.origin.x;
    int height = 35;
    int buttonWidth = topFrame.frame.size.width;
    int yCoord = topFrame.frame.origin.y + CGRectGetHeight(topFrame.frame) + 10;
    button.frame = CGRectMake(xCoord, yCoord, buttonWidth, height);
    [button.titleLabel setFont:[UIFont fontWithName:@"Gotham-Light" size:14]];
    button.titleLabel.numberOfLines = 1;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByClipping;
    button.layer.cornerRadius = 3;
    button.clipsToBounds = YES;
    return button;
}

static UIButton* makeWebsiteButton(UILabel *topLabel, int width)
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    int topSpacing = 18;
    int lateralSpacing = topLabel.frame.origin.x;
    int xCoord = lateralSpacing;
    int yCoord = topLabel.frame.origin.y + topLabel.frame.size.height + topSpacing;
    int buttonWidth = width/2 - (2 * lateralSpacing);
    int buttonHeight = 35;
    UIColor *pinkColor = [UIColor colorWithRed:0.93 green:0.30 blue:0.40 alpha:1];
    button.frame = CGRectMake(xCoord, yCoord, buttonWidth, buttonHeight);
    [button.titleLabel setFont:[UIFont fontWithName:@"Gotham-Light" size:14]];
    [button setTitle:@"Go to website" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.borderColor = pinkColor.CGColor;
    button.layer.borderWidth = 2;
    button.titleLabel.numberOfLines = 1;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByClipping;
    button.layer.cornerRadius = 3;
    button.clipsToBounds = YES;
    return button;
}

static void setButtonState(UIButton *button, Place *place)
{
    if (place.selected) {
        [button setTitle:@"Remove from schedule" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor lightGrayColor];
    } else {
        [button setTitle:@"Add to schedule" forState:UIControlStateNormal];
        UIColor *pinkColor = [UIColor colorWithRed:0.93 green:0.30 blue:0.40 alpha:1];
        button.backgroundColor = pinkColor;
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
        [self makeArrayOfColors];
        self.place = givenPlace;
        self.width = width;
        self.contentView.backgroundColor = [UIColor whiteColor];
        //self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.placeNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.goingButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.arrayOfStarImageViews = [[NSMutableArray alloc] init];
        self.arrayOfTypeLabels = [[NSMutableArray alloc] init];
        [self customLayouts];
        return self;
    }
    
- (void)makeArrayOfTypeLabels
    {
        CGRect previousLabelFrame = self.image.frame;
        for(NSString *type in self.place.types) {
            if([type isEqualToString:@"point_of_interest"]) {
                continue;
            }
            UILabel *curLabel = makeTypeLabel(type, self.width, previousLabelFrame, self.colorArray);
            [self.arrayOfTypeLabels addObject:curLabel];
            previousLabelFrame = curLabel.frame;
            [self.contentView addSubview:curLabel];
        }
    }
    
- (void)makeArrayOfColors
    {
        self.colorArray = [NSArray alloc];
        self.colorArray = @[[UIColor colorWithRed:0.33 green:0.94 blue:0.77 alpha:1.0], [UIColor colorWithRed:0.51 green:0.93 blue:0.93 alpha:1.0], [UIColor colorWithRed:0.45 green:0.73 blue:1.00 alpha:1.0], [UIColor colorWithRed:0.64 green:0.61 blue:1.00 alpha:1.0], [UIColor colorWithRed:0.00 green:0.72 blue:0.58 alpha:1.0], [UIColor colorWithRed:0.00 green:0.81 blue:0.79 alpha:1.0], [UIColor colorWithRed:0.04 green:0.52 blue:0.89 alpha:1.0], [UIColor colorWithRed:0.42 green:0.36 blue:0.91 alpha:1.0], [UIColor colorWithRed:0.98 green:0.69 blue:0.63 alpha:1.0], [UIColor colorWithRed:1.00 green:0.46 blue:0.46 alpha:1.0], [UIColor colorWithRed:0.99 green:0.47 blue:0.66 alpha:1.0], [UIColor colorWithRed:0.99 green:0.80 blue:0.43 alpha:1.0], [UIColor colorWithRed:0.88 green:0.44 blue:0.33 alpha:1.0], [UIColor colorWithRed:0.84 green:0.19 blue:0.19 alpha:1.0], [UIColor colorWithRed:0.91 green:0.26 blue:0.58 alpha:1.0]];
    }
- (void)customLayouts
    {
        self.image = makeSquareImage(self.width);
        self.image.backgroundColor = [UIColor whiteColor];
        self.image.image = [UIImage imageNamed:@"output-onlinepngtools.png"];
        [self.image setImageWithURL:self.place.photoURL];
        [self.contentView addSubview:self.image];
        
        self.placeNameLabel = makePlaceLabel(self.place.name, self.width, self.image.frame);
        [self.image addSubview:self.placeNameLabel];
        
        int rating = [self.place.rating intValue];
        for(int i = 1; i <= 5; ++i) {
            if(self.arrayOfStarImageViews == nil) {
                self.arrayOfStarImageViews = [[NSMutableArray alloc] init];
            }
            UIImageView *curImageView = makeStarImageView(i, self.image.frame, self.width, rating);
            [self.arrayOfStarImageViews addObject:curImageView];
            [self.contentView addSubview:curImageView];
        }
        
        [self makeArrayOfTypeLabels];
        
        self.locationLabel = makeLocationLabel(self.place.address, self.arrayOfTypeLabels, self.width);
        [self.contentView addSubview:self.locationLabel];
        
        self.websiteButton = makeWebsiteButton(self.locationLabel, self.width);
        [self.websiteButton addTarget:self action:@selector(goToWebsite) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.websiteButton];
        
        
        self.mapImageView = makeMapImageView(self.width, self.arrayOfTypeLabels);
        self.mapImageView.image = [UIImage imageNamed:@"3405110-512"];
        [self.contentView addSubview:self.mapImageView];
        
        self.goingButton = makeGoingButton(@"Not going", self.image, self.websiteButton, self.width);
        setButtonState(self.goingButton, self.place);
        [self.goingButton addTarget:self action:@selector(selectPlace) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.goingButton];
        
        int height = self.mapImageView.frame.origin.y + self.mapImageView.frame.size.height + 40;
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
    
- (void)goToWebsite {
    [self.websiteButton setTitle:@"Loading ..." forState:UIControlStateNormal];
    if(self.place.website == nil) {
        [[APIManager shared]getWebsiteLinkOfPlaceWithId:self.place.placeId withCompletion:^(NSString *placeWebsiteString, NSError *error) {
            if(placeWebsiteString) {
                self.place.website = placeWebsiteString;
                [self.goToWebsiteProtocolDelegate goToWebsiteWithLink:placeWebsiteString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.websiteButton setTitle:@"Go to website" forState:UIControlStateNormal];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.websiteButton setTitle:@"Website not available" forState:UIControlStateNormal];
                });
            }
        }];
    } else {
        [self.goToWebsiteProtocolDelegate goToWebsiteWithLink:self.place.website];
    }
}
    
    @end
