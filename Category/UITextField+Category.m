//
//  UITextField+Category.m
//  Spider-Man
//
//  Created by Spider-Man on 2018/3/21.
//  Copyright © 2018年 Spider-Man. All rights reserved.
//

#import "UITextField+Category.h"
#import <objc/runtime.h>
#import "Masonry.h"

@interface UITextField ()

@property (strong, nonatomic)UIView *bottomLine;

@end

static NSString *bottomLineKey = @"bottomLineKey";

@implementation UITextField (Category)

- (void)setBottomLine:(UIView *)bottomLine{
    objc_setAssociatedObject(self, &bottomLineKey, bottomLine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)bottomLine{
    UIView *view = objc_getAssociatedObject(self, &bottomLineKey);
    if (!view) {
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:view];
        objc_setAssociatedObject(self, &bottomLineKey, bottomLine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(view);
            make.height.equalTo(@1);
        }];
    }
    return  view;
}

- (void)bottomLineColor:(UIColor *)color{
    self.bottomLine.backgroundColor = color;
}

- (void)bottomLineSelectColor:(UIColor *)color{
    self.bottomLine.backgroundColor = color;
}

#pragm mark - 内容边距
- (void)textContainerInset:(UIEdgeInsets)edgeInsets {
    [self setValue:[NSNumber numberWithFloat:edgeInsets.left] forKey:@"paddingLeft"];
    [self setValue:[NSNumber numberWithFloat:edgeInsets.right]  forKey:@"paddingRight"];
    [self setValue:[NSNumber numberWithFloat:edgeInsets.top]  forKey:@"paddingTop"];
    [self setValue:[NSNumber numberWithFloat:edgeInsets.bottom]  forKey:@"paddingBottom"];
}

@end



