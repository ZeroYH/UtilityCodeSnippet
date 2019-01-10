//
//  NSMutableArray+WeakReferences.h
//  EShopComps
//
//  Created by StarLord on 2018/11/1.
//  Copyright © 2018 谢虎. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (WeakReferences)


+ (id)mutableArrayUsingWeakReferences;

+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity;

@end

NS_ASSUME_NONNULL_END
