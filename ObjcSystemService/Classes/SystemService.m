//
//  SystemService.m
//  FYDeviceObjc_Example
//
//  Created by Computer  on 07/01/26.
//  Copyright © 2026 Computer. All rights reserved.
//

#import "SystemService.h"
#import "StorageService.h"
#import "NetworkService.h"
#import "DeviceService.h"
#import "BrokenService.h"
#import "TimeService.h"

@implementation SystemService

- (NSDictionary *)deviceInfoWithOutWifi{
    NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionary];
    NSDictionary *systemInfo = [DeviceService getDeviceSystemInfo];
    [deviceInfoDict addEntriesFromDictionary:systemInfo];
    [deviceInfoDict addEntriesFromDictionary:[StorageService getDeviceStorageInfo]];
    [deviceInfoDict addEntriesFromDictionary:[TimeService getDevicetimeInfo]];
    deviceInfoDict[@"rooted"] = [BrokenService phoneBrokenStatus] == YES ? @"true" : @"false";
    [deviceInfoDict addEntriesFromDictionary:[NetworkService getDeviceCommunicationInfoWithOutWifi]];

    return deviceInfoDict;
}

- (void)deviceInfoWithCompletion:(void(^)(NSDictionary *info))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionary];
        NSDictionary *systemInfo = [DeviceService getDeviceSystemInfo];
        [deviceInfoDict addEntriesFromDictionary:systemInfo];
        [deviceInfoDict addEntriesFromDictionary:[StorageService getDeviceStorageInfo]];
        [deviceInfoDict addEntriesFromDictionary:[TimeService getDevicetimeInfo]];
        deviceInfoDict[@"rooted"] = [BrokenService phoneBrokenStatus] == YES ? @"true" : @"false";

        [NetworkService getDeviceCommunicationInfoWithCompletion:^(NSDictionary *info) {
            [deviceInfoDict addEntriesFromDictionary:info];

            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion([deviceInfoDict copy]);
                }
            });
        }];
    });
}

- (NSDictionary *)deviceInfoWithOutWifiWithUuid:(NSString *)uuid{
    NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionary];
    NSDictionary *systemInfo = [DeviceService getDeviceSystemInfo];
    [deviceInfoDict addEntriesFromDictionary:systemInfo];
    [deviceInfoDict addEntriesFromDictionary:[StorageService getDeviceStorageInfo]];
    [deviceInfoDict addEntriesFromDictionary:[TimeService getDevicetimeInfo]];
    deviceInfoDict[@"rooted"] = [BrokenService phoneBrokenStatus] == YES ? @"true" : @"false";
    [deviceInfoDict addEntriesFromDictionary:[NetworkService getDeviceCommunicationInfoWithOutWifi]];
    deviceInfoDict[@"uuid"] = uuid;
    return deviceInfoDict;
}

- (void)deviceInfoWithUuid:(NSString *)uuid WithCompletion:(void(^)(NSDictionary *info))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionary];
        NSDictionary *systemInfo = [DeviceService getDeviceSystemInfo];
        [deviceInfoDict addEntriesFromDictionary:systemInfo];
        [deviceInfoDict addEntriesFromDictionary:[StorageService getDeviceStorageInfo]];
        [deviceInfoDict addEntriesFromDictionary:[TimeService getDevicetimeInfo]];
        deviceInfoDict[@"rooted"] = [BrokenService phoneBrokenStatus] == YES ? @"true" : @"false";
        deviceInfoDict[@"uuid"] = uuid;
        
        [NetworkService getDeviceCommunicationInfoWithCompletion:^(NSDictionary *info) {
            [deviceInfoDict addEntriesFromDictionary:info];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion([deviceInfoDict copy]);
                }
            });
        }];
    });
}


@end
