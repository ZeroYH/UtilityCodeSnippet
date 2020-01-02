//
//  URLUtil.m
//
//  Created by s on 13-12-3.
//  Copyright (c) 2013年 s. All rights reserved.
//

#import "URLUtil.h"
#import "StringUtil.h"

@implementation URLUtil


+ (BOOL)isURL:(NSString *)url {
    if(url.length < 1)
        return NO;
    if (url.length>4 && [[url substringToIndex:4] isEqualToString:@"www."]) {
        url = [NSString stringWithFormat:@"http://%@",url];
    } else {
        url = url;
    }
        
    NSString *urlRegex = @"(((https|http)?://)?([a-z0-9]+[.])|(www.))\\w+[.|\\/]([a-z0-9]{0,})?[[.]([a-z0-9]{0,})]+((/[\\S&&[^,;\u4E00-\u9FA5]]+)+)?([.][a-z0-9]{0,}+|/?)";
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:url];
}

+ (BOOL)isRelativeURL:(NSString *)URL {
    if(URL == nil || URL.length == 0) return NO;
    if(![StringUtil contains:URL findString:@"http:"] || ![StringUtil contains:URL findString:@"https:"])
        return NO;
    return YES;
}

+ (NSString *)getUrlWithIsSafe:(BOOL)isSafe ip:(NSString *)ip port:(NSString *)port serverPath:(NSString *)serverPath {
    NSString *url = isSafe ? @"https://" : @"http://";
    url = [url stringByAppendingString:ip];
    url = [url stringByAppendingString:@":"];
    url = [url stringByAppendingString:port];
    url = [url stringByAppendingString:@"/"];
    url = [url stringByAppendingString:serverPath];
    return url;
}


@end
