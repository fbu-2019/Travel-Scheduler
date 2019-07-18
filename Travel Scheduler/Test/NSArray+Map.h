//
//  Header.h
//  Travel Scheduler
//
//  Created by gilemos on 7/18/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Map)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;

@end

NS_ASSUME_NONNULL_END
