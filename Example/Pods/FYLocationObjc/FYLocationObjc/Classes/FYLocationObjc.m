//
//  FYLocationObjc.m
//  FYLocationObjc_Example
//
//  Created by Computer  on 07/01/26.
//  Copyright © 2026 Computer. All rights reserved.
//

#import "FYLocationObjc.h"
@interface FYLocationObjc () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) FYLocationCompletionBlock completionBlock;
@property (nonatomic, assign) BOOL required;

@end


@implementation FYLocationObjc
+ (instancetype)sharedManager {
    static FYLocationObjc *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FYLocationObjc alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)requestLocationWithRequired:(BOOL)required
                          completion:(FYLocationCompletionBlock)completion {
    
    if (!completion) {
        return;
    }
    
    self.required = required;
    self.completionBlock = completion;
    
    CLAuthorizationStatus status;
    if (@available(iOS 14.0, *)) {
        status = self.locationManager.authorizationStatus;
    } else {
        status = [CLLocationManager authorizationStatus];
    }
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [self startUpdatingLocation];
            break;
        }
            
        case kCLAuthorizationStatusNotDetermined: {
            // 首次请求，弹出系统授权弹框
            [self.locationManager requestWhenInUseAuthorization];
            // 回调会在 didChangeAuthorizationStatus 中处理
            break;
        }
            
        case kCLAuthorizationStatusDenied: {
            // 情况1: 非首次获取的权限是拒绝
            if (required) {
                // 必须获取经纬度：经纬度为nil，弹出二次弹框，没有成功
                CLLocationCoordinate2D invalidCoordinate = CLLocationCoordinate2DMake(0, 0);
                completion(NO, invalidCoordinate, YES, NO);
            } else {
                // 非必须获取经纬度：经纬度-360，-360，不需要弹窗二次弹框，成功
                CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(-360, -360);
                completion(YES, defaultCoordinate, NO, NO);
            }
            self.completionBlock = nil;
            break;
        }
            
        case kCLAuthorizationStatusRestricted: {

            // 受限制（家长控制等）
            if (required) {
                CLLocationCoordinate2D invalidCoordinate = CLLocationCoordinate2DMake(0, 0);
                completion(NO, invalidCoordinate, NO, NO);
            } else {
                CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(-360, -360);
                completion(YES, defaultCoordinate, NO, NO);
            }
            self.completionBlock = nil;
            break;
        }
            
        default: {
            if (required) {
                CLLocationCoordinate2D invalidCoordinate = CLLocationCoordinate2DMake(0, 0);
                completion(NO, invalidCoordinate, NO,NO);
            } else {
                CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(-360, -360);
                completion(YES, defaultCoordinate, NO, NO);
            }
            self.completionBlock = nil;
            break;
        }
    }
}

- (void)startUpdatingLocation {
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    // 首次授权回调
    if (!self.completionBlock) {
        return;
    }
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            // 情况3: 首次获取，如果是同意，获取当前经纬度，不需要弹窗二次弹框，成功
            [self startUpdatingLocation];
            break;
        }
            
        case kCLAuthorizationStatusDenied: {
            // 情况4: 首次获取，如果是不同意
            if (self.required) {
                // 必须获取经纬度：经纬度为nil，不需要弹窗二次弹框，没有成功
                CLLocationCoordinate2D invalidCoordinate = CLLocationCoordinate2DMake(0, 0);
                self.completionBlock(NO, invalidCoordinate, NO, NO);
            } else {
                // 非必须获取经纬度：经纬度-360，-360，不需要弹窗二次弹框，成功
                CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(-360, -360);
                self.completionBlock(YES, defaultCoordinate, NO, NO);
            }
            self.completionBlock = nil;
            break;
        }
            
        case kCLAuthorizationStatusRestricted: {
            // 受限制
            if (self.required) {
                CLLocationCoordinate2D invalidCoordinate = CLLocationCoordinate2DMake(0, 0);
                self.completionBlock(NO, invalidCoordinate, NO, NO);
            } else {
                CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(-360, -360);
                self.completionBlock(YES, defaultCoordinate, NO, NO);
            }
            self.completionBlock = nil;
            break;
        }
            
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (!self.completionBlock) {
        return;
    }
    [self.locationManager stopUpdatingLocation];
    
    // 获取最新位置
    CLLocation *location = locations.lastObject;
    if (location) {
        CLLocationCoordinate2D coordinate = location.coordinate;
        
        // 验证经纬度是否有效
        if (CLLocationCoordinate2DIsValid(coordinate)) {
            // 成功获取经纬度，不需要弹窗二次弹框，成功
            self.completionBlock(YES, coordinate, NO, YES);
        } else {
            // 经纬度无效
            if (self.required) {
                CLLocationCoordinate2D invalidCoordinate = CLLocationCoordinate2DMake(0, 0);
                self.completionBlock(NO, invalidCoordinate, NO, NO);
            } else {
                CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(-360, -360);
                self.completionBlock(YES, defaultCoordinate, NO, NO);
            }
        }
    } else {
        // 未获取到位置
        if (self.required) {
            CLLocationCoordinate2D invalidCoordinate = CLLocationCoordinate2DMake(0, 0);
            self.completionBlock(NO, invalidCoordinate, NO, NO);
        } else {
            CLLocationCoordinate2D defaultCoordinate = CLLocationCoordinate2DMake(-360, -360);
            self.completionBlock(YES, defaultCoordinate, NO, NO);
        }
    }
    
    self.completionBlock = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  
}



@end
