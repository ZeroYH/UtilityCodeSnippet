//
//  JFSpeechMessageSender.m
//  ChatComps
//
//  Created by StarLord on 2018/9/10.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JFSpeechMessageSender.h"
#import "CategoryHeader.h"
#import "Constant.h"
#import "UploadMessageDataManager.h"

@implementation JFSpeechMessageSender

+ (void)speechRecognizeSendMessageWithRecognitionText:(NSString *)text time:(NSInteger)time audioRelativePath:(NSString *)audioRelativePath {
    // 识别出文字的，光速短信
    if (!text || [text isEqualToString:@""]) {
        text = @"(未识别)";
    }
    NSDictionary *jsonDic = @{@"url":@"", @"path":audioRelativePath?:@"", @"text":text, @"device":@"iOS"};
    NSString *jsonString = jsonDic.toString;
    NSData *audioData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", kPath, audioRelativePath]];
    NSString *fileName = [[audioRelativePath componentsSeparatedByString:@"/"] lastObject];
    [UploadMessageDataManager uploadDataToCloudAndPreSendWithMessageString:jsonString toUserID:[[EnvironmentVariable getPropertyForKey:@"toUserID" WithDefaultValue:@""] intValue] postType:[[EnvironmentVariable getPropertyForKey:@"postType" WithDefaultValue:@""] integerValue] subType:subtype_speechRecognize data:audioData fileName:fileName messageExtra:nil];
}

@end
