//
//  SyntheticImagesObj.m
//  SyntheticImages
//
//  Created by YRH on 16/9/5.
//  Copyright © 2016年 YRH. All rights reserved.
//  多张图片合成一张图片，(群头像)

#import "SyntheticImages.h"

@implementation SyntheticImages

// 图片
- (void)syntheticImagesWithImageArray:(NSMutableArray *)imageArray andNewImageWidth:(CGFloat)width height:(CGFloat)height withImg:(void (^) (UIImage *image))image {
    NSInteger count = imageArray.count;
    // 最多9张图合一张
    if (count > 9) {
        count = 9;
    }
    // 设置画布大小，即合成的图片的大小
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 2);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        UIColor *backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        CGContextSetFillColorWithColor(contextRef, backgroundColor.CGColor);
        CGContextAddRect(contextRef, CGRectMake(0, 0, width, height));
        CGContextDrawPath(contextRef, kCGPathFill);
        UIImage *subImg;
        CGSize subImgSize = [self getSubImgSizeWithImageArray:imageArray size:CGSizeMake(width, height) seperateWidth:2];
        NSArray *pointArr = [self getCGPointWithImageArray:imageArray withSize:CGSizeMake(width, height) subImgSize:subImgSize seperateWidth:2];
        for (NSInteger i = 0;i < imageArray.count; i ++) {
            subImg = [imageArray objectAtIndex:i];
            CGRect rect = CGRectZero;
            rect.origin = [[pointArr objectAtIndex:i] CGPointValue];
            rect.size = subImgSize;
            [subImg drawInRect:rect];
        }
        
        // 从当前上下文中获得最终图片
        UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            image(resultImg);
        });
    });
}

- (CGSize)getSubImgSizeWithImageArray:(NSArray *)imgArr size:(CGSize)size seperateWidth:(CGFloat)seperateWidth {
    CGSize subImgSize;
    if (imgArr.count <= 4) {
        subImgSize = [self getSubImgSizeUsingSudoku4WithSize:size seperateWidth:seperateWidth];
    } else {
        subImgSize = [self getSubImgSizeUsingSudoku9WithSize:size seperateWidth:seperateWidth];
    }
    return subImgSize;
}

//获取四宫格子图片大小
- (CGSize)getSubImgSizeUsingSudoku4WithSize:(CGSize)size seperateWidth:(CGFloat)seperateWidth {
    CGSize s4 = CGSizeMake((size.width - (seperateWidth*3))/2, (size.height - (seperateWidth*3))/2);
    return s4;
}

//获取九宫格子图片的大小
- (CGSize)getSubImgSizeUsingSudoku9WithSize:(CGSize)size seperateWidth:(CGFloat)seperateWidth {
    CGSize s9 = CGSizeMake((size.width - (seperateWidth*4))/3, (size.height - seperateWidth*4)/3);
    return s9;
}

- (NSArray *)getCGPointWithImageArray:(NSArray *)imageArray withSize:(CGSize)size subImgSize:(CGSize)subImgSize seperateWidth:(CGFloat)seperateWidth {
    NSArray *arr;
    if (imageArray.count == 1) {
        arr = [self getCGPointArrayWithOneSudoWithSize:size subImgSize:subImgSize seperateWidth:seperateWidth];
    } else if(imageArray.count == 2) {
        arr = [self getCGPointArrayWithTwoSudoWithSize:size subImgSize:subImgSize seperateWidth:seperateWidth];
    } else if(imageArray.count == 3) {
        arr = [self getCGPointArrayWithThreeSudoWithSize:size subImgSize:subImgSize seperateWidth:seperateWidth];
    } else if(imageArray.count == 4) {
        arr = [self getCGPointArrayWithFourSudoWithSize:size subImgSize:subImgSize seperateWidth:seperateWidth];
    } else if(imageArray.count == 5) {
        arr = [self getCGPointArrayWithFiveSudoWithSize:size subImgSize:subImgSize seperateWidth:seperateWidth];
    } else if(imageArray.count == 6 || imageArray.count >= 9) {
        NSInteger imageCount = imageArray.count;
        if(imageCount > 9) {
            imageCount = 9;
        }
        arr = [self getCGPointArrayWithNineSudoWithSize:size subImgSize:subImgSize imageCount:imageCount seperateWidth:seperateWidth];
    } else if (imageArray.count == 7) {
        arr = [self getCGPointArrayWithSevenSudoWithSize:size subImgSize:subImgSize seperateWidth:seperateWidth];
    } else if (imageArray.count == 8) {
        arr = [self getCGPointArrayWithEightSudoWithSize:size subImgSize:subImgSize seperateWidth:seperateWidth];
    }
    return arr;
}

//1图片的布局
- (NSArray *)getCGPointArrayWithOneSudoWithSize:(CGSize)size subImgSize:(CGSize)subImgSize seperateWidth:(CGFloat)seperateWidth {
    CGPoint point1 = CGPointMake((size.width-subImgSize.width)/2, (size.height-subImgSize.height)/2);
    return @[[NSValue valueWithCGPoint:point1]];
}

//2张图片的布局
- (NSArray *)getCGPointArrayWithTwoSudoWithSize:(CGSize)size subImgSize:(CGSize)subImgSize seperateWidth:(CGFloat)seperateWidth {
    CGPoint point1 = CGPointMake(seperateWidth, (size.height-subImgSize.height)/2);
    CGPoint point2 = CGPointMake(subImgSize.width + seperateWidth*2, (size.height-subImgSize.height)/2);
    
    return @[[NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2]];
}

//3图布局
- (NSArray *)getCGPointArrayWithThreeSudoWithSize:(CGSize)size subImgSize:(CGSize)subImgSize seperateWidth:(CGFloat)seperateWidth {
    CGPoint point1 = CGPointMake((size.width-subImgSize.width)/2, seperateWidth);
    CGPoint point2 = CGPointMake(seperateWidth, subImgSize.height + seperateWidth*2);
    CGPoint point3 = CGPointMake(subImgSize.width + seperateWidth*2, subImgSize.height + seperateWidth*2);
    
    return @[[NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3]];
}

//4图布局
- (NSArray *)getCGPointArrayWithFourSudoWithSize:(CGSize)size subImgSize:(CGSize)subImgSize seperateWidth:(CGFloat)seperateWidth {
    CGPoint point1 = CGPointMake(seperateWidth, seperateWidth);
    CGPoint point2 = CGPointMake(subImgSize.width + seperateWidth*2, seperateWidth);
    CGPoint point3 = CGPointMake(seperateWidth, subImgSize.height + seperateWidth*2);
    CGPoint point4 = CGPointMake(subImgSize.width +seperateWidth*2, subImgSize.height + seperateWidth*2);
    
    return @[[NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4]];
}

//5图布局
- (NSArray *)getCGPointArrayWithFiveSudoWithSize:(CGSize)size subImgSize:(CGSize)subImgSize seperateWidth:(CGFloat)seperateWidth {
    CGPoint point1 = CGPointMake((size.width - subImgSize.width*2)/2, (size.height - subImgSize.height*2)/2);
    CGPoint point2 = CGPointMake((size.width - subImgSize.width*2)/2 + subImgSize.width + seperateWidth, (size.height - subImgSize.height*2)/2);
    CGPoint point3 = CGPointMake(seperateWidth, point1.y + subImgSize.height + seperateWidth);
    CGPoint point4 = CGPointMake(subImgSize.height + seperateWidth*2, point1.y + subImgSize.height + seperateWidth);
    CGPoint point5 = CGPointMake(subImgSize.height*2 + (seperateWidth * 3), point1.y + subImgSize.height + seperateWidth);
    
    return @[[NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], [NSValue valueWithCGPoint:point5]];
}

//7图布局
- (NSArray *)getCGPointArrayWithSevenSudoWithSize:(CGSize)size subImgSize:(CGSize)subImgSize seperateWidth:(CGFloat)seperateWidth {
    CGPoint point1 = CGPointMake((size.width-subImgSize.width)/2, seperateWidth);
    CGPoint point2 = CGPointMake(seperateWidth, point1.y + subImgSize.height + seperateWidth);
    CGPoint point3 = CGPointMake(subImgSize.height + seperateWidth*2, point1.y + subImgSize.height + seperateWidth);
    CGPoint point4 = CGPointMake(subImgSize.height*2 + (seperateWidth * 3), point1.y + subImgSize.height + seperateWidth);
    
    CGPoint point5 = CGPointMake(seperateWidth, point2.y + subImgSize.height + seperateWidth);
    CGPoint point6 = CGPointMake(subImgSize.height + seperateWidth*2, point2.y + subImgSize.height + seperateWidth);
    CGPoint point7 = CGPointMake(subImgSize.height*2 + (seperateWidth * 3), point2.y + subImgSize.height + seperateWidth);
    return @[[NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], [NSValue valueWithCGPoint:point5], [NSValue valueWithCGPoint:point6], [NSValue valueWithCGPoint:point7]];
}

//8图布局
- (NSArray *)getCGPointArrayWithEightSudoWithSize:(CGSize)size subImgSize:(CGSize)subImgSize seperateWidth:(CGFloat)seperateWidth {
    CGPoint point1 = CGPointMake((size.width - subImgSize.width*2)/2, seperateWidth);
    CGPoint point2 = CGPointMake((size.width - subImgSize.width*2)/2 + subImgSize.width + seperateWidth, seperateWidth);
    CGPoint point3 = CGPointMake(seperateWidth, point1.y + subImgSize.height + seperateWidth);
    CGPoint point4 = CGPointMake(subImgSize.height + seperateWidth*2, point1.y + subImgSize.height + seperateWidth);
    CGPoint point5 = CGPointMake(subImgSize.height*2 + (seperateWidth * 3), point1.y + subImgSize.height + seperateWidth);
    CGPoint point6 = CGPointMake(seperateWidth, point3.y + subImgSize.height + seperateWidth);
    CGPoint point7 = CGPointMake(subImgSize.height + seperateWidth*2, point3.y + subImgSize.height + seperateWidth);
    CGPoint point8 = CGPointMake(subImgSize.height*2 + (seperateWidth * 3), point3.y + subImgSize.height + seperateWidth);
    
    return @[[NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], [NSValue valueWithCGPoint:point3], [NSValue valueWithCGPoint:point4], [NSValue valueWithCGPoint:point5], [NSValue valueWithCGPoint:point6], [NSValue valueWithCGPoint:point7], [NSValue valueWithCGPoint:point8]];
}

//6或9宫格布局
- (NSArray *)getCGPointArrayWithNineSudoWithSize:(CGSize)size subImgSize:(CGSize)subImgSize imageCount:(NSInteger)imageCount seperateWidth:(CGFloat)seperateWidth {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSInteger count = imageCount;
    NSInteger columnPerRow = 3;
    NSInteger rowPerColumn = 3;
    
    NSInteger columnIndex = 0;
    NSInteger rowIndex = 0;
    NSInteger allRowCount = 0;
    for (NSInteger i = 0; i < count; i ++) {
        
        columnIndex = i % columnPerRow;
        rowIndex = i / columnPerRow;
        
        if (count % columnPerRow == 0) {
            allRowCount = count / columnPerRow;
        } else {
            allRowCount = count / columnPerRow + 1;
        }
        
        CGPoint point = CGPointMake(columnIndex * subImgSize.width + (seperateWidth*(columnIndex + 1)), ((rowPerColumn - allRowCount)*subImgSize.height)/2 + (rowIndex * subImgSize.height) + (seperateWidth *(rowIndex+1)));
        
        [arr addObject:[NSValue valueWithCGPoint:point]];
    }
    
    return arr;
}

// 图片URL
- (void)syntheticImagesWithImageURLArray:(NSMutableArray *)imageURLArray andNewImageWidth:(CGFloat)width height:(CGFloat)height withImg:(void(^)(UIImage *image))returnImg {
    _queue = [[NSOperationQueue alloc] init];
    // 创建一个队列
    NSInteger cont = imageURLArray.count;
    if (cont > 9) {
        cont = 9;
    }
    __block typeof(self) temp = self;
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < cont; i ++) {
        [temp downloadWithUrl:imageURLArray[i] andDownLoadData:^(UIImage *image) {
            if (image) {
                [imageArray addObject:image];
            }
            if (imageArray.count == cont) {
                [temp syntheticImagesWithImageArray:imageArray andNewImageWidth:width height:height withImg:^(UIImage *image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        returnImg(image);
                    });
                }];
            }
        }];
    }
}

// 下载图片
- (void)downloadWithUrl:(NSString *)url andDownLoadData:(void (^) (UIImage *image))downLoadImg {
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *downloadImg = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            UIImage *img = [UIImage imageWithData:data];
            NSLog(@"%d", [NSThread isMainThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                downLoadImg(img);
            });
        }];
        [dataTask resume];
    }];
    [_queue addOperation:downloadImg];
}

- (void)dealloc {
    NSLog(@"syntheticImage");
}
@end
