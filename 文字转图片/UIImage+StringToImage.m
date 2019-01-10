//
//  UIImage+StringToImage.m
//  ToolsLibrary
//
//  Created by StarLord on 2018/10/18.
//  Copyright © 2018 Javor Feng. All rights reserved.
//

#import "UIImage+StringToImage.h"

@implementation UIImage (StringToImage)
#pragma mark - 字符串变成图片

+ (UIImage *)imageWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color {
    CGSize size = CGSizeMake([string getSizeWithFont:font constrainedWidth:0 numberOfLines:1].width, font.pointSize + 3);
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSForegroundColorAttributeName:color};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    UIGraphicsBeginImageContextWithOptions(size, 0, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetCharacterSpacing(ctx, 10);
    
    CGContextSetTextDrawingMode (ctx, kCGTextFill);
    
    CGContextSetRGBFillColor (ctx, 255, 255, 255, 1);
    
    [attributedString drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
