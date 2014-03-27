//
//  LCRecorder.h
//  LCRecorder
//
//  Created by liuyi on 14-3-25.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCRecordHUD.h"

@interface LCRecorder : NSObject

@property (weak, nonatomic) UIView *parentView;

- (BOOL)startRecordWithPath:(NSString *)recordPath;
- (void)stopRecordWithCompletion:(void(^)(BOOL succeed, NSString *recordTime, NSString *recordPath))block;
- (void)deleteRecordWithCompletion:(void(^)(BOOL succeed))block;

@end
