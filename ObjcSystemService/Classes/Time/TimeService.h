//
//  TimeService.h
//  ObjcSystemService_Example
//
//  Created by Computer  on 25/03/26.
//  Copyright © 2026 crazyLuobo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeService : NSObject
+ (NSDictionary *)getDevicetimeInfo;
// 设备系统运行时间相关方法
+ (NSString *)getDeviceSystemUptime NS_SWIFT_NAME(deviceSystemUptime());
+ (NSString *)getDeviceProcessUptime NS_SWIFT_NAME(deviceProcessUptime());
+ (NSString *)getDeviceBootTime NS_SWIFT_NAME(deviceBootTime());

@end

NS_ASSUME_NONNULL_END
