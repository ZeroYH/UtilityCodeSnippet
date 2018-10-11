//
//  UIImage+ImageOperation.m
//  UIImageTensileTest
//
//  Created by YRH on 2018/4/9.
//  Copyright © 2018年 YRH. All rights reserved.
//

#import "UIImage+ImageOperation.h"
#import "DeviceUtil.h"

#define ImageResolution_1x CGSizeMake(320, 480)
#define ImageResolution_2x CGSizeMake(750, 1334)
#define ImageResolution_3x CGSizeMake(1080, 1920)

#define ImageSandboxPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@implementation UIImage (ImageOperation)

#pragma mark - 从沙盒中获取拉伸图片
+ (UIImage *)sendboxImageStretchWithImageName:(NSString *)imageName suffix:(NSString *)suffix isFlipMirror:(BOOL)isFlipMirror {
    UIImage *image = [self sandboxImageWithImageName:imageName suffix:suffix isFlipMirror:isFlipMirror];
    UIImage *stretchImage = [self chatBubbleimageStretchWithImage:image];
    return stretchImage;
}

#pragma mark - 聊天气泡 拉伸图片
+ (UIImage *)chatBubbleimageStretchWithImage:(UIImage *)image {
    return [UIImage imageStretchWithImage:image insets:UIEdgeInsetsMake(27, 27, 27, 27)];
}

#pragma mark - 拉伸图片
+ (UIImage *)imageStretchWithImage:(UIImage *)image insets:(UIEdgeInsets)insets {
    // 指定为拉伸模式，伸缩后重新赋值
    image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    return image;
}

#pragma mark - 从沙盒中获取图片，并镜像翻转
+ (UIImage *)sandboxImageWithImageName:(NSString *)imageName suffix:(NSString *)suffix isFlipMirror:(BOOL)isFlipMirror {
    UIImage *localImage = [UIImage sandboxImageWithImageName:imageName suffix:suffix];
    if (isFlipMirror) {
        localImage = [UIImage flipMirrorImageWithOriginalImage:localImage];
    }
    return localImage;
}

#pragma mark - 从沙盒中取图片
+ (UIImage *)sandboxImageWithImageName:(NSString *)imageName suffix:(NSString *)suffix {
    NSString *newImageName = @"";
    if (suffix && ![suffix isEqualToString:@""]) {
        newImageName = [[self adapterDeviceResolutionImageName:imageName] stringByAppendingString:[NSString stringWithFormat:@".%@", suffix]];
    } else if ([imageName componentsSeparatedByString:@"."].count > 1) {
        newImageName = [self adapterDeviceResolutionImageName:imageName];
    } else {
        newImageName = [[self adapterDeviceResolutionImageName:imageName] stringByAppendingString:@".png"];
    }
    NSString *imageSandboxLocalPath = [ImageSandboxPath stringByAppendingString:[NSString stringWithFormat:@"/%@", newImageName]];
    UIImage *image = [UIImage imageWithContentsOfFile:imageSandboxLocalPath];
//    NSData *data = [NSData dataWithContentsOfFile:imageSandboxLocalPath];
    return image;
}

#pragma mark - 根据分辨率得到图片名字
+ (NSString *)adapterDeviceResolutionImageName:(NSString *)imageName {
    // 检测是否有后缀名
    NSArray *imageStringArray = [imageName componentsSeparatedByString:@"."];
    NSString *oldImageFirstName = [imageStringArray firstObject];
    NSString *newImageFirstName = [oldImageFirstName stringByAppendingString:[self imageNameWithDeviceResolution:[DeviceUtil deviceResolution]]];
    if (imageStringArray.count == 2) {
        newImageFirstName = [newImageFirstName stringByAppendingString:[imageStringArray lastObject]];
    }
    return newImageFirstName;
}

#pragma mark - 根据分辨率赋值1x、2x、3x
+ (NSString *)imageNameWithDeviceResolution:(CGSize)scaleSize {
    NSString *imageSuffix = @"";
    if (scaleSize.width == ImageResolution_1x.width) {
        // 一倍图
        imageSuffix = @"";
    } else if (scaleSize.width > ImageResolution_1x.width && scaleSize.width <= ImageResolution_2x.width) {
        // 二倍图
        imageSuffix = @"@2x";
    } else if (scaleSize.width >= ImageResolution_3x.width) {
        // 三倍图
        imageSuffix = @"@3x";
    }
    return imageSuffix;
}

#pragma mark - 水平翻转（左右镜像）
+ (UIImage *)flipMirrorImageWithOriginalImage:(UIImage *)originalImage {
    UIImage *newImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:((originalImage.imageOrientation + 4) % 8)];
    return newImage;
}

@end
