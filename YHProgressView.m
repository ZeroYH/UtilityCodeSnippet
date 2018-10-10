//
//  ProgressView.m
//  KeyBoardTest
//
//  Created by YRH on 2018/4/3.
//  Copyright © 2018年 YRH. All rights reserved.
//

#import "YHProgressView.h"

@interface YHProgressView () <CAAnimationDelegate>

/// 圆圈层
@property (nonatomic, strong) CAShapeLayer *circleShapeLayer;
/// 进度文字层
@property (nonatomic, strong) CATextLayer *percentTextLayer;
/// 镂空层
@property (nonatomic, strong) CAShapeLayer *clearShapeLayer;
/// 背景层
@property (nonatomic, strong) CALayer *backgroundLayer;

@property (nonatomic, copy) AnimationFinish animationFinished;

@end

@implementation YHProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 背景
    self.backgroundLayer.frame = self.bounds;
    
    // 光圈
    CGFloat circleRadius = 62;
    CGFloat minBoundsLength = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    if (minBoundsLength < 62) {
        circleRadius = minBoundsLength - 10;
    }
    self.circleShapeLayer.frame = CGRectMake(0, 0, circleRadius, circleRadius);
    self.circleShapeLayer.position = self.center;
    UIBezierPath *aperturePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(circleRadius / 2, circleRadius / 2) radius:(circleRadius / 2 - 1) startAngle:0 endAngle:2 * M_PI clockwise:YES];
    self.circleShapeLayer.path = [aperturePath CGPath];
    
    // 文字层
    if (circleRadius == 62) {
        self.percentTextLayer.frame = CGRectMake(0, 0, 30, 16);
        UIFont *font = [UIFont systemFontOfSize:12];
        CFStringRef fontName = (__bridge CFStringRef)(font.fontName);
        CGFontRef fontRef = CGFontCreateWithFontName(fontName);
        _percentTextLayer.font = fontRef;
        _percentTextLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef);
    } else if (circleRadius > 20) {
        self.percentTextLayer.frame = CGRectMake(0, 0, 25, 12);
        UIFont *font = [UIFont systemFontOfSize:9];
        CFStringRef fontName = (__bridge CFStringRef)(font.fontName);
        CGFontRef fontRef = CGFontCreateWithFontName(fontName);
        _percentTextLayer.font = fontRef;
        _percentTextLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef);
    }
    self.percentTextLayer.position = _circleShapeLayer.position;
    
    // 镂空层
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:self.center radius:(circleRadius / 2 - 1) startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    self.clearShapeLayer.path = path.CGPath;
}

#pragma mark - 改变进度
- (void)changePercent:(CGFloat)percent animationFinish:(AnimationFinish)animationFinish {
    if (animationFinish) {
        self.animationFinished = animationFinish;
    }
    CGFloat progress = fabs(percent * 100.0f);
    NSString *percentString = [NSString stringWithFormat:@"%.f%%", progress];
    self.percentTextLayer.string = percentString;
    if (percent == 1.0) {
        [self exitAnimation];
    }
}

#pragma mark - 背景色
- (UIColor *)maskBackgroundColor {
    if (!_maskBackgroundColor) {
        _maskBackgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    }
    return _maskBackgroundColor;
}

#pragma mark - 圆圈颜色
- (UIColor *)circleColor {
    if (!_circleColor) {
        _circleColor = [UIColor whiteColor];
    }
    return _circleColor;
}

#pragma mark - 字体颜色
- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor whiteColor];
    }
    return _textColor;
}

#pragma mark - 圆圈宽度
- (CGFloat)circleLineWidth {
    if (_circleLineWidth == 0.0f) {
        _circleLineWidth = 5.0f;
    }
    return _circleLineWidth;
}

#pragma mark - 背景层
- (CALayer *)backgroundLayer {
    if (!_backgroundLayer) {
        _backgroundLayer = [CALayer layer];
        [self.layer addSublayer:_backgroundLayer];
        _backgroundLayer.backgroundColor = self.maskBackgroundColor.CGColor;
    }
    return _backgroundLayer;
}

#pragma mark - 圆圈layer
- (CAShapeLayer *)circleShapeLayer {
    if (!_circleShapeLayer) {
        _circleShapeLayer = [CAShapeLayer layer];
        _circleShapeLayer.lineWidth = self.circleLineWidth;
        _circleShapeLayer.strokeColor = self.circleColor.CGColor;
        _circleShapeLayer.fillColor = [UIColor clearColor].CGColor;
        [self.backgroundLayer addSublayer:_circleShapeLayer];
        _circleShapeLayer.shadowRadius = 4.0f;
        _circleShapeLayer.shadowColor = self.circleColor.CGColor;
        _circleShapeLayer.shadowOpacity = 1.0f;
        _circleShapeLayer.shadowOffset = CGSizeMake(0, 1);
        // 开启动画
        [self circleAnimation];
    }
    return _circleShapeLayer;
}

#pragma mark - 文字层
- (CATextLayer *)percentTextLayer {
    if (!_percentTextLayer) {
        _percentTextLayer = [CATextLayer layer];
        _percentTextLayer.contentsScale = [UIScreen mainScreen].scale;
        _percentTextLayer.alignmentMode = kCAAlignmentCenter;
        _percentTextLayer.wrapped = YES;
        [self.backgroundLayer addSublayer:_percentTextLayer];
        _percentTextLayer.foregroundColor = self.textColor.CGColor;
    }
    return _percentTextLayer;
}

#pragma mark - 镂空层
- (CAShapeLayer *)clearShapeLayer {
    if (!_clearShapeLayer) {
        _clearShapeLayer = [CAShapeLayer layer];
        _clearShapeLayer.fillRule = kCAFillRuleEvenOdd;//中间镂空的关键点 填充规则
        _clearShapeLayer.fillColor = self.maskBackgroundColor.CGColor;
        _clearShapeLayer.opacity = 1;
    }
    return _clearShapeLayer;
}

#pragma mark - 圆圈动画
- (void)circleAnimation {
    // 呼吸动画（改变透明度动画）
    CABasicAnimation *opacityAnimation =[CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.3f];
    // 缩放动画
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:6.0f];
    scaleAnimation.toValue = [NSNumber numberWithFloat:3.0f];
    // 组动画
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = [NSArray arrayWithObjects:opacityAnimation, scaleAnimation, nil];
    groupAnimation.duration = 1.5f;
    groupAnimation.repeatCount = MAXFLOAT;
    groupAnimation.autoreverses = YES;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_circleShapeLayer addAnimation:groupAnimation forKey:@"groupAnimation"];
}

#pragma mark - 退场动画
- (void)hiddenProgressLayer {
    _percentTextLayer.hidden = _circleShapeLayer.hidden = YES;
    _backgroundLayer.mask = _clearShapeLayer;
}

- (void)exitAnimation {
    [self hiddenProgressLayer];
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
    scaleAnimation.toValue = [NSNumber numberWithFloat:MAX(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) / 15.0f];
    scaleAnimation.duration = 0.5f;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    scaleAnimation.delegate = self;
    [_backgroundLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.animationFinished();
}

@end
