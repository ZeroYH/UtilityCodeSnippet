//
//  MessageForwardProxy.m
//  Sideslip
//
//  Created by YRH on 2018/9/29.
//  Copyright © 2018 SpiderMan. All rights reserved.
//

#import "MessageForwardProxy.h"

@interface MessageForwardProxy ()

@property (nonatomic, weak) id target;

@end

@implementation MessageForwardProxy

- (instancetype)initWithObject:(id)object {
    self.target = object;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}


@end
