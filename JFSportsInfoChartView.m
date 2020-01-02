//
//  JFSportsInfoChatView.m
//  JFHealthComps
//
//  Created by YRH on 2019/1/25.
//  Copyright © 2019 SpiderMan. All rights reserved.
//

#import "JFSportsInfoChartView.h"
#import "ThemeKit.h"
#import "Masonry.h"
#import "Constant.h"
#import "JFLanguageManager.h"
#import "NSAttributedString+Theme.h"

#define kLineWidth 22.0f
@interface JFSportsInfoChartView ()

/// 底色圆环
@property (nonatomic, strong) CAShapeLayer *backCircularLayer;
/// 底色圆环贝塞尔曲线
@property (nonatomic, strong) UIBezierPath *backBezierPath;

/// 多彩动态圆环层
@property (nonatomic, strong) CALayer *polychromeDynamicRingLayer;
/// 动态圆环
@property (nonatomic, strong) CAShapeLayer *dynamicCircularLayer;
/// 色盘层
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

/// 线条
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;

/// 中间显示数据的view
@property (nonatomic, strong) UIView *middleView;
/// 时间
@property (nonatomic, strong) UILabel *dateLabel;
/// 步数
@property (nonatomic, strong) UILabel *stepNumberLabel;
/// 完成度
@property (nonatomic, strong) UILabel *completenessLabel;
/// 目标
@property (nonatomic, strong) UILabel *targetLabel;

/// 计时器
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat circularFloat;

@end

@implementation JFSportsInfoChartView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _circularFloat = - (M_PI / 2);
        [self createView];
        [self theme];
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf sportsInfoChartValues];
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 创建视图
- (void)createView {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.right.equalTo(self).offset(-10);
        make.left.equalTo(self).offset(10);
        make.height.mas_equalTo(1);
    }];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self).offset(-10);
        make.left.equalTo(self).offset(10);
        make.height.mas_equalTo(1);
    }];
    
    [self.middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.middleView.mas_top);
        make.centerX.equalTo(self.mas_centerX);
    }];
    [self.stepNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dateLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.mas_centerX);
    }];
    [self.completenessLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stepNumberLabel.mas_bottom).offset(20);
        make.centerX.equalTo(self.mas_centerX);
    }];
    [self.targetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.completenessLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.middleView.mas_bottom);
    }];
}

#pragma mark - 主题
- (void)theme {
    _topLineView.theme_backgroundColor = _bottomLineView.theme_backgroundColor = [UIColor theme_colorForKey:@"separator_color" from:@"health"];
    _targetLabel.theme_textColor = _dateLabel.theme_textColor = [UIColor theme_colorForKey:@"light_textColor" from:@"health"];
    _completenessLabel.theme_textColor = [UIColor theme_colorForKey:@"dark_textColor" from:@"health"];
    _targetLabel.font = [UIFont systemFontOfSize:14];
    _dateLabel.font = [UIFont systemFontOfSize:15];
    _completenessLabel.font = [UIFont systemFontOfSize:16];
    _dateLabel.textAlignment = _targetLabel.textAlignment = _completenessLabel.textAlignment = _stepNumberLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - 赋值 目前写死数据
- (void)sportsInfoChartValues {
    _dateLabel.text = [JFLanguageManager stringWithKey:@"today" table:Table_HealthComps comment:@"今日"];
    _completenessLabel.text = [NSString stringWithFormat:@"%@ %@%%", [JFLanguageManager stringWithKey:@"completed" table:Table_HealthComps comment:@"已完成"], @"75"];
    _targetLabel.text = [NSString stringWithFormat:@"%@ %@", [JFLanguageManager stringWithKey:@"target" table:Table_HealthComps comment:@"目标"], @"11946"];
    
    NSString *bushu = [NSString stringWithFormat:@"%@ %@", @"8960", [JFLanguageManager stringWithKey:@"step" table:Table_HealthComps comment:@"步"]];
    NSMutableAttributedString *attributedString = [self stepNumberAttributeString:bushu];
    _stepNumberLabel.attributedText = attributedString;
}

#pragma mark - 布局 圆环
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 底色圆环
    if (!_backBezierPath) {
        _backBezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(CGRectGetWidth(self.bounds) / 2 - CGRectGetHeight(self.bounds) / 2 + kLineWidth, kLineWidth, CGRectGetHeight(self.bounds) - kLineWidth * 2, CGRectGetHeight(self.bounds) - kLineWidth * 2) cornerRadius:(CGRectGetHeight(self.bounds) - kLineWidth * 2) / 2];
        self.backCircularLayer.path = _backBezierPath.CGPath;
    }
    
    // 动态圆环
    self.polychromeDynamicRingLayer.frame = self.layer.bounds;
    self.gradientLayer.frame = CGRectMake(CGRectGetWidth(self.bounds) / 2 - CGRectGetHeight(self.bounds) / 2, 0, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
    self.polychromeDynamicRingLayer.mask = self.dynamicCircularLayer;
    // 动态圆环动画
    if (self.displayLink.paused) {
        self.displayLink.paused = NO;
    }
}

#pragma mark - 动态圆环动画
- (void)changeDynamicCircular:(CADisplayLink *)sender {
//    2 * M_PI * 0.8
    _circularFloat += M_PI / 180;
    UIBezierPath *progressBezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) radius:(CGRectGetHeight(self.bounds) - kLineWidth * 2) / 2 startAngle:M_PI * 3 / 2 endAngle:_circularFloat clockwise:YES];
    self.dynamicCircularLayer.path = progressBezierPath.CGPath;
    if (_circularFloat >= M_PI) {
        _displayLink.paused = YES;
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

#pragma mark - 赋值步数富文本
- (NSMutableAttributedString *)stepNumberAttributeString:(NSString *)string {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : [UIColor theme_colorForKey:@"light_textColor" from:@"health"]()}];
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:kNumRegular options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *items = [regular matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, attributedString.length)];
    NSValue *value;
    for (NSTextCheckingResult *res in items) {
        value = [NSValue valueWithRange:res.range];
        NSRange range = value.rangeValue;
        
        [attributedString addAttributes:@{NSForegroundColorAttributeName : [UIColor theme_colorForKey:@"yellow_textColor" from:@"health"](), NSFontAttributeName : [UIFont systemFontOfSize:35 weight:0.8f]} range:range];
    }
    return attributedString;
}

#pragma mark - lazy
- (CAShapeLayer *)backCircularLayer {
    if (!_backCircularLayer) {
        _backCircularLayer = [CAShapeLayer layer];
        _backCircularLayer.lineWidth = kLineWidth;
        _backCircularLayer.fillColor = [UIColor clearColor].CGColor;
        _backCircularLayer.strokeColor = [UIColor theme_colorForKey:@"arc_backColor" from:@"health"]().CGColor;
        _backCircularLayer.opacity = 0.5;
        [self.layer addSublayer:_backCircularLayer];
    }
    return _backCircularLayer;
}

- (CALayer *)polychromeDynamicRingLayer {
    if (!_polychromeDynamicRingLayer) {
        _polychromeDynamicRingLayer = [CALayer layer];
        [self.layer addSublayer:_polychromeDynamicRingLayer];
    }
    return _polychromeDynamicRingLayer;
}

- (CAShapeLayer *)dynamicCircularLayer {
    if (!_dynamicCircularLayer) {
        _dynamicCircularLayer = [CAShapeLayer layer];
        _dynamicCircularLayer.lineCap = kCALineCapRound;
        _dynamicCircularLayer.lineWidth = kLineWidth;
        _dynamicCircularLayer.fillColor = [UIColor clearColor].CGColor;
        _dynamicCircularLayer.strokeColor = [UIColor theme_colorForKey:@"arc_backColor" from:@"health"]().CGColor;
        [self.polychromeDynamicRingLayer addSublayer:_dynamicCircularLayer];
    }
    return _dynamicCircularLayer;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.locations = @[@(0.1), @(0.9)];
        _gradientLayer.startPoint = CGPointMake(0, 1);
        _gradientLayer.endPoint = CGPointMake(1, 0);
        // 创建颜色数组
        NSMutableArray *colors = [NSMutableArray array];
        // 如果自定义颜色为空
        CGColorRef lowCGColor = [UIColor theme_colorForKey:@"arc_gradientLowColor" from:@"health"]().CGColor;
        CGColorRef lightCGColor = [UIColor theme_colorForKey:@"arc_gradientLightColor" from:@"health"]().CGColor;
        [colors addObject:(__bridge id _Nonnull)(lowCGColor)];
        [colors addObject:(__bridge id _Nonnull)(lightCGColor)];
        // 给渐变色layer设置颜色
        [_gradientLayer setColors:[NSArray arrayWithArray:colors]];
        [self.polychromeDynamicRingLayer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        [self addSubview:_topLineView];
    }
    return _topLineView;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        [self addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

- (UIView *)middleView {
    if (!_middleView) {
        _middleView = [[UIView alloc] init];
        [self addSubview:_middleView];
    }
    return _middleView;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        [self.middleView addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UILabel *)stepNumberLabel {
    if (!_stepNumberLabel) {
        _stepNumberLabel = [[UILabel alloc] init];
        [self.middleView addSubview:_stepNumberLabel];
    }
    return _stepNumberLabel;
}

- (UILabel *)completenessLabel {
    if (!_completenessLabel) {
        _completenessLabel = [[UILabel alloc] init];
        [self.middleView addSubview:_completenessLabel];
    }
    return _completenessLabel;
}

- (UILabel *)targetLabel {
    if (!_targetLabel) {
        _targetLabel = [[UILabel alloc] init];
        [self.middleView addSubview:_targetLabel];
    }
    return _targetLabel;
}

- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeDynamicCircular:)];
        _displayLink.paused = YES;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

@end
