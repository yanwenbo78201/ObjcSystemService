//
//  StorageService.m
//  CodeSkiingTraining
//
//  Created by IndiaComputer on 19/09/25.
//

#import "StorageService.h"
#import <mach/mach.h>
#include <sys/sysctl.h>

@implementation StorageService

#pragma mark - Public Storage Methods

+ (NSDictionary *)getDeviceStorageInfo
{
    NSMutableDictionary *storageInfo = [NSMutableDictionary dictionary];
    storageInfo[@"ramTotal"] = [NSString stringWithFormat:@"%.6f",[StorageService getDeviceTotalMemorySize]];
    storageInfo[@"ramCanUse"] = [NSString stringWithFormat:@"%f",[StorageService getDeviceTotalMemorySize] - [StorageService getDeviceUsedMemorySize]];
    storageInfo[@"cashTotal"] = [NSString stringWithFormat:@"%.6f",[[StorageService getDeviceTotalStorageSize] floatValue]];
    storageInfo[@"cashCanUse"] = [NSString stringWithFormat:@"%.6f",[[StorageService getDeviceAvailableStorageSize] floatValue]];
    return  storageInfo;
}

+ (NSString *)getDeviceTotalStorageSize {
    long long totalDiskSpace = [self getDiskTotalSpace];
    
    if (totalDiskSpace < 0) {
        return @"0";
    }
    
    NSString *formattedSize = [self formatStorageSize:totalDiskSpace];
    if (formattedSize) {
        return formattedSize;
    }
    
    return @"0";
}

+ (NSString *)getDeviceAvailableStorageSize {
    long long availableDiskSpace = [self getDiskAvailableSpace];
    
    if (availableDiskSpace <= 0) {
        return @"0";
    }
    
    NSString *formattedSize = [self formatStorageSize:availableDiskSpace];
    if (formattedSize) {
        return formattedSize;
    }
    
    return @"0";

}

#pragma mark - Public Memory Methods

+ (double)getDeviceTotalMemorySize {
    double physicalMemory = [self getPhysicalMemorySize];
    double roundedMemory = [self roundMemoryToNearest256MB:physicalMemory];
    
    if (roundedMemory <= 0) {
        return -1;
    }
    
    return roundedMemory / 1024.0; // 转换为GB
}

+ (double)getDeviceUsedMemorySize {
    vm_statistics_data_t vmStats;
    vm_size_t pageSize;
    
    if (![self getVMStatistics:&vmStats pageSize:&pageSize]) {
        return -1;
    }
    
    double usedMemoryBytes = [self calculateUsedMemory:vmStats pageSize:pageSize];
    double usedMemoryGB = [self convertBytesToGB:usedMemoryBytes];
    
    return usedMemoryGB;
}

#pragma mark - Public Utility Methods

+ (NSString *)formatStorageSize:(long long)bytes {
    if (bytes <= 0) {
        return nil;
    }
    
    double numberBytes = 1.0 * bytes;
    double totalGB = numberBytes / (1024 * 1024 * 1024);
    
    NSString *formattedSize = nil;
    formattedSize = [NSString stringWithFormat:@"%.6f", totalGB];
    return formattedSize;
}

#pragma mark - Private Storage Helper Methods

+ (long long)getDiskTotalSpace {
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    
    if (error != nil) {
        return -1;
    }
    
    long long totalSpace = [[fileAttributes objectForKey:NSFileSystemSize] longLongValue];
    return totalSpace > 0 ? totalSpace : -1;
}

+ (long long)getDiskAvailableSpace {
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    
    if (error != nil) {
        return -1;
    }
    
    long long availableSpace = [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    return availableSpace;
}

+ (double)extractNumericValueFromFormattedString:(NSString *)formattedString {
    NSArray *components = [formattedString componentsSeparatedByString:@" "];
    if (components.count > 0) {
        return [[components firstObject] doubleValue];
    }
    return 0.0;
}


#pragma mark - Private Memory Helper Methods

+ (double)getPhysicalMemorySize {
    double physicalMemory = [[NSProcessInfo processInfo] physicalMemory];
    return (physicalMemory / 1024.0) / 1024.0; // 转换为MB
}

+ (double)roundMemoryToNearest256MB:(double)memoryInMB {
    int toNearest = 256;
    int remainder = (int)memoryInMB % toNearest;
    
    if (remainder >= toNearest / 2) {
        return ((int)memoryInMB - remainder) + 256;
    } else {
        return (int)memoryInMB - remainder;
    }
}

+ (BOOL)getVMStatistics:(vm_statistics_data_t *)vmStats pageSize:(vm_size_t *)pageSize {
    mach_port_t hostPort = mach_host_self();
    mach_msg_type_number_t hostSize = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    
    if (host_page_size(hostPort, pageSize) != KERN_SUCCESS) {
        return NO;
    }
    
    return host_statistics(hostPort, HOST_VM_INFO, (host_info_t)vmStats, &hostSize) == KERN_SUCCESS;
}

+ (double)calculateUsedMemory:(vm_statistics_data_t)vmStats pageSize:(vm_size_t)pageSize {
    return (double)((vmStats.active_count + vmStats.inactive_count + vmStats.wire_count) * pageSize);
}

+ (double)convertBytesToGB:(double)bytes {
    return (bytes / 1024.0) / 1024.0 / 1024.0;
}

@end
