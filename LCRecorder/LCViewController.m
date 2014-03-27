//
//  LCViewController.m
//  LCRecorder
//
//  Created by liuyi on 14-3-25.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "LCViewController.h"
#import "LCRecorder.h"

@interface LCViewController ()
{
    LCRecorder *recorder;
}
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

@end

@implementation LCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    recorder = [[LCRecorder alloc] init];
    recorder.parentView = self.view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)startRecord:(id)sender
{
    NSString *path = [self filePath];
    [recorder startRecordWithPath:path];
    _recordBtn.highlighted = YES;
}

- (IBAction)stopRecord:(id)sender
{
    [recorder stopRecordWithCompletion:^(BOOL succeed, NSString *recordTime, NSString *recordPath) {
        if (succeed) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:recordTime message:recordPath delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    _recordBtn.highlighted = NO;
}

- (IBAction)cancelRecord:(id)sender
{
    [recorder deleteRecordWithCompletion:^(BOOL succeed) {
        if (succeed) {
            NSLog(@"cancel record success!");
        }
    }];
    _recordBtn.highlighted = NO;
}

- (IBAction)prepareForCancel:(id)sender
{
    RecordStatus status = RecordStatusCancel;
    [[NSNotificationCenter defaultCenter] postNotificationName:RECORD_STATUS_NOTIFICATION object:@(status)];
    _recordBtn.highlighted = YES;
}

- (IBAction)reverseToRecord:(id)sender
{
    RecordStatus status = RecordStatusNormal;
    [[NSNotificationCenter defaultCenter] postNotificationName:RECORD_STATUS_NOTIFICATION object:@(status)];
    _recordBtn.highlighted = YES;
}


//- (IBAction)handleGesture:(id)sender {
//    UIPanGestureRecognizer *panGestureRecognizer = sender;
//    switch (panGestureRecognizer.state) {
//        case UIGestureRecognizerStateBegan:
//        {
//            [self startRecord];
//            _recordBtn.highlighted = YES;
//        }
//            break;
//        case UIGestureRecognizerStateChanged:
//        {
//            CGPoint gestureLocation = [panGestureRecognizer locationInView:_recordBtn];
//            if (gestureLocation.y+20 < 0) {
//                RecordStatus status = RecordStatusCancel;
//                [[NSNotificationCenter defaultCenter] postNotificationName:RECORD_STATUS_NOTIFICATION object:@(status)];
//            }
//            else {
//                RecordStatus status = RecordStatusNormal;
//                [[NSNotificationCenter defaultCenter] postNotificationName:RECORD_STATUS_NOTIFICATION object:@(status)];
//            }
//        }
//            break;
//        case UIGestureRecognizerStateEnded:
//        {
//            CGPoint gestureLocation = [panGestureRecognizer locationInView:_recordBtn];
//            if (gestureLocation.y+20 < 0) {
//                [self cancelRecord];
//            }
//            else {
//                [self stopRecord];
//            }
//            _recordBtn.highlighted = NO;
//        }
//            break;
//            
//        default:
//            break;
//    }
//}

- (NSString *)filePath
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"test.caf"];
    return filePath;
}

@end
