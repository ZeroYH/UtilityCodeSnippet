//
//  JFSpeechRecognitionConstant.m
//  ChatComps
//
//  Created by StarLord on 2018/9/7.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JFSpeechRecognitionConstant.h"
#import "CategoryHeader.h"
#import "JFiFlyService.h"
#import "Constant.h"

#define kSpeechRecognizerFolder @"SpeechRecognizer"
#define kSpeechRecognizerSuffix @".pcm"

@implementation JFSpeechRecognitionConstant

+ (NSString *)speechRecognizerLocalFolderName {
    return kSpeechRecognizerFolder;
}

+ (NSString *)speechRecognizerLocalRelativePath {
    NSString *relativePath = [NSString stringWithFormat:@"%@/%@%@", kSpeechRecognizerFolder, [NSString uuidString], kSpeechRecognizerSuffix];
    return relativePath;
}

+ (void)createAudioLocalFolder {
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@", [JFiFlyService iFlySDKWorkPath], [EnvironmentVariable getIMUserID], [JFSpeechRecognitionConstant speechRecognizerLocalFolderName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

@end
