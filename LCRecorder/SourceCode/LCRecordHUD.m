//
//  LCRecordHUD.m
//  LCRecorder
//
//  Created by liuyi on 14-3-25.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "LCRecordHUD.h"
#import <tgmath.h>

@interface LCRecordHUD ()

@property (strong, nonatomic) UIImageView *micImg;
@property (strong, nonatomic) UIImageView *signalImg;
@property (strong, nonatomic) UIImageView *cancelImg;
@property (strong, nonatomic) UILabel *msgLabel;

@end

static CGFloat HUDWidth  = 150.0f;
static CGFloat HUDHeight = 150.0f;

static CGFloat gap = 10.0f;
static CGFloat labelHeight = 20.0f;

@implementation LCRecordHUD

- (id)initWithFrame:(CGRect)frame
{
    CGRect HUDFrame = CGRectMake((CGRectGetWidth(frame)-HUDWidth)/2, (CGRectGetHeight(frame)-HUDHeight)/2, HUDWidth, HUDHeight);
    self = [super initWithFrame:HUDFrame];
    if (self) {
        [self setupUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHUD:) name:RECORD_STATUS_NOTIFICATION object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECORD_STATUS_NOTIFICATION object:nil];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    
    //Gradient colours
    size_t gradLocationsNum = 2;
    CGFloat gradLocations[2] = {0.0f, 1.0f};
    CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
    CGColorSpaceRelease(colorSpace);
    //Gradient center
    CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    //Gradient radius
    float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    //Gradient draw
    CGContextDrawRadialGradient (context, gradient, gradCenter,
                                 0, gradCenter, gradRadius,
                                 kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    
    // Set background rect color
    CGContextSetGrayFillColor(context, 0.0f, 0.8f);
    
	// Draw rounded HUD backgroud rect
    
	float radius = 10.0f;
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
	CGContextFillPath(context);
    
	UIGraphicsPopContext();
}

- (void)setupUI
{
    _msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, HUDHeight-labelHeight-gap, HUDWidth, labelHeight)];
    [_msgLabel setBackgroundColor:[UIColor clearColor]];
    [_msgLabel setFont:[UIFont systemFontOfSize:13.0f]];
    [_msgLabel setTextColor:[UIColor whiteColor]];
    [_msgLabel setTextAlignment:NSTextAlignmentCenter];
    _msgLabel.text = @"手指上滑，取消发送";
    [self addSubview:_msgLabel];
    
    _micImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordingBkg"]];
    [_micImg sizeToFit];
    _signalImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordingSignal001"]];
    [_signalImg sizeToFit];
    
    _micImg.frame = CGRectMake((HUDWidth-CGRectGetWidth(_micImg.frame)-CGRectGetWidth(_signalImg.frame))/2, (CGRectGetMinY(_msgLabel.frame)-CGRectGetHeight(_micImg.frame))/2, CGRectGetWidth(_micImg.frame), CGRectGetHeight(_micImg.frame));
    [self addSubview:_micImg];
    
    NSLog(@"%@", NSStringFromCGRect(_micImg.frame));
    _signalImg.frame = CGRectMake(CGRectGetMaxX(_micImg.frame), CGRectGetMaxY(_micImg.frame)-CGRectGetHeight(_signalImg.frame)-11.0f, CGRectGetWidth(_signalImg.frame), CGRectGetHeight(_signalImg.frame));
    NSLog(@"%@", NSStringFromCGRect(_signalImg.frame));
    [self addSubview:_signalImg];
    
    _cancelImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100.0f, 100.0f)];
    [_cancelImg setImage:[UIImage imageNamed:@"RecordCancel@2x"]];
    _cancelImg.frame = CGRectMake((HUDWidth-CGRectGetWidth(_cancelImg.frame))/2, (CGRectGetMinY(_msgLabel.frame)-CGRectGetHeight(_cancelImg.frame))/2, CGRectGetWidth(_cancelImg.frame), CGRectGetHeight(_cancelImg.frame));
    [self addSubview:_cancelImg];
    _cancelImg.hidden = YES;
}

- (void)setProgress:(double)progress
{
    CGFloat unit = 0.125f;
    
    if (!_signalImg.hidden) {
        if (0<progress<=unit) {
            [_signalImg setImage:[UIImage imageNamed:@"RecordingSignal001"]];
        }else if (unit<progress<=unit*2) {
            [_signalImg setImage:[UIImage imageNamed:@"RecordingSignal002"]];
        }else if (unit*2<progress<=unit*3) {
            [_signalImg setImage:[UIImage imageNamed:@"RecordingSignal003"]];
        }else if (unit*3<progress<=unit*4) {
            [_signalImg setImage:[UIImage imageNamed:@"RecordingSignal004"]];
        }else if (unit*4<progress<=unit*5) {
            [_signalImg setImage:[UIImage imageNamed:@"RecordingSignal005"]];
        }else if (unit*5<progress<=unit*6) {
            [_signalImg setImage:[UIImage imageNamed:@"RecordingSignal006"]];
        }else if (unit*6<progress<=unit*7) {
            [_signalImg setImage:[UIImage imageNamed:@"RecordingSignal007"]];
        }else {
            [_signalImg setImage:[UIImage imageNamed:@"RecordingSignal008"]];
        }
        [_signalImg layoutIfNeeded];
        _progress = progress;
    }
}

- (void)updateHUD:(NSNotification *)notification
{
    RecordStatus status = [notification.object unsignedIntegerValue];
    
    switch (status) {
        case RecordStatusNormal:
        {
            _cancelImg.hidden = YES;
            _micImg.hidden = NO;
            _signalImg.hidden = NO;
            _msgLabel.text = @"手指上滑，取消发送";
        }
            break;
        case RecordStatusCancel:
        {
            [_cancelImg setImage:[UIImage imageNamed:@"RecordCancel"]];
            _cancelImg.hidden = NO;
            _micImg.hidden = YES;
            _signalImg.hidden = YES;
            _msgLabel.text = @"松开手指，取消发送";
        }
            break;
            
        default:
        {
            [_cancelImg setImage:[UIImage imageNamed:@"MessageTooShort"]];
            _cancelImg.hidden = NO;
            _micImg.hidden = YES;
            _signalImg.hidden = YES;
            _msgLabel.text = @"说话时间太短";
        }
            break;
    }
}

@end
