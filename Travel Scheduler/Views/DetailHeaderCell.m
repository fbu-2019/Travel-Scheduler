//
//  DetailHeaderCell.m
//  Travel Scheduler
//
//  Created by aliu18 on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "DetailHeaderCell.h"

static UILabel* makeHeaderLabel(NSString *text, int width, CGRect imageFrame) {
    int halfScreen = width / 2;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(halfScreen, imageFrame.origin.y, halfScreen, 50)];
    [label setFont: [UIFont fontWithName:@"Arial-BoldMT" size:50]];
    label.text = text;
    label.textColor = [UIColor blackColor];
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

static UILabel* makeLocationLabel(NSString *text, CGRect labelFrame) {
    int xCoord = labelFrame.origin.x;
    int yCoord = labelFrame.origin.y + CGRectGetHeight(labelFrame) + 10;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(xCoord, yCoord, CGRectGetWidth(labelFrame), 50)];
    label.text = text;
    [label setFont: [UIFont fontWithName:@"Arial" size:30]];
    label.textColor = [UIColor grayColor];
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

static UILabel* makeDescriptionLabel(NSString *text, CGRect imageFrame, int width) {
    int xCoord = imageFrame.origin.x;
    int yCoord = imageFrame.origin.y + CGRectGetHeight(imageFrame) + 25;
    int objectWidth = width - xCoord * 2;
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectMake(xCoord, yCoord, objectWidth, 250)];
    label.text = text;
    [label setFont: [UIFont fontWithName:@"Arial" size:30]];
    label.textColor = [UIColor blackColor];
    [label setLineBreakMode:UILineBreakModeWordWrap];
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

static UIImageView* makeImage(int width) {
    int leftEdge = 15;
    int imageHeight = 175;
    int imageWidth = width/2 - leftEdge * 2;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftEdge, 50, imageWidth, imageHeight)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = [UIImage imageNamed:@"heart3"];
    return imageView;
}

@implementation DetailHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithWidth:(int)width {
    self = [super init];
    self.width = width;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.placeNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.image = makeImage(self.width);
    [self.contentView addSubview:self.image];
    self.placeNameLabel = makeHeaderLabel(@"PLACE", self.width, self.image.frame);
    [self.contentView addSubview:self.placeNameLabel];
    self.locationLabel = makeLocationLabel(@"location", self.placeNameLabel.frame);
    [self.contentView addSubview:self.locationLabel];
    self.descriptionLabel = makeDescriptionLabel(@"Description a;slkdjf;ak alsdkjf asfj;kla flkasf sfj as;fkj a;sf jaslfj asl;fj as;kfj askf asjf asj f;alskjf asjkf ;asf ;askj f;askjf asfkj aslkfj a;sfk asfj s Description a;slkdjf;ak alsdkjf asfj;kla flkasf sfj as;fkj a;sf jaslfj asl;fj as;kfj askf asjf asj f;alskjf asjkf ;asf ;askj f;askjf asfkj aslkfj a;sfk asfj s Description a;slkdjf;ak alsdkjf asfj;kla flkasf sfj as;fkj a;sf jaslfj asl;fj as;kfj askf asjf asj f;alskjf asjkf ;asf ;askj f;askjf asfkj aslkfj a;sfk asfj s", self.image.frame, self.width);
    [self.contentView addSubview:self.descriptionLabel];
    int height = self.descriptionLabel.frame.origin.y + CGRectGetHeight(self.descriptionLabel.frame) + 25;
    self.contentView.frame = CGRectMake(0, 0, self.width, height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
