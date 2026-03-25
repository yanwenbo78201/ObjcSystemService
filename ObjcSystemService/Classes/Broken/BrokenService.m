//
//  BrokenService.m
//  ObjcSystemService_Example
//
//  Created by Computer  on 25/03/26.
//  Copyright © 2026 crazyLuobo. All rights reserved.
//

#import "BrokenService.h"
#import <sys/stat.h>
#import <sys/sysctl.h>
#define CHECKFILEEXIT [NSFileManager defaultManager] fileExistsAtPath:
enum {
    PhoneBrokenKindTypeCydia = 432,
    PhoneBrokenKindTypeExists = 6625,
    PhoneBrokenKindTypePlist = 9412,
    PhoneBrokenKindTypeSymbolic = 34859,
    PhoneBrokenKindTypeIFC = 47293,
    PhoneBrokenKindTypeBroken = 3429542,
    PhoneBrokenKindTypeNotFound = 4783242
    
} PhoneBrokenKindType;

@implementation BrokenService
+ (BOOL)phoneBrokenStatus {
    int checkDeviceDestructionResult = 0;

    if ([self phoneBrokenConditionCydiaCheck] != PhoneBrokenKindTypeNotFound) {
        checkDeviceDestructionResult += 3;
    }
    
    if ([self phoneBrokenConditionInaccessibleFilesCheck] != PhoneBrokenKindTypeNotFound) {
        checkDeviceDestructionResult += 2;
    }

    if ([self phoneBrokenConditionPlistCheck] != PhoneBrokenKindTypeNotFound) {
        checkDeviceDestructionResult += 2;
    }

    if ([self phoneBrokenConditionSymbolicLinkCheck] != PhoneBrokenKindTypeNotFound) {
        checkDeviceDestructionResult += 2;
    }

    if ([self phoneBrokenConditionfilesExistCheck] != PhoneBrokenKindTypeNotFound) {
        checkDeviceDestructionResult += 2;
    }
    if (checkDeviceDestructionResult >= 3) {
        return YES;
    }
    return NO;
}

+ (int)phoneBrokenConditionCydiaCheck {
    @try {
        NSString *filePath = @"/Applications/Cydia.app";
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return PhoneBrokenKindTypeCydia;
        } else {
            return PhoneBrokenKindTypeNotFound;
        }
    }
    @catch (NSException *exception) {
        return PhoneBrokenKindTypeNotFound;
    }
}
+ (int)phoneBrokenConditionInaccessibleFilesCheck {
    @try {
        NSArray *filesList = [NSArray arrayWithObjects:@"/Applications/RockApp.app",@"/Applications/Icy.app",@"/usr/sbin/sshd",@"/usr/bin/sshd",@"/usr/libexec/sftp-server",@"/Applications/WinterBoard.app",@"/Applications/SBSettings.app",@"/Applications/MxTube.app",@"/Applications/IntelliScreen.app",@"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",@"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",@"/private/var/lib/apt",@"/private/var/stash",@"/System/Library/LaunchDaemons/com.ikey.bbot.plist",@"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",@"/private/var/tmp/cydia.log",@"/private/var/lib/cydia", @"/etc/clutch.conf", @"/var/cache/clutch.plist", @"/etc/clutch_cracked.plist", @"/var/cache/clutch_cracked.plist", @"/var/lib/clutch/overdrive.dylib", @"/var/root/Documents/Cracked/", nil];
        for (NSString *file in filesList) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
                return PhoneBrokenKindTypeIFC;
            }
        }
        return PhoneBrokenKindTypeNotFound;
    }
    @catch (NSException *exception) {
        return PhoneBrokenKindTypeNotFound;
    }
}

+ (int)phoneBrokenConditionPlistCheck {
    @try {
        NSString *exeName = [[NSBundle mainBundle] executablePath];
        NSDictionary *filePath = [[NSBundle mainBundle] infoDictionary];
        if ([CHECKFILEEXIT exeName] == FALSE || filePath == nil || filePath.count <= 0) {
            return PhoneBrokenKindTypePlist;
        } else {
            return PhoneBrokenKindTypeNotFound;
        }
    }
    @catch (NSException *exception) {
        return PhoneBrokenKindTypeNotFound;
    }
}

+ (int)phoneBrokenConditionfilesExistCheck {
    @try {
        if (![CHECKFILEEXIT [[NSBundle mainBundle] executablePath]]) {
            return PhoneBrokenKindTypeExists;
        } else
            return PhoneBrokenKindTypeNotFound;
    }
    @catch (NSException *exception) {
        return PhoneBrokenKindTypeNotFound;
    }
}

+ (int)phoneBrokenConditionSymbolicLinkCheck {
    @try {
        struct stat s;
        if (lstat("/Applications", &s) != 0) {
            if (s.st_mode & S_IFLNK) {
                // Device is jailbroken
                return PhoneBrokenKindTypeSymbolic;
            } else
                return PhoneBrokenKindTypeNotFound;
        } else {
            return PhoneBrokenKindTypeNotFound;
        }
    }
    @catch (NSException *exception) {
        return PhoneBrokenKindTypeNotFound;
    }
}

@end
