//
//  JFSpeechRecognitionController.m
//  ChatComps
//
//  Created by YRH on 2018/9/4.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JFSpeechRecognitionController.h"
#import <objc/message.h>
#import "Masonry.h"
#import "ThemeKit.h"
#import "ViewControllerManager.h"
#import "JFSpeechRecognitionBox.h"
#import "Constant.h"
#import "JFSpeechMessageSender.h"
#import "UIView+Toast.h"
#import "JFPcmConversionAmr.h"
#import "JFSpeechRecognitionConstant.h"
#import "MBProgressHUD.h"
#import "JFLanguageManager.h"
#import "AuthorizationUtil.h"

@interface JFSpeechRecognitionController () <UIPopoverPresentationControllerDelegate, JFSpeechRecognitionBoxDelegate>

@property (nonatomic, strong) JFSpeechRecognitionBox *speechRecognitionBox;
/// 正在录音时候显示的操作按钮数组
@property (nonatomic, strong) NSMutableArray <JFSpeechOperationBtnModel *>*recordingArray;
/// 录音结束时显示的操作按钮数组
@property (nonatomic, strong) NSMutableArray <JFSpeechOperationBtnModel *>*recordedArray;
/// 录音文件相对路径
@property (nonatomic, copy) NSString *audioRelativePath;
/// 是否手动结束录制
@property (nonatomic, assign) BOOL isInitiativeEndAudio;
/// 发送的文字
@property (nonatomic, copy) NSString *sendText;
@property (nonatomic, assign) NSInteger speechTime;
@property (nonatomic, copy) DismissCompletion dismissCompletion;

@property (nonatomic, assign) CGFloat popoverWidth;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

/// 标记是否可以发送
@property (nonatomic, assign) BOOL speechRecognizerSessionEnd;
/// 标记是否取消会话
@property (nonatomic, assign) BOOL cancelSpeechRecognizerSession;
/// 标记是否在识别过程中点击了发送按钮
@property (nonatomic, assign) BOOL isIdentifyTouchSendbutton;

@end

@implementation JFSpeechRecognitionController

#pragma mark - 显示弹出窗口
+ (void)presentSpeechRecognitionControllerWithSourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect popoverWidth:(CGFloat)popoverWidth animated:(BOOL)animated permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections dismissCompletion:(DismissCompletion)completion {
    // 1.检测是否有语音权限; 2.有权限就展示
    [AuthorizationUtil autoAuthorizationWithType:AuthorizationTypeAudio complete:^(BOOL granted) {
        if (granted) {
            JFSpeechRecognitionController *poverVC = [JFSpeechRecognitionController new];
            poverVC.view.theme_backgroundColor = [UIColor theme_navigationBarColorForKey:@"barTintColor"];//[UIColor theme_colorForKey:@"textFieldBackgroundColor" from:@"keyBoard"];
            if (completion) {
                poverVC.dismissCompletion = completion;
            }
            poverVC.popoverWidth = popoverWidth;
            // 设置大小
            //    poverVC.preferredContentSize = CGSizeMake(kBoxWidth, 200);
            // 设置 Sytle
            poverVC.modalPresentationStyle = UIModalPresentationPopover;
            // 需要通过 sourceView 来判断位置的
            poverVC.popoverPresentationController.sourceView = sourceView;
            // 指定箭头所指区域的矩形框范围（位置和尺寸）,以sourceView的左上角为坐标原点
            // 这个可以 通过 Point 或  Size 调试位置
            poverVC.popoverPresentationController.sourceRect = sourceRect;
            // 箭头方向
            poverVC.popoverPresentationController.permittedArrowDirections = permittedArrowDirections?:UIPopoverArrowDirectionAny;
            poverVC.popoverPresentationController.backgroundColor = poverVC.view.backgroundColor;
            // 设置代理
            poverVC.popoverPresentationController.delegate = poverVC;
            [ViewControllerManager presentViewController:poverVC animated:animated completion:nil];
        }
    }];
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone; //不适配
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return NO;   //点击蒙版popover消失， 默认YES
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sendText = @"";
    _speechTime = 0;
    _isInitiativeEndAudio = NO;
    _speechRecognizerSessionEnd = NO;
    _cancelSpeechRecognizerSession = NO;
    _isIdentifyTouchSendbutton = NO;
    [self createView];
    _audioRelativePath = [self.speechRecognitionBox speechRecognitionStartWithRelativePath];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)setPopoverWidth:(CGFloat)popoverWidth {
    _popoverWidth = popoverWidth;
    
    [_speechRecognitionBox mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_popoverWidth);
    }];
    [self.view layoutIfNeeded];
    self.preferredContentSize = CGSizeMake(_popoverWidth, CGRectGetHeight(self.speechRecognitionBox.bounds));
}

#pragma mark - createView
- (void)createView {
    [self speechRecognitionBox];
}

#pragma mark - 按钮点击事件
- (void)speechRecognitionOperationAction:(UIButton *)sender {
    JFSpeechOperationBtnModel *selectModel = ({
        JFSpeechOperationBtnModel *model = [sender.extraObj isKindOfClass:[JFSpeechOperationBtnModel class]] ? (JFSpeechOperationBtnModel *)sender.extraObj : nil;
        model;
    });
    if (selectModel.sel && [self respondsToSelector:selectModel.sel]) {
        NSString *selectString = NSStringFromSelector(selectModel.sel);
        SEL selector = selectModel.sel;
        if ([selectString rangeOfString:@":"].location != NSNotFound) {
            // 无参
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL) = (void *)imp;
            func(self, selector);
        } else {
            // 有参
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL, UIView *) = (void *)imp;
            func(self, selector, sender);
        }
    }
}

- (void)cancelRecord:(id)sender {
    Log(@"取消 会话");
    _isInitiativeEndAudio = YES;
    
    if (_speechRecognitionBox.boxIsListening) {
        _cancelSpeechRecognizerSession = YES;
        [_speechRecognitionBox speechRecognitionCancel];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [_speechRecognitionBox deleteAudioFile];
}

- (void)recordEnd:(id)sender {
    Log(@"录制结束");
    // 主动结束录制
    _isInitiativeEndAudio = YES;
    // 结束录音
    [_speechRecognitionBox speechRecognitionEnd];
    if (_speechRecognitionBox.timerLength < 1) {
        // 录制时间短于1m，提示
        [_speechRecognitionBox deleteAudioFile];
        [self.view jk_makeToast:[JFLanguageManager stringWithKey:@"chatSpeechTooShort" table:Table_Chat comment:@"说话声音过短"] duration:1 position:JKToastPositionCenter];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
        // 发送消息
        [self sendRecord:sender];
    }
    
}

- (void)cancelSendRecord:(id)sender {
    Log(@"取消发送录音");
}

- (void)sendRecord:(id)sender {
    Log(@"发送录音");
    if (!_speechRecognizerSessionEnd) {
        self.progressHUD.label.text = [JFLanguageManager stringWithKey:@"chatSpeechRecoding" table:Table_Chat comment:@"正在识别语音"];
        [self.progressHUD showAnimated:YES];
        _isIdentifyTouchSendbutton = YES;
        return;
    }
    
    if (!_isIdentifyTouchSendbutton) {
        self.progressHUD.label.text = @"";
        [self.progressHUD showAnimated:YES];
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 转换格式
        [JFPcmConversionAmr jfAmrAudioWithPcmAudioRelativePath:weakSelf.audioRelativePath];
        // 发送消息
        [JFSpeechMessageSender speechRecognizeSendMessageWithRecognitionText:weakSelf.sendText time:weakSelf.speechTime audioRelativePath:[NSString stringWithFormat:@"/%@/%@.wav", [JFSpeechRecognitionConstant speechRecognizerLocalFolderName], [[[[weakSelf.audioRelativePath componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] firstObject]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressHUD hideAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                if (weakSelf.dismissCompletion) {
                    weakSelf.dismissCompletion(sender);
                }
            }];
        });
    });
}

#pragma mark - 配置操作按钮
- (NSMutableArray <JFSpeechOperationBtnModel *>*)recordingArray {
    if (!_recordingArray) {
        _recordingArray = [[NSMutableArray alloc] init];
        // 配置按钮
        JFSpeechOperationBtnModel *leftModel = [JFSpeechOperationBtnModel createOperationBtnModelWithText:JFLanguageManager.cancel sel:@selector(cancelRecord:)];
        [_recordingArray addObject:leftModel];
        JFSpeechOperationBtnModel *rightModel = [JFSpeechOperationBtnModel createOperationBtnModelWithText:[JFLanguageManager stringWithKey:@"send" table:Table_Tools comment:@"发送"] sel:@selector(recordEnd:)]; // 说完了
        [_recordingArray addObject:rightModel];
    }
    return _recordingArray;
}

- (NSMutableArray <JFSpeechOperationBtnModel *>*)recordedArray {
    if (!_recordedArray) {
        _recordedArray = [[NSMutableArray array] init];
        // 配置按钮
        JFSpeechOperationBtnModel *leftModel = [JFSpeechOperationBtnModel createOperationBtnModelWithText:JFLanguageManager.cancel sel:@selector(cancelSendRecord:)];
        [_recordedArray addObject:leftModel];
        JFSpeechOperationBtnModel *rightModel = [JFSpeechOperationBtnModel createOperationBtnModelWithText:[JFLanguageManager stringWithKey:@"send" table:Table_Tools comment:@"发送"] sel:@selector(sendRecord:)];
        [_recordedArray addObject:rightModel];
    }
    return _recordedArray;
}

#pragma mark - JFSpeechRecognitionBoxDelegate
- (void)endOfSpeechWithText:(NSString *)text speechTimeLength:(NSInteger)timeLength {
    Log(@"停止 录音 代理");
    _speechTime = timeLength;
    if (!_isInitiativeEndAudio) {
        // 不是主动结束录音，时间到了结束录音,更改按钮
        [self.view jk_makeToast:[JFLanguageManager stringWithKey:@"chatSpeechEnd" table:Table_Chat comment:@"语音识别已结束"] duration:1 position:JKToastPositionCenter];
    }
}

- (void)boxSpeechRecognizerOnResults:(NSString *)results isLast:(BOOL)isLast {
    Log(@"返回识别的文字 代理");
    _sendText = [_sendText stringByAppendingString:results];
}

- (void)onCancelSpeech {
    Log(@"取消 会话 代理");
}

- (void)listeningSpeechTimeLength:(NSInteger)timeLength {
    if (60 - timeLength < 10 && 60 - timeLength > 0) {
        // 给出提示
        [self.view jk_makeToast:[NSString stringWithFormat:[JFLanguageManager stringWithKey:@"chatSpeechAgain" table:Table_Chat comment:@"您还能再说%ld秒钟"], 60 - timeLength] duration:1 position:JKToastPositionCenter];
    }
}

// 语音听写会话结束
- (void)boxSpeechRecognizerOnCompleted:(IFlySpeechError *)error {
    Log(@"整个会话结束 代理");
    if (error.errorCode != 0) {
        [self.view jk_makeToast:[NSString stringWithFormat:[JFLanguageManager stringWithKey:@"chatSpeechWrong" table:Table_Chat comment:@"语音听写出错：%@"], error.errorDesc] duration:1 position:JKToastPositionCenter];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } else if (_cancelSpeechRecognizerSession) {
        // 取消会话完成 界面消失
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        // 识别完成，可以发送
        _speechRecognizerSessionEnd = YES;
        if (_isIdentifyTouchSendbutton) {
            // 识别过程中点击了发送按钮，自动发送
            [self sendRecord:nil];
        }
    }
    // 销毁识别对象
    [_speechRecognitionBox boxDestroySpeechRecognizer];
}

#pragma mark - lazy
- (JFSpeechRecognitionBox *)speechRecognitionBox {
    if (!_speechRecognitionBox) {
        _speechRecognitionBox = [JFSpeechRecognitionBox new];
        
        [self.view addSubview:_speechRecognitionBox];
        [_speechRecognitionBox mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
        
        _speechRecognitionBox.delegate = self;
        __weak typeof(self) weakSelf = self;
        _speechRecognitionBox.operationCompletionHandle = ^(UIButton *sender) {
            [weakSelf speechRecognitionOperationAction:sender];
        };
        _speechRecognitionBox.operationButtonArray = self.recordingArray;
        
        _speechRecognitionBox.updateTextViewHeight = ^(CGFloat newHeight) {
            weakSelf.preferredContentSize = CGSizeMake(CGRectGetWidth(weakSelf.speechRecognitionBox.bounds), CGRectGetHeight(weakSelf.speechRecognitionBox.bounds) - kBlank + newHeight);
        };
        
        _speechRecognitionBox.startListeningError = ^{
            [weakSelf.view jk_makeToast:[JFLanguageManager stringWithKey:@"chatSpeechFail" table:Table_Chat comment:@"语音听写开启失败"] duration:1 position:JKToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        };
    }
    return _speechRecognitionBox;
}

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_progressHUD];
        //        _progressHUD.dimBackground = YES;
    }
    return _progressHUD;
}

- (void)dealloc {
    Log(@"识别控件控制器销毁");
}

@end
