//
//  RespondSEL.m
//  ChatComps
//
//  Created by Spider-Man on 2018/10/9.
//  Copyright © 2018 Javor Feng. All rights reserved.
//

#import "RespondSEL.h"

@implementation RespondSEL

+ (void)respondNonParameterSEL:(SEL)sender {
    // 无参
    if (sender && [self respondsToSelector:sender]) {
//        NSString *selectString = NSStringFromSelector(sender);
        SEL selector = sender;
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL) = (void *)imp;
        func(self, selector);
    }
}

+ (void)respondParameterSEL:(SEL)sender parameter:(id)parameter {
    // 有参
    if (sender && [self respondsToSelector:sender]) {
        SEL selector = sender;
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self, selector, parameter);
    }
}

@end
