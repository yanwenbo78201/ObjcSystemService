//
//  SystemService.h
//  FYDeviceObjc_Example
//
//  Created by Computer  on 07/01/26.
//  Copyright © 2026 Computer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SystemService : NSObject
- (NSDictionary *)deviceInfo NS_SWIFT_NAME(deviceInfo());
@end

NS_ASSUME_NONNULL_END
