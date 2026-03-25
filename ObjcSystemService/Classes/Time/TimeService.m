//
//  TimeService.m
//  ObjcSystemService_Example
//
//  Created by Computer  on 25/03/26.
//  Copyright © 2026 crazyLuobo. All rights reserved.
//

#import "TimeService.h"
#import <mach/mach.h>
#include <sys/sysctl.h>

@implementation TimeService

+ (NSDictionary *)getDevicetimeInfo
{
    NSMutableDictionary *timeInfo = [NSMutableDictionary dictionary];
    timeInfo[@"totalBootTime"] = [TimeService getDeviceSystemUptime];
    timeInfo[@"totalBootTimeWake"] = [TimeService getDeviceProcessUptime];
    timeInfo[@"lastBootTime"] = [TimeService getDeviceBootTime];
    return  timeInfo;
}


+ (NSString *)getDeviceSystemUptime {
    struct timeval bootTime;
    if (![self getBootTime:&bootTime]) {
        return @"-1";
    }
    
    struct timeval currentTime;
    [self getCurrentTime:&currentTime];
    
    long long uptimeMilliseconds = [self calculateUptimeInMilliseconds:currentTime bootTime:bootTime];
    return [NSString stringWithFormat:@"%lld", uptimeMilliseconds];
}

+ (NSString *)getDeviceProcessUptime {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSTimeInterval uptimeInterval = [processInfo systemUptime];
    long long uptimeMilliseconds = (long long)(uptimeInterval * 1000);
    
    return [NSString stringWithFormat:@"%lld", uptimeMilliseconds];
}

+ (NSString *)getDeviceBootTime {
    long long systemUptime = [[self getDeviceSystemUptime] longLongValue];
    NSTimeInterval bootTimeInterval = (double)systemUptime / 1000.0;
    NSDate *bootDate = [NSDate dateWithTimeIntervalSinceNow:(0 - bootTimeInterval)];
    long bootTimestamp = [bootDate timeIntervalSince1970] * 1000;
    
    return [NSString stringWithFormat:@"%ld", bootTimestamp];
}

+ (BOOL)getBootTime:(struct timeval *)bootTime {
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(*bootTime);
    
    int result = sysctl(mib, 2, bootTime, &size, NULL, 0);
    return (result != -1 && bootTime->tv_sec != 0);
}

+ (void)getCurrentTime:(struct timeval *)currentTime {
    struct timezone currentTimeZone;
    gettimeofday(currentTime, &currentTimeZone);
}

+ (long long)calculateUptimeInMilliseconds:(struct timeval)currentTime bootTime:(struct timeval)bootTime {
    long long uptimeMilliseconds = ((long long)(currentTime.tv_sec - bootTime.tv_sec)) * 1000;
    uptimeMilliseconds += (currentTime.tv_usec - bootTime.tv_usec) / 1000;
    return uptimeMilliseconds;
}
@end
