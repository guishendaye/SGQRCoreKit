//
//  SGQRCodeManager.m
//  SGQRCodeExample
//
//  Created by 欧嘉明 on 2022/4/25.
//  Copyright © 2022 Sorgle. All rights reserved.
//


#import "SGQRCodeManager.h"
#import "SGQRCodeUtils.h"
#import "SGQRCode.h"

static SGQRCodeManager *manager = nil;
static dispatch_once_t once;
@interface SGQRCodeManager()
@property (nonatomic, strong)SGScanCode *scanCode;
///扫描View 宽度为0.7 * 屏宽
@property (nonatomic, strong) SGScanView *scanView;
@property (nonatomic, assign) BOOL stop;
@property (nonatomic, weak) UIViewController *currentVC;
@property (nonatomic, assign) ScanStyle scanStyle;
@property (nonatomic, assign) CornerLoaction cornerLoaction;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, strong) SGAuthorization *authorization;
@end

@implementation SGQRCodeManager

+ (SGQRCodeManager*)sharedInstance{
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.authorizationRemindBool = YES;
    }
    return self;
}

- (instancetype)initWithScanStyle:(GJScanStyle)scanStyle withCornerLoaction:(GJCornerLoaction)cornerLoaction{
    __weak typeof(self) weakSelf = self;
    weakSelf.scanStyle = (ScanStyle)scanStyle;
    weakSelf.cornerLoaction = (CornerLoaction)cornerLoaction;
    weakSelf.currentVC.view.backgroundColor = [UIColor blackColor];
    _scanCode = [SGScanCode scanCode];
    [weakSelf.currentVC.view addSubview:weakSelf.scanView];
    [weakSelf.scanView startScanning];
    return self;
}

#pragma mark 开始扫描
- (void)startRunningWithBefore:(void (^)(void))before completion:(void (^)(void))completion{
    if (_stop) {
        [_scanCode startRunningWithBefore:before completion:completion];
    }
}

#pragma mark 停止扫描
- (void)stopScanning{
    __weak typeof(self) weakSelf = self;
    [weakSelf.scanView stopScanning];
}

#pragma mark 扫描回调
- (void)scanResultBlock:(void(^)(NSString *result))block startRunningWithBeforeBlock:(void(^)(void))startRunningWithBefore completionBlock:(void(^)(void))completionBlock{
    __weak typeof(self) weakSelf = self;
    [weakSelf.scanCode scanWithController:weakSelf.currentVC resultBlock:^(SGScanCode *scanCode, NSString *result) {
        if (result) {
            [scanCode stopRunning];
            weakSelf.stop = YES;
            [scanCode playSoundName:@"SGQRCode.bundle/scanEndSound.caf"];
            if (block) {
                block(result);
            }
        }
    }];
    [weakSelf.scanCode startRunningWithBefore:^{
        if (startRunningWithBefore) {
            startRunningWithBefore();
        }
    } completion:^{
        if (completionBlock) {
            completionBlock();
        }
    }];
}

#pragma mark 相册图片扫描回调
- (void)readWithResultBlock:(void(^)(NSString *result))block{
    [_scanCode readWithResultBlock:^(SGScanCode *scanCode, NSString *result) {
        if (result == nil) {
            if (block) {
                block(nil);
            }
        } else {
            if (block) {
                block(result);
            }
        }
    }];
}

#pragma mark 扫描线停止扫描并移除视图
- (void)removeScanningView {
    __weak typeof(self) weakSelf = self;
    [weakSelf.scanView stopScanning];
    [weakSelf.scanView removeFromSuperview];
    weakSelf.scanView = nil;
}

#pragma mark 捕获外界光线亮度
- (void)setBrightness:(BOOL)brightness{
    _brightness = brightness;
    _scanCode.brightness = YES;
}

#pragma mark 捕获外界光线强弱回调方法
- (void)scanWithBrightnessBlock:(void(^)(float brightness))block{
    [_scanCode scanWithBrightnessBlock:^(SGScanCode *scanCode, CGFloat brightness) {
        if (block) {
            block(brightness);
        }
    }];
}

#pragma mark 相机授权回调方法
- (void)cameraAuthorizationBlock:(void(^)(GJSGAuthorizationStatus status))block{
    __weak typeof(self) weakSelf = self;
    [weakSelf.authorization AVAuthorizationBlock:^(SGAuthorization * _Nonnull authorization, SGAuthorizationStatus status) {
        if (block) {
            block((GJSGAuthorizationStatus)status);
        }
        ///是否打开默认权限禁止弹窗
        if (!weakSelf.authorizationRemindBool) {
            return;
        }
        if (status == SGAuthorizationStatusFail) {
            
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未允许相机权限，是否去打开权限" preferredStyle:(UIAlertControllerStyleAlert)];
            [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication]canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
            }]];
            [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.currentVC presentViewController:alertC animated:YES completion:nil];
            });
        } else if(status == SGAuthorizationStatusUnknown){
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:alertA];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.currentVC presentViewController:alertC animated:YES completion:nil];
            });
        }
    }];
}

#pragma mark 相册授权回调方法
- (void)albumAuthorizationBlock:(void(^)(GJSGAuthorizationStatus status))block{
    __weak typeof(self) weakSelf = self;
    [weakSelf.authorization PHAuthorizationBlock:^(SGAuthorization * _Nonnull authorization, SGAuthorizationStatus status) {
        if (block) {
            block((GJSGAuthorizationStatus)status);
        }
        ///是否打开默认权限禁止弹窗
        if (!weakSelf.authorizationRemindBool) {
            return;
        }
        if (status == SGAuthorizationStatusFail) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未允许相册权限，是否去打开权限" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication]canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
            }];
            [alertC addAction:alertA];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.currentVC presentViewController:alertC animated:YES completion:nil];
            });
        } else if(status == SGAuthorizationStatusUnknown){
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"由于系统原因, 无法访问相册" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertC addAction:alertA];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.currentVC presentViewController:alertC animated:YES completion:nil];
            });
        }
    }];
}

#pragma mark 提示文本
- (void)setTipStr:(NSString *)tipStr{
    __weak typeof(self) weakSelf = self;
    _tipStr = tipStr;
    weakSelf.promptLabel.text = tipStr;
    [weakSelf.currentVC.view addSubview:weakSelf.promptLabel];
}

#pragma mark lazy
- (SGScanView *)scanView {
    if (!_scanView) {
        __weak typeof(self) weakSelf = self;
        _scanView = [[SGScanView alloc] initWithFrame:CGRectMake(0, 0, weakSelf.currentVC.view.frame.size.width, weakSelf.currentVC.view.frame.size.height)];
        _scanView.scanLineName = @"SGQRCode.bundle/scanLineGrid";
        _scanView.scanStyle = weakSelf.scanStyle;
        _scanView.cornerLocation = weakSelf.cornerLoaction;
        _scanView.cornerColor = [UIColor clearColor];
    }
    return _scanView;
}

#pragma mark 提示文本
- (UILabel *)promptLabel {
    if (!_promptLabel) {
        __weak typeof(self) weakSelf = self;
        _promptLabel = [[UILabel alloc] init];
        _promptLabel.backgroundColor = [UIColor clearColor];
        CGFloat promptLabelX = 0;
        CGFloat promptLabelY = (weakSelf.currentVC.view.frame.size.height + 0.7 * weakSelf.currentVC.view.frame.size.width) * 0.5 + 25;
        CGFloat promptLabelW = weakSelf.currentVC.view.frame.size.width;
        CGFloat promptLabelH = 25;
        _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    }
    return _promptLabel;
}

- (UIViewController *)currentVC{
    if (!_currentVC) {
        _currentVC = [SGQRCodeUtils getCurrentVC];
    }
    return _currentVC;
}

#pragma mark 权限
- (SGAuthorization *)authorization{
    if (!_authorization) {
        _authorization = [SGAuthorization authorization];
        _authorization.openLog = YES;
    }
    return _authorization;
}
@end
