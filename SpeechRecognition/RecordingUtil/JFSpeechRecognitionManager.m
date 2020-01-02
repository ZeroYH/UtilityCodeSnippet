//
//  JFSpeechRecognitionManager.m
//  ChatComps
//
//  Created by YRH on 2018/9/4.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JFSpeechRecognitionManager.h"
#import "JFiFlyService.h"
#import "ISRDataHelper.h"

@interface JFSpeechRecognitionManager () <IFlySpeechRecognizerDelegate>

/// 识别对象
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
/// 录音本地文件
@property (nonatomic, copy) NSString *audiolocalPath;

@end

@implementation JFSpeechRecognitionManager

+ (instancetype)speechRecognizer {
    JFSpeechRecognitionManager *speechRecognition = [[JFSpeechRecognitionManager alloc] init];
    return speechRecognition;
}

- (instancetype)init {
    if (self = [super init]) {
        [self iFlySpeechRecognizer];
    }
    return self;
}

- (IFlySpeechRecognizer *)iFlySpeechRecognizer {
    if (!_iFlySpeechRecognizer) {
        //创建语音识别对象
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        _iFlySpeechRecognizer.delegate = self;
        //设置识别参数
        //设置为听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];

        [_iFlySpeechRecognizer setParameter:@"0" forKey:[IFlySpeechConstant ASR_SCH]];
        
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        [_iFlySpeechRecognizer setParameter:@"zh_cn" forKey:[IFlySpeechConstant LANGUAGE]];
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        // 音量返回时间间隔
        [_iFlySpeechRecognizer setParameter:@"0.05" forKey:[IFlySpeechConstant POWER_CYCLE]];
        //设置是否返回标点符号
//        [_iFlySpeechRecognizer setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
        
        //设置语音后端点:后端点静音检测时间，即用户停止说话多长时间内即认为不再输入， 自动停止录音
        [_iFlySpeechRecognizer setParameter:@"10000" forKey:[IFlySpeechConstant VAD_EOS]];
        //设置语音前端点:静音超时时间，即用户多长时间不说话则当做超时处理 engine指定iat识别默认值为5000；
        [_iFlySpeechRecognizer setParameter:@"5000" forKey:[IFlySpeechConstant VAD_BOS]];
        // 设置麦克风为音频源
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
    }
    return _iFlySpeechRecognizer;
}

#pragma mark - 是否正在识别
- (BOOL)speechRecognierIsListening {
    return _iFlySpeechRecognizer.isListening;
}

#pragma mark - 设置本地录音文件名
- (void)createAudiolocalRelativeFilePath:(NSString *)audioPath {
    //asr_audio_path 是录音文件名，设置value为nil或者为空取消保存，默认保存目录在Library/cache下。
    self.audiolocalPath = audioPath;
    [_iFlySpeechRecognizer setParameter:audioPath forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
}

#pragma mark - 启动识别服务
- (BOOL)speechRecognizerStartListening {
    [self.iFlySpeechRecognizer cancel];
    return [self.iFlySpeechRecognizer startListening];
}

#pragma mark - 停止录音
- (void)speechRecognizerStopListening {
    [self.iFlySpeechRecognizer stopListening];
}

#pragma mark - 取消本次录音
- (void)speechRecognizercancel {
    [self.iFlySpeechRecognizer cancel];
}

#pragma mark - 删除录音文件
- (BOOL)deleteAudiolocalFile {
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", [JFiFlyService iFlySDKWorkPath], self.audiolocalPath]]) {
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", [JFiFlyService iFlySDKWorkPath], self.audiolocalPath] error:&error];
        return result;
    } else {
        return NO;
    }
}

#pragma mark - 销毁识别对象
- (BOOL)destroy {
    return [self.iFlySpeechRecognizer destroy];
}

#pragma mark - IFlySpeechRecognizerDelegate协议实现
// 识别结果返回代理
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast {
    if (results.count == 0) {
        return;
    }
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = [results objectAtIndex:0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString * resultFromJson = [ISRDataHelper stringFromJson:resultString];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(speechRecognizerOnResults:isLast:)]) {
        [_delegate speechRecognizerOnResults:resultFromJson isLast:isLast];
    }
}

// 识别会话结束返回代理
- (void)onCompleted:(IFlySpeechError *)error {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(speechRecognizerOnCompleted:)]) {
        [_delegate speechRecognizerOnCompleted:error];
    }
}

// 停止录音回调
- (void)onEndOfSpeech {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(speechRecognizerOnEndOfSpeech)]) {
        [_delegate speechRecognizerOnEndOfSpeech];
    }
}

// 开始录音回调
- (void)onBeginOfSpeech {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(speechRecognizerOnBeginOfSpeech)]) {
        [_delegate speechRecognizerOnBeginOfSpeech];
    }
}

// 音量回调函数
- (void)onVolumeChanged:(int)volume {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(speechRecognizerOnVolumeChanged:)]) {
        [_delegate speechRecognizerOnVolumeChanged:volume];
    }
}

// 会话取消回调
- (void)onCancel {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(speechRecognizerOnCancel)]) {
        [_delegate speechRecognizerOnCancel];
    }
}

@end
