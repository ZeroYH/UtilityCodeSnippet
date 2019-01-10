//
//  UIImage+StringToImage.h
//  ToolsLibrary
//
//  Created by StarLord on 2018/10/18.
//  Copyright © 2018 Javor Feng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (StringToImage)
/// 字符串变成图片
+ (UIImage *)imageWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
