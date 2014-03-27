//
//  LCRecorder.m
//  LCRecorder
//
//  Created by liuyi on 14-3-25.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "LCRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface LCRecorder () <AVAudioRecorderDelegate>

@property (strong, nonatomic) NSString *recordPath;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (assign, nonatomic) float recordedDuration;
@property (strong, nonatomic) LCRecordHUD *recordHUD;
@property (strong, nonatomic) NSTimer *meterTimer;

@end

static NSTimeInterval timeInterval = 0.05;

@implementation LCRecorder

- (BOOL)startRecordWithPath:(NSString *)recordPath
{
    [self shutRecorder:NO];
    
    _recordPath = recordPath;
    NSURL *recordURL = [NSURL fileURLWithPath:recordPath];
    NSDictionary *recordSettings =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSNumber numberWithFloat: 22050],               AVSampleRateKey,
     [NSNumber numberWithInt: kAudioFormatLinearPCM], AVFormatIDKey,
     [NSNumber numberWithInt: 1],                     AVNumberOfChannelsKey,
     [NSNumber numberWithBool:NO],                    AVLinearPCMIsFloatKey,
     [NSNumber numberWithInt: AVAudioQualityMax],     AVEncoderAudioQualityKey,
     nil];
    NSError *error = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:recordURL settings:recordSettings error:&error];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    if ([_recorder prepareToRecord]) {
        _recordedDuration = 0.0;
        [_recorder recordForDuration:NSTimeIntervalSince1970];
        
        _recordHUD = [[LCRecordHUD alloc] initWithFrame:_parentView.bounds];
        [_parentView addSubview:_recordHUD];
        
        _meterTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                       target:self
                                                     selector:@selector(updateMeter)
                                                     userInfo:nil
                                                      repeats:YES];
        return YES;
    }
    return NO;
}

- (void)stopRecordWithCompletion:(void(^)(BOOL succeed, NSString *recordTime, NSString *recordPath))block
{
    if (_recorder && _recorder.isRecording) {
        _recordedDuration = _recorder.currentTime;
        if (_recordedDuration >= 3.0f) {
            NSString *recordTime = [self convertTimeIntervalToStandardFormat:_recordedDuration];
            [_recorder stop];
            [self shutRecorder:NO];
            return block(YES, recordTime, _recordPath);
        }
        else {
            RecordStatus status = RecordStatusShort;
            [[NSNotificationCenter defaultCenter] postNotificationName:RECORD_STATUS_NOTIFICATION object:@(status)];
            [self shutRecorder:YES];
            return block(NO, nil, nil);
        }
    }
    else return block(NO, nil, nil);
}

- (void)deleteRecordWithCompletion:(void(^)(BOOL succeed))block
{
    if (_recorder) {
        if (_recorder.isRecording) {
            [_recorder stop];
        }
        block([_recorder deleteRecording]);
        [self shutRecorder:NO];
    }
}

- (void)shutRecorder:(BOOL)isShortRecord
{
    if (_recordHUD) {
        [UIView animateWithDuration:0.3 delay:(isShortRecord ? 0.6 : 0) options:UIViewAnimationOptionLayoutSubviews animations:^{
            _recordHUD.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_recordHUD removeFromSuperview];
            _recordHUD = nil;
        }];
    }
    
    if (_meterTimer) {
        [_meterTimer invalidate];
        _meterTimer = nil;
    }
    
    if(_recorder){
        if (_recorder.isRecording) {
            [_recorder stop];
        }
        _recorder = nil;
    }
}

- (void)updateMeter
{
    if (_recordHUD && _recorder) {
        [_recorder updateMeters];
        float peakPower = [_recorder averagePowerForChannel:0];
        double ALPHA = 0.05;
        double peakPowerForChannel = pow(10, (ALPHA * peakPower));
        
        [_recordHUD setProgress:peakPowerForChannel];
    }
}

- (NSString *)convertTimeIntervalToStandardFormat:(double)currentTime
{
    NSString *result = @"";
    uint currentDuring = (uint)currentTime;
    uint hour = currentDuring/3600;
    currentDuring = currentDuring%3600;
    uint min = currentDuring/60;
    currentDuring = currentDuring%60;
    uint sec = currentDuring;
    if (hour) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%@%d:", (hour < 10 ? @"0" : @""), hour]];
    }
    else {
        result = [result stringByAppendingString:@"00:"];
    }
    
    if (min) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%@%d:", (min < 10 ? @"0" : @""), min]];
    }
    else {
        result = [result stringByAppendingString:@"00:"];
    }
    
    if (sec) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@"%@%d", (sec < 10 ? @"0" : @""), sec]];
    }
    return result;
}

@end
