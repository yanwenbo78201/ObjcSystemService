//
//  DeviceService.m
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import "DeviceService.h"
#import <sys/utsname.h>
#include <sys/sysctl.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/ASIdentifierManager.h>

@implementation DeviceService
+ (NSDictionary *)getDeviceSystemInfo{
   
    NSMutableDictionary *systemInfo = [NSMutableDictionary dictionary];
    systemInfo[@"idfa"] = [DeviceService getDeviceAdvertisingIdentifier];
    systemInfo[@"idfv"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    systemInfo[@"phoneMark"] = [[UIDevice currentDevice] name];
    systemInfo[@"phoneType"] = [DeviceService getDeviceType];
    systemInfo[@"systemVersions"] = [DeviceService getDeviceSystemVersion];
    systemInfo[@"versionCode"] = [DeviceService getDeviceAppVersion];
    systemInfo[@"screenResolution"] = [DeviceService getDeviceScreenResolution];
    systemInfo[@"batteryLevel"] = [DeviceService getDeviceBatteryLevel];
    
    systemInfo[@"charged"] = [DeviceService getDeviceBatteryChargingStatus];
    systemInfo[@"defaultLanguage"] = [DeviceService getDeviceDefaultLanguage];
    systemInfo[@"defaultTimeZone"] = [DeviceService getDeviceDefaultTimeZone];
    systemInfo[@"screenWidth"] = [NSString stringWithFormat:@"%d",(int)[UIScreen mainScreen].bounds.size.width];
    systemInfo[@"screenHeight"] = [NSString stringWithFormat:@"%d",(int)[UIScreen mainScreen].bounds.size.height];
    systemInfo[@"cpuNum"] = [DeviceService getDeviceCPUCount];
    systemInfo[@"simulated"] = [DeviceService isDeviceSimulator];
    systemInfo[@"debugged"] = [DeviceService isDeviceAttachedDebugger] == YES ? @"true" : @"false";
    systemInfo[@"screenBrightness"] = [DeviceService getDeviceScreenBrightness];
    return systemInfo;
}



+ (NSNumber *)getDeviceTypeNumber{
    NSNumber *deviceTypeNumber = @0;
   
    NSString *detailDeviceType = [self getDeviceType];
    if ([detailDeviceType hasPrefix:@"iPhone"])
        deviceTypeNumber = @3;
    else if ([detailDeviceType hasPrefix:@"iPad"])
        deviceTypeNumber = @2;
    else if ([detailDeviceType hasPrefix:@"iMac"] || [detailDeviceType hasPrefix:@"Mac"])
        deviceTypeNumber = @1;

    return deviceTypeNumber;
}

+ (NSString *)getDeviceTypeString{
    NSString *deviceTypeString = @"unknown";
    NSString *detailDeviceType = [self getDeviceType];
    if ([detailDeviceType hasPrefix:@"iPhone"])
        deviceTypeString = @"Mobile";
    else if ([detailDeviceType hasPrefix:@"iPad"])
        deviceTypeString = @"Tablet";
    else if ([detailDeviceType hasPrefix:@"iMac"] || [detailDeviceType hasPrefix:@"Mac"])
        deviceTypeString = @"pc";
    return deviceTypeString;
}

+ (NSString *)getDeviceType{
    NSString *deviceType = [self getRawDeviceType];
    return [self getDeviceNameFromType:deviceType];
}

#pragma mark - Private Helper Methods

+ (NSString *)calculateScreenResolution{
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenResolutionWidth = screenBounds.size.width * screenScale;
    CGFloat screenResolutionHeight = screenBounds.size.height * screenScale;
    return [NSString stringWithFormat:@"%d-%d",(int)screenResolutionWidth,(int)screenResolutionHeight];
}

+ (BOOL)checkDebuggerAttachment{
    @try {
        int attachedRet;
        int attachedMibs[4];
        struct kinfo_proc info;
        size_t size;
        info.kp_proc.p_flag = 0;
        attachedMibs[0] = CTL_KERN;
        attachedMibs[1] = KERN_PROC;
        attachedMibs[2] = KERN_PROC_PID;
        attachedMibs[3] = getpid();
        size = sizeof(info);
        attachedRet = sysctl(attachedMibs, sizeof(attachedMibs) / sizeof(*attachedMibs), &info, &size, NULL, 0);
        if (attachedRet) {
            return attachedRet;
        }
        return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
    }
    @catch (NSException *exception) {
        return NO;
    }
}

+ (NSString *)getAdvertisingIdentifier{
    __block NSString *advertisingIdentifier = @"";
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                advertisingIdentifier = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            }
        }];
    } else {
        advertisingIdentifier = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    }
    return advertisingIdentifier;
}

+ (NSString *)getRawDeviceType{
    struct utsname dtname;
    uname(&dtname);
    return [NSString stringWithFormat:@"%s", dtname.machine];
}

+ (NSString *)getDeviceNameFromType:(NSString *)deviceType{
    // Simulator devices
    if ([self isSimulatorDevice:deviceType]) {
        return [self getSimulatorDeviceName:deviceType];
    }
    
    // iPhone devices
    if ([self isiPhoneDevice:deviceType]) {
        return [self getiPhoneDeviceName:deviceType];
    }
    
    // iPad devices  
    if ([self isiPadDevice:deviceType]) {
        return [self getiPadDeviceName:deviceType];
    }
    
    // iPod devices
    if ([self isiPodDevice:deviceType]) {
        return [self getiPodDeviceName:deviceType];
    }
    
    // Apple TV devices
    if ([self isAppleTVDevice:deviceType]) {
        return [self getAppleTVDeviceName:deviceType];
    }
    
    // Default fallback
    return deviceType;
}

+ (BOOL)isSimulatorDevice:(NSString *)deviceType {
    return [deviceType isEqualToString:@"i386"] || [deviceType isEqualToString:@"x86_64"] || [deviceType isEqualToString:@"arm64"];
}

+ (BOOL)isiPhoneDevice:(NSString *)deviceType {
    return [deviceType hasPrefix:@"iPhone"];
}

+ (BOOL)isiPadDevice:(NSString *)deviceType {
    return [deviceType hasPrefix:@"iPad"];
}

+ (BOOL)isiPodDevice:(NSString *)deviceType {
    return [deviceType hasPrefix:@"iPod"];
}

+ (BOOL)isAppleTVDevice:(NSString *)deviceType {
    return [deviceType hasPrefix:@"AppleTV"];
}

+ (NSString *)getSimulatorDeviceName:(NSString *)deviceType {
    return @"iPhone Simulator";
}

+ (NSString *)getiPhoneDeviceName:(NSString *)deviceType {
    NSDictionary *iPhoneModels = [self getiPhoneModelDictionary];
    NSString *modelName = iPhoneModels[deviceType];
    return modelName ?: deviceType;
}

+ (NSString *)getiPadDeviceName:(NSString *)deviceType {
    NSDictionary *iPadModels = [self getiPadModelDictionary];
    NSString *modelName = iPadModels[deviceType];
    return modelName ?: deviceType;
}

+ (NSString *)getiPodDeviceName:(NSString *)deviceType {
    NSDictionary *iPodModels = [self getiPodModelDictionary];
    NSString *modelName = iPodModels[deviceType];
    return modelName ?: deviceType;
}

+ (NSString *)getAppleTVDeviceName:(NSString *)deviceType {
    NSDictionary *appleTVModels = [self getAppleTVModelDictionary];
    NSString *modelName = appleTVModels[deviceType];
    return modelName ?: deviceType;
}

+ (NSDictionary *)getiPhoneModelDictionary {
    return @{
        @"iPhone1,1": @"iPhone",
            @"iPhone1,2": @"iPhone 3G",
            @"iPhone2,1": @"iPhone 3GS",
            @"iPhone3,1": @"iPhone 4",
            @"iPhone3,2": @"iPhone 4",
            @"iPhone3,3": @"iPhone 4",
            @"iPhone4,1": @"iPhone 4S",
            @"iPhone5,1": @"iPhone 5",
            @"iPhone5,2": @"iPhone 5",
            @"iPhone5,3": @"iPhone 5c",
            @"iPhone5,4": @"iPhone 5c",
            @"iPhone6,1": @"iPhone 5s",
            @"iPhone6,2": @"iPhone 5s",
            @"iPhone7,1": @"iPhone 6 Plus",
            @"iPhone7,2": @"iPhone 6",
            @"iPhone8,1": @"iPhone 6s",
            @"iPhone8,2": @"iPhone 6s Plus",
            @"iPhone8,4": @"iPhone SE (1st generation)",
            @"iPhone9,1": @"iPhone 7",
            @"iPhone9,2": @"iPhone 7 Plus",
            @"iPhone9,3": @"iPhone 7",
            @"iPhone9,4": @"iPhone 7 Plus",
            @"iPhone10,1": @"iPhone 8",
            @"iPhone10,2": @"iPhone 8 Plus",
            @"iPhone10,3": @"iPhone X",
            @"iPhone10,4": @"iPhone 8",
            @"iPhone10,5": @"iPhone 8 Plus",
            @"iPhone10,6": @"iPhone X",
            @"iPhone11,2": @"iPhone XS",
            @"iPhone11,4": @"iPhone XS Max",
            @"iPhone11,6": @"iPhone XS Max",
            @"iPhone11,8": @"iPhone XR",
            @"iPhone12,1": @"iPhone 11",
            @"iPhone12,3": @"iPhone 11 Pro",
            @"iPhone12,5": @"iPhone 11 Pro Max",
            @"iPhone12,8": @"iPhone SE (2nd generation)",
            @"iPhone13,1": @"iPhone 12 mini",
            @"iPhone13,2": @"iPhone 12",
            @"iPhone13,3": @"iPhone 12 Pro",
            @"iPhone13,4": @"iPhone 12 Pro Max",
            @"iPhone14,2": @"iPhone 13 Pro",
            @"iPhone14,3": @"iPhone 13 Pro Max",
            @"iPhone14,4": @"iPhone 13 mini",
            @"iPhone14,5": @"iPhone 13",
            @"iPhone14,6": @"iPhone SE (3rd generation)",
            @"iPhone14,7": @"iPhone 14",
            @"iPhone14,8": @"iPhone 14 Plus",
            @"iPhone15,2": @"iPhone 14 Pro",
            @"iPhone15,3": @"iPhone 14 Pro Max",
            @"iPhone15,4": @"iPhone 15",
            @"iPhone15,5": @"iPhone 15 Plus",
            @"iPhone16,1": @"iPhone 15 Pro",
            @"iPhone16,2": @"iPhone 15 Pro Max",
            @"iPhone17,1": @"iPhone 16 Pro",
            @"iPhone17,2": @"iPhone 16 Pro Max",
            @"iPhone17,3": @"iPhone 16",
            @"iPhone17,4": @"iPhone 16 Plus",
            @"iPhone17,5": @"iPhone 16e",
            @"iPhone18,1": @"iPhone 17 Pro",
            @"iPhone18,2": @"iPhone 17 Pro Max",
            @"iPhone18,3": @"iPhone 17",
            @"iPhone18,4": @"iPhone Air",
            @"iPhone18,5": @"iPhone 17e",
    };
}

+ (NSDictionary *)getiPadModelDictionary {
    return @{
        @"iPad1,1": @"iPad",
        @"iPad2,1": @"iPad 2",
        @"iPad2,2": @"iPad 2",
        @"iPad2,3": @"iPad 2",
        @"iPad2,4": @"iPad 2",
        @"iPad2,5": @"iPad mini",
        @"iPad2,6": @"iPad mini",
        @"iPad2,7": @"iPad mini",
        @"iPad3,1": @"iPad (3rd generation)",
        @"iPad3,2": @"iPad (3rd generation)",
        @"iPad3,3": @"iPad (3rd generation)",
        @"iPad3,4": @"iPad (4th generation)",
        @"iPad3,5": @"iPad (4th generation)",
        @"iPad3,6": @"iPad (4th generation)",
        @"iPad4,1": @"iPad Air",
        @"iPad4,2": @"iPad Air",
        @"iPad4,3": @"iPad Air",
        @"iPad4,4": @"iPad mini 2",
        @"iPad4,5": @"iPad mini 2",
        @"iPad4,6": @"iPad mini 2",
        @"iPad4,7": @"iPad mini 3",
        @"iPad4,8": @"iPad mini 3",
        @"iPad4,9": @"iPad mini 3",
        @"iPad5,1": @"iPad mini 4",
        @"iPad5,2": @"iPad mini 4",
        @"iPad5,3": @"iPad Air 2",
        @"iPad5,4": @"iPad Air 2",
        @"iPad6,3": @"iPad Pro (9.7-inch)",
        @"iPad6,4": @"iPad Pro (9.7-inch)",
        @"iPad6,7": @"iPad Pro (12.9-inch)",
        @"iPad6,8": @"iPad Pro (12.9-inch)",
        @"iPad6,11": @"iPad (5th generation)",
        @"iPad6,12": @"iPad (5th generation)",
        @"iPad7,1": @"iPad Pro (12.9-inch) (2nd generation)",
        @"iPad7,2": @"iPad Pro (12.9-inch) (2nd generation)",
        @"iPad7,3": @"iPad Pro (10.5-inch)",
        @"iPad7,4": @"iPad Pro (10.5-inch)",
        @"iPad7,5": @"iPad (6th generation)",
        @"iPad7,6": @"iPad (6th generation)",
        @"iPad7,11": @"iPad (7th generation)",
        @"iPad7,12": @"iPad (7th generation)",
        @"iPad8,1": @"iPad Pro (11-inch)",
        @"iPad8,2": @"iPad Pro (11-inch)",
        @"iPad8,3": @"iPad Pro (11-inch)",
        @"iPad8,4": @"iPad Pro (11-inch)",
        @"iPad8,5": @"iPad Pro (12.9-inch) (3rd generation)",
        @"iPad8,6": @"iPad Pro (12.9-inch) (3rd generation)",
        @"iPad8,7": @"iPad Pro (12.9-inch) (3rd generation)",
        @"iPad8,8": @"iPad Pro (12.9-inch) (3rd generation)",
        @"iPad8,9": @"iPad Pro (11-inch) (2nd generation)",
        @"iPad8,10": @"iPad Pro (11-inch) (2nd generation)",
        @"iPad8,11": @"iPad Pro (12.9-inch) (4th generation)",
        @"iPad8,12": @"iPad Pro (12.9-inch) (4th generation)",
        @"iPad11,1": @"iPad mini (5th generation)",
        @"iPad11,2": @"iPad mini (5th generation)",
        @"iPad11,3": @"iPad Air (3rd generation)",
        @"iPad11,4": @"iPad Air (3rd generation)",
        @"iPad11,6": @"iPad (8th generation)",
        @"iPad11,7": @"iPad (8th generation)",
        @"iPad12,1": @"iPad (9th generation)",
        @"iPad12,2": @"iPad (9th generation)",
        @"iPad13,1": @"iPad Air (4th generation)",
        @"iPad13,2": @"iPad Air (4th generation)",
        @"iPad13,4": @"iPad Pro (11-inch) (3rd generation)",
        @"iPad13,5": @"iPad Pro (11-inch) (3rd generation)",
        @"iPad13,6": @"iPad Pro (11-inch) (3rd generation)",
        @"iPad13,7": @"iPad Pro (11-inch) (3rd generation)",
        @"iPad13,8": @"iPad Pro (12.9-inch) (5th generation)",
        @"iPad13,9": @"iPad Pro (12.9-inch) (5th generation)",
        @"iPad13,10": @"iPad Pro (12.9-inch) (5th generation)",
        @"iPad13,11": @"iPad Pro (12.9-inch) (5th generation)",
        @"iPad13,16": @"iPad Air (5th generation)",
        @"iPad13,17": @"iPad Air (5th generation)",
        @"iPad13,18": @"iPad (10th generation)",
        @"iPad13,19": @"iPad (10th generation)",
        @"iPad14,1": @"iPad mini (6th generation)",
        @"iPad14,2": @"iPad mini (6th generation)",
        @"iPad14,3": @"iPad Pro (11-inch) (4th generation)",
        @"iPad14,4": @"iPad Pro (11-inch) (4th generation)",
        @"iPad14,5": @"iPad Pro (12.9-inch) (6th generation)",
        @"iPad14,6": @"iPad Pro (12.9-inch) (6th generation)",
        @"iPad14,8": @"iPad Air 11-inch (M2)",
        @"iPad14,9": @"iPad Air 11-inch (M2)",
        @"iPad14,10": @"iPad Air 13-inch (M2)",
        @"iPad14,11": @"iPad Air 13-inch (M2)",
        @"iPad15,3": @"iPad Air 11-inch (M3)",
        @"iPad15,4": @"iPad Air 11-inch (M3)",
        @"iPad15,5": @"iPad Air 13-inch (M3)",
        @"iPad15,6": @"iPad Air 13-inch (M3)",
        @"iPad15,7": @"iPad (A16)",
        @"iPad15,8": @"iPad (A16)",
        @"iPad16,1": @"iPad mini (A17 Pro)",
        @"iPad16,2": @"iPad mini (A17 Pro)",
        @"iPad16,3": @"iPad Pro 11-inch (M4)",
        @"iPad16,4": @"iPad Pro 11-inch (M4)",
        @"iPad16,5": @"iPad Pro 13-inch (M4)",
        @"iPad16,6": @"iPad Pro 13-inch (M4)",
        @"iPad16,8": @"iPad Air 11-inch (M4)",
        @"iPad16,9": @"iPad Air 11-inch (M4)",
        @"iPad16,10": @"iPad Air 13-inch (M4)",
        @"iPad16,11": @"iPad Air 13-inch (M4)",
        @"iPad17,1": @"iPad Pro 11-inch (M5)",
        @"iPad17,2": @"iPad Pro 11-inch (M5)",
        @"iPad17,3": @"iPad Pro 13-inch (M5)",
        @"iPad17,4": @"iPad Pro 13-inch (M5)",
    };
}

+ (NSDictionary *)getiPodModelDictionary {
    return @{
        @"iPod1,1": @"iPod touch",
        @"iPod2,1": @"iPod touch (2nd generation)",
        @"iPod3,1": @"iPod touch (3rd generation)",
        @"iPod4,1": @"iPod touch (4th generation)",
        @"iPod5,1": @"iPod touch (5th generation)",
        @"iPod7,1": @"iPod touch (6th generation)",
        @"iPod9,1": @"iPod touch (7th generation)",
    };
}

+ (NSDictionary *)getAppleTVModelDictionary {
    return @{
        @"AppleTV1,1": @"Apple TV (1st generation)",
        @"AppleTV2,1": @"Apple TV (2nd generation)",
        @"AppleTV3,1": @"Apple TV (3rd generation)",
        @"AppleTV3,2": @"Apple TV (3rd generation)",
        @"AppleTV5,3": @"Apple TV HD",
        @"AppleTV6,2": @"Apple TV 4K",
        @"AppleTV11,1": @"Apple TV 4K (2nd generation)",
        @"AppleTV14,1": @"Apple TV 4K (3rd generation)",
    };
}

+ (NSString *)getDeviceSystemVersion{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(systemVersion)]) {
        NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
        return deviceVersion;
    } else {
        return @"";
    }
}

+ (NSString *)getDeviceAppVersion{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)getDeviceScreenResolution{
    return [self calculateScreenResolution];
}

+ (NSString *)getDeviceCPUCount{
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(processorCount)]) {
        NSInteger cpuCount = [[NSProcessInfo processInfo] processorCount];
        return [NSString stringWithFormat:@"%ld",(long)cpuCount];
    } else {
        return @"-1";
    }
}



+ (NSNumber *)getDeviceBatteryLevel{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    float batteryLevel = 0.0;
    float batteryCharge = [device batteryLevel];
    if (batteryCharge > 0.0f) {
        batteryLevel = batteryCharge * 100;
        return @(batteryLevel);
    } else {
        // Unable to find the battery level
        return @(-1);
    }
}

+ (NSString *)getDeviceBatteryChargingStatus{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    if ([device batteryState] == UIDeviceBatteryStateCharging || [device batteryState] == UIDeviceBatteryStateFull) {
        return @"true";
    } else {
        return @"false";
    }
}
+ (NSString *)getDeviceDefaultLanguage{
    NSArray *languages = [NSLocale preferredLanguages];
    // Get the user's language
    NSString *language = [languages objectAtIndex:0];
    if (language == nil || language.length <= 0) {
        return @"null";
    }
    return [language componentsSeparatedByString:@"-"].firstObject;
}

+ (NSString *)getDeviceDefaultTimeZone{
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSString *timeZoneName = [timeZone name];
    // Check for validity
    if (timeZoneName == nil || timeZoneName.length <= 0) {
        return @"null";
    }
    return timeZoneName;
}

+ (NSString *)getDeviceScreenBrightness{
    float brightness = [UIScreen mainScreen].brightness;
    if (brightness < 0.0 || brightness > 1.0) {
        return @"-1";
    }
    return [NSString stringWithFormat:@"%d",(int)(brightness*100)];
}

+ (BOOL)isDeviceAttachedDebugger{
    return [self checkDebuggerAttachment];
}

+ (NSString *)isDeviceSimulator{
    NSString *deviceType = [self getDeviceType];
    if ([deviceType containsString:@"Simulator"]) {
        return @"true";
    }else{
        return @"false";
    }
}

+ (NSString *)getDeviceAdvertisingIdentifier{
    return [self getAdvertisingIdentifier];
}

+ (NSString *)getDeviceName{
    UIDevice *device = [UIDevice currentDevice];
    return device.name;
}

@end
