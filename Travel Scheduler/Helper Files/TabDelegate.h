//
//  TabDelegate.h
//  Travel Scheduler
//
//  Created by gilemos on 7/29/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UITabDelegate ((TabDelegate *)[UIApplication sharedApplication].delegate)

@interface TabDelegate : UIResponder <UIApplicationDelegate>
    
@property (nonatomic, strong) NSMutableArray *arrayOfSelectedPlaces;
    
@end
