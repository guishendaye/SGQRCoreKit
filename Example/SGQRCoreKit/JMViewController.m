//
//  JMViewController.m
//  SGQRCoreKit
//
//  Created by ohigod@163.com on 05/17/2022.
//  Copyright (c) 2022 ohigod@163.com. All rights reserved.
//

#import "JMViewController.h"
#import "SGQRCodeManager.h"
#import "GJSecondViewController.h"

@interface JMViewController ()

@end

@implementation JMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *tempBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 50, 300, 100, 60)];
    [tempBtn setTitle:@"扫二维码" forState:UIControlStateNormal];
    [tempBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [tempBtn addTarget:self action:@selector(scanClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tempBtn];
}

- (void)scanClick{
    ///权限检查
    __weak typeof(self) wself = self;
    [[SGQRCodeManager sharedInstance] cameraAuthorizationBlock:^(GJSGAuthorizationStatus status) {
        if (status == GJSGAuthorizationStatusSuccess) {
            [wself.navigationController pushViewController:[GJSecondViewController new] animated:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
