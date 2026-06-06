//
//  FYViewController.m
//  ObjcSystemService
//
//  Created by crazyLuobo on 03/25/2026.
//  Copyright (c) 2026 crazyLuobo. All rights reserved.
//

#import "FYViewController.h"
#import <ObjcSystemService/SystemService.h>
#import <ObjcSystemService_Example-Swift.h>
#import <FYLocationObjc.h>
@interface FYViewController ()

@end

@implementation FYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@",[[SystemService new] deviceInfoWithOutWifi]);
    
//    [[FYLocationObjc sharedManager] requestLocationWithRequired:NO completion:^(BOOL success, CLLocationCoordinate2D coordinate, BOOL needShowAlert, BOOL authStatus) {
//        [[SystemService new] deviceInfoWithCompletion:^(NSDictionary *info) {
//            NSLog(@"设备信息: %@", info);
//        }];
//        
//    }];
    /*NSLog(@"%@",[systemService deviceInfo])*/;
    double a = 8589934292.0;
    NSLog(@"%f",a);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    SwiftViewController *swiftVC = [[SwiftViewController alloc] init];
    [self.navigationController pushViewController:swiftVC animated:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
