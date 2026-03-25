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

- (NSDictionary *)deviceInfo {
    NSMutableDictionary *deviceInfoDict = [NSMutableDictionary dictionary];
    NSDictionary *systemInfo = [DeviceService getDeviceSystemInfo];
    [deviceInfoDict addEntriesFromDictionary:systemInfo];
    [deviceInfoDict addEntriesFromDictionary:[StorageService getDeviceStorageInfo]];
    [deviceInfoDict addEntriesFromDictionary:[NetworkService getDeviceCommunicationInfo]];
    [deviceInfoDict addEntriesFromDictionary:[TimeService getDevicetimeInfo]];
    deviceInfoDict[@"rooted"] = [BrokenService phoneBrokenStatus] == YES ? @"true" : @"false";
    
    return deviceInfoDict;
}

@end
