//
//  SkilingStorageService.h
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StorageService : NSObject

+ (NSDictionary *)getDeviceStorageInfo NS_SWIFT_NAME(deviceStorageInfo());

// 设备内存管理相关方法
+ (double)getDeviceTotalMemorySize NS_SWIFT_NAME(deviceTotalMemorySize());
+ (double)getDeviceUsedMemorySize NS_SWIFT_NAME(deviceUsedMemorySize());
+ (NSNumber *)getDeviceTotalStorageSize NS_SWIFT_NAME(deviceTotalStorageSize());
+ (NSNumber *)getDeviceAvailableStorageSize NS_SWIFT_NAME(deviceAvailableStorageSize());

// 辅助方法
+ (NSString *)formatStorageSize:(long long)bytes NS_SWIFT_NAME(formatStorageSize(_:));

@end

NS_ASSUME_NONNULL_END
