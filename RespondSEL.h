//
//  RespondSEL.h
//  ChatComps
//
//  Created by Spider-Man on 2018/10/9.
//  Copyright © 2018 Javor Feng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

+ (void)respondNonParameterSEL:(SEL)sender;

+ (void)respondParameterSEL:(SEL)sender parameter:(id)parameter;

@end

NS_ASSUME_NONNULL_END
