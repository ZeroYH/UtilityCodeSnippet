//
//  JFRecordingSoundWave.m
//  ChatComps
//
//  Created by YRH on 2018/9/4.
//  Copyright © 2018年 Javor Feng. All rights reserved.
//

#import "JFRecordingSoundWave.h"
#import "Masonry.h"
#import "ThemeKit.h"

@interface JFRecordingSoundWave ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIBezierPath *pathUpper;
@property (nonatomic, strong) UIBezierPath *pathLower;

@property (nonatomic, strong) CAShapeLayer *shapeLayerUpper;
@property (nonatomic, strong) CAShapeLayer *shapeLayerLower;

@end

@implementation JFRecordingSoundWave
{
    CGFloat _currentX;
    CGFloat _lastPower;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentX = 0.0f;
        _lastPower = 0.0f;
    }
    return self;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.contentView.frame = self.bounds;
    
    [self.pathUpper moveToPoint:CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds))];
    [self.pathLower moveToPoint:CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMidY(self.bounds))];
    
    [self shapeLayerUpper];
    [self shapeLayerLower];
}

- (CGFloat)customDrowAveragePower:(CGFloat)averagePower {
    if (averagePower - _lastPower > 1) {
        averagePower = _lastPower + 1;
    }
    if (averagePower == 20 && _lastPower == 20) {
        averagePower = 20 - 3;
    }
    if (averagePower == 20 && _lastPower == 17) {
        averagePower = _lastPower + 2;
    }
    if (averagePower == 20 && _lastPower == 18) {
        averagePower = _lastPower + 1;
    }
    _lastPower = averagePower;
    return averagePower;
}

#pragma mark - 实时绘图
- (void)drowWave:(CGFloat)averagePower {
    _currentX += 1;
    // 先移动到中间点
    [self.pathUpper addLineToPoint:CGPointMake(_currentX, CGRectGetMidY(self.bounds))];
    [self.pathLower addLineToPoint:CGPointMake(_currentX, CGRectGetMidY(self.bounds))];
    
    // 根据系数获取偏移量
//    CGFloat y = averagePower * CGRectGetMidY(self.bounds);
    CGFloat y = averagePower;
    // 向上
    [_pathUpper addLineToPoint:CGPointMake(_currentX, CGRectGetMidY(self.bounds) + y)];
    // 向下
    [_pathLower addLineToPoint:CGPointMake(_currentX, CGRectGetMidY(self.bounds) - y)];
    
    self.shapeLayerUpper.path = _pathUpper.CGPath;
    self.shapeLayerLower.path = _pathLower.CGPath;
    
    if (_currentX > CGRectGetWidth(self.bounds)) {
        self.scrollView.contentSize = CGSizeMake(_currentX, CGRectGetMaxY(self.bounds));
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width - CGRectGetMaxX(self.bounds), 0) animated:NO];
    }
}

#pragma mark - lazy
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.bounces = NO;
        _scrollView.scrollEnabled = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [self.scrollView addSubview:_contentView];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIBezierPath *)pathUpper {
    if (!_pathUpper) {
        _pathUpper = [UIBezierPath bezierPath];
    }
    return _pathUpper;
}

- (UIBezierPath *)pathLower {
    if (!_pathLower) {
        _pathLower = [UIBezierPath bezierPath];
    }
    return _pathLower;
}

- (CAShapeLayer *)shapeLayerUpper {
    if (!_shapeLayerUpper) {
        _shapeLayerUpper = [CAShapeLayer layer];
        _shapeLayerUpper.lineCap = @"round";
        _shapeLayerUpper.lineWidth = 1.0f;
        _shapeLayerUpper.strokeColor = [UIColor theme_navigationBarColorForKey:@"tintColor"]().CGColor;//[UIColor whiteColor].CGColor;
        _shapeLayerUpper.fillColor = [UIColor clearColor].CGColor;
        [self.contentView.layer addSublayer:_shapeLayerUpper];
    }
    return _shapeLayerUpper;
}

+ (float)resetAveragePowerLevel:(float)averagePower {
    float level; // 声音级别
    float minDecibels = -60.0f; // 60分贝认为没有声音
    if (averagePower < minDecibels)
    {
        level = 0.0f;
    }
    else if (averagePower >= 0.0f)
    {
        level = 1.0f;
    }
    else
    {
        // 计算公式 参考
        //http://stackoverflow.com/questions/9247255/am-i-doing-the-right-thing-to-convert-decibel-from-120-0-to-0-120/16192481#16192481
        float   root            = 2.0f;
        float   minAmp          = powf(10.0f, 0.05f * minDecibels);
        float   inverseAmpRange = 1.0f / (1.0f - minAmp);
        float   amp             = powf(10.0f, 0.05f * averagePower);
        float   adjAmp          = (amp - minAmp) * inverseAmpRange;
        level = powf(adjAmp, 1.0f / root);
    }
    return level;
}

- (CAShapeLayer *)shapeLayerLower {
    if (!_shapeLayerLower) {
        _shapeLayerLower = [CAShapeLayer layer];
        _shapeLayerLower.lineCap = @"round";
        _shapeLayerLower.lineWidth = 1.0f;
        _shapeLayerLower.strokeColor = [UIColor theme_navigationBarColorForKey:@"tintColor"]().CGColor;//[UIColor whiteColor].CGColor;
        _shapeLayerLower.fillColor = [UIColor clearColor].CGColor;
        [self.contentView.layer addSublayer:_shapeLayerLower];
    }
    return _shapeLayerLower;
}

@end
