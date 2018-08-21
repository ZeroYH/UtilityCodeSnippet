//
//  UITextField+Category.h
//  Spider-Man
//
//  Created by Spider-Man on 2018/3/21.
//  Copyright © 2018年 Spider-Man. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Category)

- (void)bottomLineColor:(UIColor *)color;
- (void)bottomLineSelectColor:(UIColor *)color;
/// 内容边距
- (void)textContainerInset:(UIEdgeInsets)edgeInsets;

@end



