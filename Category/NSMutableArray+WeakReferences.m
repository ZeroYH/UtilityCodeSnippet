//
//  NSMutableArray+WeakReferences.m
//  EShopComps
//
//  Created by StarLord on 2018/11/1.
//  Copyright © 2018 谢虎. All rights reserved.
//

#import "NSMutableArray+WeakReferences.h"

@implementation NSMutableArray (WeakReferences)

+ (id)mutableArrayUsingWeakReferences {
    return [self mutableArrayUsingWeakReferencesWithCapacity:0];
}

+ (id)mutableArrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    // Cast of C pointer type 'CFMutableArrayRef' (aka 'struct __CFArray *') to Objective-C pointer type 'id' requires a bridged cast
    return (id)CFBridgingRelease(CFArrayCreateMutable(0, capacity, &callbacks));
    // return (id)(CFArrayCreateMutable(0, capacity, &callbacks));
}

@end
