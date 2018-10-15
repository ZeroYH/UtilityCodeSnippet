//
//
//  Created by YRH on 18-8-5.
//  Copyright (c) 2018年 YRH. All rights reserved.
//

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif

/// 字体
#define FONT_SYSTEM(fontSize) [UIFont fontWithName:@"helvetica Neue" size:fontSize]
/// 系统字体
#define FONT(size) [UIFont systemFontOfSize:size]
/// 粗体
#define BOLD_FONT(size) [UIFont boldSystemFontOfSize:size]

/// 状态栏高度
#define STATUS_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height
/// 手机屏幕宽
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
/// 手机屏幕高
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
/// 系统控件高度
#define NAVIGATION_BAR_HEIGHT 44
#define X_TOP_BAR_HEIGHT NAVIGATION_BAR_HEIGHT + STATUS_HEIGHT
#define TOOL_BAR_HEIGHT 44
#define TABBAR_HEIGHT 49
/// 1分辨率线高
#define LINE_HEIGHT (1 / [UIScreen mainScreen].scale)

/// RGB颜色
#define RGB(r, g, b) RGBA(r, g, b, 1.0f)
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]
/// 十六进制颜色
#define HEX_COLOR(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]
/// 随机色
#define RandomColor RGB(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))
/// 随机亮色
#define RandomLightColor RGB(arc4random()%128+128,arc4random()%128+128,arc4random()%128+128)
/// 常用颜色
#define Color_WhiteColor [UIColor whiteColor]
#define Color_BlackColor [UIColor blackColor]
#define Color_DarkGrayColor [UIColor darkGrayColor]
#define Color_LightGrayColor [UIColor lightGrayColor]
#define Color_GrayColor [UIColor grayColor]
#define Color_RedColor [UIColor redColor]
#define Color_GreenColor [UIColor greenColor]
#define Color_BlueColor [UIColor blueColor]
#define Color_CyanColor [UIColor cyanColor]
#define Color_YellowColor [UIColor yellowColor]
#define Color_MagentaColor [UIColor magentaColor]
#define Color_OrangeColor [UIColor orangeColor]
#define Color_PurpleColor [UIColor purpleColor]
#define Color_BrownColor [UIColor brownColor]
#define Color_ClearColor [UIColor clearColor]
#define Color_GroupTableViewBackgroundColor [UIColor groupTableViewBackgroundColor]

/// 按钮相关
#define BUTTON_NEW_CUSTOM [UIButton buttonWithType:UIButtonTypeCustom]
#define BUTTON_CLICK(button,function) [button addTarget:self action:@selector(function) forControlEvents:UIControlEventTouchUpInside];
#define BUTTON_TITLE(button,title) [button setTitle:title forState:UIControlStateNormal]

/// 沙盒Document路径
#define DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
/// 沙盒temp路径
#define TEMP_PATH NSTemporaryDirectory()
/// 沙盒Cache路径
#define CACHE_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]

/// 弱引用/强引用
#define WEAK_SELF(weakSelf)    __weak __typeof(&*self)weakSelf = self;
#define WEAK(type)   __weak typeof(type) weak##type = type;
#define STRONG(type) __strong typeof(type) type = weak##type;

/// 开发的时候打印，但是发布的时候不打印的NSLog
#ifdef DEBUG
#define Log(...) printf("************************************************************************************************\n%s 第%d行 \n %s\n\n",__func__,__LINE__,[[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define Log(...)
#endif

/// 读取Bundle文件
#define BundleFile(bundle,path)  [[[NSBundle mainBundle] pathForResource:bundle ofType:nil] stringByAppendingString:path]
/// 读取Bundle中的图片文件
#define BundleImage(bundle,path) [UIImage imageWithContentsOfFile:BundleFile(bundle,path)]

/// 系统单例(可能非单例)名称简写宏
#define APPLICATION        [UIApplication sharedApplication]
#define KEYWINDOW          [UIApplication sharedApplication].keyWindow
#define APPDELEGATE        [UIApplication sharedApplication].delegate
#define USERDEFAULT        [NSUserDefaults standardUserDefaults]
#define NOTIFICATIONCENTER [NSNotificationCenter defaultCenter]
#define HTTPCOOKIESTORAGE  [NSHTTPCookieStorage sharedHTTPCookieStorage]
#define MAINBUNDLE         [NSBundle mainBundle]
#define CURRENTDEVICE      [UIDevice currentDevice]
/// APP版本号
#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
/// 系统版本号
#define SYSTEM_VERSION [[UIDevice currentDevice] systemVersion]
/// 获取当前语言
#define CURRENT_LANGUAGE ([[NSLocale preferredLanguages] objectAtIndex:0])
/// 判断是否为iPhone
#define IsIPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
/// 判断是否为iPad
#define IsIPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/// 判空处理
/// 字符串是否为空
#define StringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
/// 数组是否为空
#define ArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
/// 字典是否为空
#define DictionaryIsEmpty(dict) (dict == nil || [dict isKindOfClass:[NSNull class]] || dict.allKeys == 0)
/// 是否是空对象
#define ObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))
/// 空字符串
#define EmptyString @""
/// 空数组
#define EmptyArray @[]
/// 空字典
#define EmptyDictionary @{}
/// 安全字符串
#define SafeString(str) StringIsEmpty(str)?EmptyString:str
/// 安全数组
#define SafeArray(array) ArrayIsEmpty(array)?EmptyArray:array
/// 安全字典
#define SafeDictionary(dict) DictionaryIsEmpty(dict)?:EmptyDictionary:dict
/// 数值转字符串
#define NumberToString(i) [@(i) stringValue]

/// 系统版本号
#define IOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 9.0)
#define IOS8_10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 10.0)
#define IOS9 ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 10.0)
#define IOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define iOS_VERSION  [[[UIDevice currentDevice] systemVersion] floatValue]

// 是否是IPhoneX
#define  isIPhoneX (SCREEN_WIDTH == 375.f && SCREEN_HEIGHT == 812.f ? YES : NO)
// 小屏幕IPhone
#define isSamllScreenIPhone SCREEN_WIDTH <= 320.f

/**
 *  Runtime 归档解档对象
 *  对应调用
 - (void)encodeWithCoder:(NSCoder *)aCoder {
    PXYNSCodingRuntime_EncodeWithCoder(Father)
 }
 - (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    PXYNSCodingRuntime_InitWithCoder(Father)
 }
 **/
#define PXYNSCodingRuntime_EncodeWithCoder(Class) \ unsigned int outCount = 0;\
Ivar *ivars = class_copyIvarList([Class class], &outCount);\ for (int i = 0; i < outCount; i++) {\
Ivar ivar = ivars[i];\ NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];\
[aCoder encodeObject:[self valueForKey:key] forKey:key];\
}\
free(ivars);\
\
#define PXYNSCodingRuntime_InitWithCoder(Class)\ if (self = [super init]) {\ unsigned int outCount = 0;\
Ivar *ivars = class_copyIvarList([Class class], &outCount);\ for (int i = 0; i < outCount; i++) {\
Ivar ivar = ivars[i];\ NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];\ id value = [aDecoder decodeObjectForKey:key];\ if (value) {\
[self setValue:value forKey:key];\
}\
}\
free(ivars);\
}\ return self;\
\

/// 检测函数运行时间
#define FunctionRunTimeStart CFAbsoluteTime start = CACurrentMediaTime();
#define FunctionRunTimeEnd CFAbsoluteTime end = CACurrentMediaTime(); NSLog(@"time cost: %f", end - start);
