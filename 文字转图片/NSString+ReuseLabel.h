//
//  NSString+ReuseLabel.h
//  ToolsLibrary
//
//  Created by YRH on 2018/10/13.
//  Copyright © 2018 Javor Feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (ReuseLabel)


- (CGSize )getSizeWithFont:(UIFont *)font constrainedWidth:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;

@end

