//
//  LCRecordHUD.h
//  LCRecorder
//
//  Created by liuyi on 14-3-25.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RecordStatus)
{
    RecordStatusNormal = 0,
    RecordStatusCancel,
    RecordStatusShort
};

#define RECORD_STATUS_NOTIFICATION @"RECORD_STATUS_NOTIFICATION"

@interface LCRecordHUD : UIView

@property (assign, nonatomic) double progress;

@end
