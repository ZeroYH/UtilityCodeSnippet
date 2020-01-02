//
//  SpeechRecognitionBox.m
//  ChatComps
//
//  Created by YRH on 2018/9/3.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JFSpeechRecognitionBox.h"
#import <objc/message.h>
#import "Masonry.h"
#import "ThemeKit.h"
#import "JFRecordingSoundWave.h"
#import "JFSpeechRecognitionManager.h"
#import "JFSpeechRecognitionConstant.h"
#import "JFiFlyService.h"
#import "Constant.h"

@interface JFSpeechRecognitionBox () <JFSpeechRecognitionManagerDelegate>

/// box内容视图
@property (nonatomic, strong) UIView *boxContentView;
/// 文字翻译层
@property (nonatomic, strong) UITextView *literalTranslationTextView;
/// 语音动画层
@property (nonatomic, strong) UIView *speechAnimationView;
/// 波纹图
@property (nonatomic, strong) JFRecordingSoundWave *soundWaveView;
/// 操作按钮层
@property (nonatomic, strong) UIView *operationButtonBackView;
/// 录音阶段
@property (nonatomic, assign) RecordingPhase recordingPhase;
/// 存放当前操作按钮数组
@property (nonatomic, strong) NSMutableArray <UIButton *>*currentButtonArray;
/// 计时器
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timerLength;

/// 语音识别
@property (nonatomic, strong) JFSpeechRecognitionManager *speechRecognizer;

@end

@implementation JFSpeechRecognitionBox

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
        [self theme];
        [self addObserver];
        _timerLength = 0;
    }
    return self;
}

#pragma mark - createView
- (void)createView {
    // 背景图层设置
    self.layer.cornerRadius = 12.0f;
    self.layer.masksToBounds = YES;
//    self.layer.borderWidth = 1.0f;
//    self.layer.borderColor = [UIColor theme_colorForKey:@"chat_viewBackgroud" from:@"chat"]().CGColor;//[UIColor whiteColor].CGColor;
    [self.boxContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.width.mas_equalTo(kBoxWidth);
    }];
    // 文字展示层
    [self.literalTranslationTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_boxContentView).offset(5);
        make.left.equalTo(_boxContentView).offset(5);
        make.right.equalTo(_boxContentView).offset(-5);
        make.height.greaterThanOrEqualTo(@kBlank);
    }];
    // 声波动画层
    [self.speechAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_literalTranslationTextView.mas_bottom).offset(kBlank);
        make.left.right.equalTo(_boxContentView);
        make.height.mas_equalTo(kOperationButtonHeight);
    }];
    [self.soundWaveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_speechAnimationView);
    }];
    // 按钮背景层
    [self.operationButtonBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_speechAnimationView.mas_bottom);
        make.left.equalTo(_boxContentView).offset(5);
        make.right.equalTo(_boxContentView).offset(-5);
        make.bottom.equalTo(_boxContentView);
        make.height.mas_equalTo(0);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - 布局操作按钮
- (void)layoutOperationButtonWithContentArray:(NSMutableArray <JFSpeechOperationBtnModel *>*)array {
    if (!array || array.count == 0) {
        return;
    }
    // 清空
    if (_currentButtonArray.count > 0) {
        [_currentButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [_currentButtonArray removeAllObjects];
    }
    // 创建
    [self updateOperationButtonBackViewHeight];
    NSMutableArray *buttonArray = [NSMutableArray array];
    for (JFSpeechOperationBtnModel *model in array) {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
        button.extraObj = model;
        [button setTitle:model.text forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(operationAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [buttonArray addObject:button];
        button.theme_backgroundColor = [UIColor theme_navigationBarColorForKey:@"barTintColor"];
        [button setTheme_tintColor:Theme_TitleColor];
        [_operationButtonBackView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_operationButtonBackView.mas_top).offset(kMinInterval);
            make.bottom.equalTo(_operationButtonBackView);
        }];
    }
    self.currentButtonArray = buttonArray;
    if (buttonArray.count == 1) {
        UIButton *button = [buttonArray firstObject];
        [button mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_operationButtonBackView);
        }];
    } else {
        [self.currentButtonArray mas_distributeViewsAlongAxis:(MASAxisTypeHorizontal) withFixedSpacing:kMinInterval leadSpacing:0.0f tailSpacing:0.0f];
    }
}

- (void)updateOperationButtonBackViewHeight {
    [self.operationButtonBackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kOperationButtonHeight + kMinInterval);
    }];
}

#pragma mark - 主题
- (void)theme {
    self.theme_backgroundColor = self.boxContentView.theme_backgroundColor = [UIColor theme_navigationBarColorForKey:@"barTintColor"];
    self.operationButtonBackView.theme_backgroundColor = [UIColor theme_colorForKey:@"chat_viewBackgroud" from:@"chat"];;//[UIColor theme_colorForKey:@"chatListSeperatorLine" from:@"chat"];//[UIColor theme_colorForKey:@"chat_viewBackgroud" from:@"chat"];
}

#pragma mark - 添加监听
- (void)addObserver {
    [self.literalTranslationTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)removeObserver {
    [self.literalTranslationTextView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGFloat height = self.literalTranslationTextView.contentSize.height;
        [_literalTranslationTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        !_updateTextViewHeight?:_updateTextViewHeight(height);
    }
}

#pragma mark - 操作按钮的点击事件
- (void)operationAction:(UIButton *)sender {
    !self.operationCompletionHandle?:self.operationCompletionHandle(sender);
}

#pragma mark - 操作按钮数组getter
- (void)setOperationButtonArray:(NSMutableArray<JFSpeechOperationBtnModel *> *)operationButtonArray {
    _operationButtonArray = operationButtonArray;
    // 按钮
    [self layoutOperationButtonWithContentArray:operationButtonArray];
}

#pragma mark - 时事显示识别的语音
- (void)updateSpeechRecognitionString:(NSString *)string {
    _literalTranslationTextView.text = string;
}

#pragma mark - 改变声波线
- (void)updateSoundWaveWithVolume:(CGFloat)volume {
    // ((40.0 / 2.0) / 30.0) * volume
    // [JFRecordingSoundWave resetAveragePowerLevel:(volume * 2.0 - 60.0)]
    [_soundWaveView drowWave:[_soundWaveView customDrowAveragePower:((kOperationButtonHeight / 2.0) / 30.0) * volume]];
}

#pragma mark - 是否正在识别
- (BOOL)boxIsListening {
    return _speechRecognizer.speechRecognierIsListening;
}

#pragma mark - 销毁识别对象
- (BOOL)boxDestroySpeechRecognizer {
    return [self.speechRecognizer destroy];
}

#pragma mark - 录音识别相关
// 开始录音识别
- (NSString *)speechRecognitionStartWithRelativePath {
    [JFSpeechRecognitionConstant createAudioLocalFolder];
    NSString *relativePath = [JFSpeechRecognitionConstant speechRecognizerLocalRelativePath];
    [self.speechRecognizer createAudiolocalRelativeFilePath:[NSString stringWithFormat:@"%@/%@", [EnvironmentVariable getIMUserID], relativePath]];
    BOOL isStart = [self.speechRecognizer speechRecognizerStartListening];
    if (!isStart) {
        !_startListeningError?:_startListeningError();
    } else {
        // 开启计时器
        [self.timer setFireDate:[NSDate distantPast]];
    }
    return relativePath;
}
// 录音识别结束
- (void)speechRecognitionEnd {
    [self.speechRecognizer speechRecognizerStopListening];
}
// 取消录音识别
- (void)speechRecognitionCancel {
    [self.speechRecognizer speechRecognizercancel];
}
// 删除录音文件
- (void)deleteAudioFile {
    [self.speechRecognizer deleteAudiolocalFile];
}

#pragma mark - 语音听写代理
/// 识别结果返回代理
- (void)speechRecognizerOnResults:(NSString *)results isLast:(BOOL)isLast {
    NSString *text = _literalTranslationTextView.text;
    NSString *newText = [text stringByAppendingString:results];
    _literalTranslationTextView.text = newText;
    if (_delegate != nil && [_delegate respondsToSelector:@selector(boxSpeechRecognizerOnResults:isLast:)]) {
        [_delegate boxSpeechRecognizerOnResults:results isLast:isLast];
    }
}

/// 识别会话结束返回代理
- (void)speechRecognizerOnCompleted:(IFlySpeechError *)error {
    // 销毁计时器
    [self releaseTimer];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(boxSpeechRecognizerOnCompleted:)]) {
        [_delegate boxSpeechRecognizerOnCompleted:error];
    }
}

/// 停止录音回调
- (void)speechRecognizerOnEndOfSpeech {
    // 销毁计时器
    [self releaseTimer];
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(endOfSpeechWithText:speechTimeLength:)]) {
        [_delegate endOfSpeechWithText:_literalTranslationTextView.text speechTimeLength:_timerLength];
    }
}

/// 开始录音回调
- (void)speechRecognizerOnBeginOfSpeech {
    
}

/// 音量回调函数
- (void)speechRecognizerOnVolumeChanged:(int)volume {
    [self updateSoundWaveWithVolume:(volume * 1.0)];
    NSLog(@"**** %d", volume);
}

/// 会话取消回调
- (void)speechRecognizerOnCancel {
    // 销毁计时器
    [self releaseTimer];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(onCancelSpeech)]) {
        [_delegate onCancelSpeech];
    }
}

#pragma mark - 计时器
- (void)speechRecognitionTimer:(NSTimer *)sender {
    NSLog(@"--- %ld", _timerLength);
    if (_delegate != nil && [_delegate respondsToSelector:@selector(listeningSpeechTimeLength:)]) {
        [_delegate listeningSpeechTimeLength:_timerLength];
    }
    _timerLength += 1;
}

#pragma mark - 销毁计时器
- (void)releaseTimer {
    if (_timer) {
        [_timer setFireDate:[NSDate distantFuture]];
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - lazy
- (UIView *)boxContentView {
    if (!_boxContentView) {
        _boxContentView = [[UIView alloc] init];
        [self addSubview:_boxContentView];
    }
    return _boxContentView;
}

- (UITextView *)literalTranslationTextView {
    if (!_literalTranslationTextView) {
        _literalTranslationTextView = [[UITextView alloc] init];
        _literalTranslationTextView.editable = NO;
        [self.boxContentView addSubview:_literalTranslationTextView];
        _literalTranslationTextView.backgroundColor = [UIColor clearColor];
        _literalTranslationTextView.font = [UIFont systemFontOfSize:17];
        _literalTranslationTextView.textColor = [UIColor whiteColor];
    }
    return _literalTranslationTextView;
}

- (UIView *)speechAnimationView {
    if (!_speechAnimationView) {
        _speechAnimationView = [[UIView alloc] init];
        [self.boxContentView addSubview:_speechAnimationView];
    }
    return _speechAnimationView;
}

- (JFRecordingSoundWave *)soundWaveView {
    if (!_soundWaveView) {
        _soundWaveView = [[JFRecordingSoundWave alloc] init];
        [self.speechAnimationView addSubview:_soundWaveView];
    }
    return _soundWaveView;
}

- (UIView *)operationButtonBackView {
    if (!_operationButtonBackView) {
        _operationButtonBackView = [[UIView alloc] init];
        [self.boxContentView addSubview:_operationButtonBackView];
    }
    return _operationButtonBackView;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(speechRecognitionTimer:) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (JFSpeechRecognitionManager *)speechRecognizer {
    if (!_speechRecognizer) {
        _speechRecognizer = [[JFSpeechRecognitionManager alloc] init];
        _speechRecognizer.delegate = self;
    }
    return _speechRecognizer;
}

- (void)dealloc {
    [self removeObserver];
    NSLog(@"语音识别组件销毁");
}

@end

@implementation JFSpeechOperationBtnModel

+ (JFSpeechOperationBtnModel *)createOperationBtnModelWithText:(NSString *)text sel:(SEL)sel {
    JFSpeechOperationBtnModel *model = [JFSpeechOperationBtnModel new];
    model.text = text;
    model.sel = sel;
    return model;
}

@end

@implementation UIButton (ExtraAttributes)

- (void)setExtraObj:(id)extraObj {
    objc_setAssociatedObject(self, "extraObj", extraObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)extraObj {
    return objc_getAssociatedObject(self, "extraObj");
}

@end
