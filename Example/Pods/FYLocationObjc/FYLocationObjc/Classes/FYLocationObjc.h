//
//  FYLocationObjc.h
//  FYLocationObjc_Example
//
//  Created by Computer  on 07/01/26.
//  Copyright © 2026 Computer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/// 位置获取完成回调
/// @param success 是否成功
/// @param coordinate 坐标信息
/// @param needShowAlert 是否需要显示提示框
/// @param authStatus 授权状态
typedef void(^FYLocationCompletionBlock)(BOOL success, CLLocationCoordinate2D coordinate, BOOL needShowAlert, BOOL authStatus) NS_SWIFT_NAME(LocationCompletionBlock);

/// 位置管理类
NS_SWIFT_NAME(LocationManager)
@interface FYLocationObjc : NSObject

/// 获取单例实例
+ (instancetype)sharedManager NS_SWIFT_NAME(shared());

/// 请求位置信息
/// @param required 是否必须获取位置
/// @param completion 完成回调
- (void)requestLocationWithRequired:(BOOL)required
                          completion:(FYLocationCompletionBlock)completion NS_SWIFT_NAME(requestLocation(required:completion:));

@end

NS_ASSUME_NONNULL_END
