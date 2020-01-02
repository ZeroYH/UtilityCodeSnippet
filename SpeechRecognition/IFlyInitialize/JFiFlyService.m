//
//  IFlyInitializeService.m
//  ChatComps
//
//  Created by YRH on 2018/9/7.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JFiFlyService.h"

@implementation JFiFlyService

#pragma mark - 科大讯飞初始化启动服务
+ (void)iFlyInitializeStartService {
    //设置sdk的log等级，log保存在下面设置的工作路径中
    [IFlySetting setLogFile:LVL_ALL];
    //打开输出在console的log开关
    [IFlySetting showLogcat:YES];
    //设置sdk的工作路径
    [IFlySetting setLogFilePath:[self iFlySDKWorkPath]];
    //Appid是应用的身份信息，具有唯一性，初始化时必须要传入Appid。
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APPID_VALUE];
    [IFlySpeechUtility createUtility:initString];
}

+ (NSString *)iFlySDKWorkPath {
    NSString *workPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return workPath;
}

@end
