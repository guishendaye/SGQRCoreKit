//
//  SGQRCodeManager.h
//  SGQRCodeExample
//
//  Created by 欧嘉明 on 2022/4/25.
//  Copyright © 2022 Sorgle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    /// 授权成功（第一次授权允许及已授权）
    GJSGAuthorizationStatusSuccess,
    /// 授权失败（已拒绝）
    GJSGAuthorizationStatusFail,
    /// 未知（受限制）
    GJSGAuthorizationStatusUnknown,
} GJSGAuthorizationStatus;

typedef enum : NSUInteger {
    /// 默认与边框线同中心点
    GJCornerLoactionDefault,
    /// 在边框线内部
    GJCornerLoactionInside,
    /// 在边框线外部
    GJCornerLoactionOutside
} GJCornerLoaction;

typedef enum : NSUInteger {
    /// 单线扫描样式
    GJScanStyleDefault,
    /// 网格扫描样式
    GJScanStyleGrid
} GJScanStyle;

NS_ASSUME_NONNULL_BEGIN

@interface SGQRCodeManager : NSObject

///下方提示文本
@property (nonatomic, copy) NSString *tipStr;

+ (SGQRCodeManager*)sharedInstance;

///初始化
- (instancetype)initWithScanStyle:(GJScanStyle)scanStyle withCornerLoaction:(GJCornerLoaction)cornerLoaction;

///开始扫描 before/completion可以传nil 这个一般放在viewWillAppear
- (void)startRunningWithBefore:(void (^)(void))before completion:(void (^)(void))completion;

///停止扫描
- (void)stopScanning;

///扫描回调 startRunningWithBefore里面加提示
- (void)scanResultBlock:(void(^)(NSString *result))block startRunningWithBeforeBlock:(void(^)(void))startRunningWithBefore completionBlock:(void(^)(void))completionBlock;

///相册图片扫描回调 返回nil为未识别二维码
- (void)readWithResultBlock:(void(^)(NSString *result))block;

///扫描线停止扫描并移除视图 放在dealloc调用
- (void)removeScanningView;

///捕获外界光线亮度，默认为：NO
@property (nonatomic, assign) BOOL brightness;
///扫码时，捕获外界光线强弱回调方法（brightness = YES 时，此回调方法才有效 brightness < - 1显示电筒按钮，否则隐藏
- (void)scanWithBrightnessBlock:(void(^)(float brightness))block;

///默认为YES 设置为NO隐藏默认权限弹窗
@property (nonatomic, assign) BOOL authorizationRemindBool;

///相机授权回调方法
- (void)cameraAuthorizationBlock:(void(^)(GJSGAuthorizationStatus status))block;

///相册授权回调方法
- (void)albumAuthorizationBlock:(void(^)(GJSGAuthorizationStatus status))block;

@end

NS_ASSUME_NONNULL_END
