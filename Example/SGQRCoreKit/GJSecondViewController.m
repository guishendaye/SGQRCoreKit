//
//  GJSecondViewController.m
//  SGQRCoreKit_Example
//
//  Created by 欧嘉明 on 2022/5/10.
//  Copyright © 2022 ohigod@163.com. All rights reserved.
//

#import "GJSecondViewController.h"
#import "SGQRCodeManager.h"
#import "SGQRCodeUtils.h"
@interface GJSecondViewController ()

@end

@implementation GJSecondViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[SGQRCodeManager sharedInstance] startRunningWithBefore:^{

    } completion:^{

    }];
}

- (void)setupNavigationBar {
    self.navigationItem.title = @"扫一扫";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SGQRCodeManager *manager = [[SGQRCodeManager sharedInstance]initWithScanStyle:GJScanStyleDefault withCornerLoaction:GJCornerLoactionOutside];
    manager.tipStr = @"这里是默认提示文本！！！，懒加载方式";
    [self scanCode];
}

#pragma mark 扫码
- (void)scanCode{
    [[SGQRCodeManager sharedInstance] scanResultBlock:^(NSString * _Nonnull result) {
        if (result.length == 0) {
            NSLog(@"未识别到二维码");
        }else{
            NSLog(@"%@",result);
        }
    } startRunningWithBeforeBlock:^{
//        [MBProgressHUD SG_showMBProgressHUDWithModifyStyleMessage:@"正在加载..." toView:weakSelf.view];
    } completionBlock:^{
//        [MBProgressHUD SG_hideHUDForView:weakSelf.view];
    }];
}

#pragma mark 相册扫码
- (void)rightBarButtonItenAction{
    [[SGQRCodeManager sharedInstance] readWithResultBlock:^(NSString * _Nonnull result) {
        if (result.length == 0) {
            NSLog(@"未识别到二维码");
        }else{
            NSLog(@"%@",result);
        }
    }];
}

- (void)dealloc{
    NSLog(@"TeamViewController - dealloc");
    [[SGQRCodeManager sharedInstance] removeScanningView];
}
@end
