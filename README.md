# ObjcSystemService

[![CI Status](https://img.shields.io/travis/crazyLuobo/ObjcSystemService.svg?style=flat)](https://travis-ci.org/crazyLuobo/ObjcSystemService)
[![Version](https://img.shields.io/cocoapods/v/ObjcSystemService.svg?style=flat)](https://cocoapods.org/pods/ObjcSystemService)
[![License](https://img.shields.io/cocoapods/l/ObjcSystemService.svg?style=flat)](https://cocoapods.org/pods/ObjcSystemService)
[![Platform](https://img.shields.io/cocoapods/p/ObjcSystemService.svg?style=flat)](https://cocoapods.org/pods/ObjcSystemService)

面向 iOS 的 Objective-C 工具库，收集设备、网络、存储、时间等信息，并提供越狱/调试等环境检测。已配置 **Clang 模块**（`DEFINES_MODULE`），**Swift 与 Objective-C 均可使用**。

## 功能概览

| 组件 | 说明 |
|------|------|
| **SystemService** | 异步一键汇总：后台线程获取所有信息，回调返回合并字典（含 `rooted` 等字段） |
| **DeviceService** | 系统版本、机型、屏幕、电量、语言时区、模拟器/调试器、IDFA/IDFV（依赖 ATT/AdSupport）等 |
| **NetworkService** | 网络类型、代理/VPN、Wi‑Fi 信息（支持异步获取）、移动网络类型等 |
| **StorageService** | 内存与磁盘用量、格式化辅助方法 |
| **TimeService** | 系统/进程运行时长、上次启动时间等 |
| **BrokenService** | `phoneBrokenStatus` 越狱状态检测 |

## API 详细说明

### DeviceService

```objc
// 同步方法
[DeviceService deviceSystemVersion];           // 系统版本
[DeviceService deviceAppVersion];               // App版本
[DeviceService deviceScreenResolution];         // 屏幕分辨率
[DeviceService deviceCPUCount];                 // CPU核心数
[DeviceService deviceBatteryLevel];             // 电量等级 (0-100)
[DeviceService deviceBatteryChargingStatus];   // 充电状态 ("true"/"false")
[DeviceService deviceDefaultLanguage];         // 默认语言
[DeviceService deviceDefaultTimeZone];          // 默认时区
[DeviceService deviceScreenBrightness];         // 屏幕亮度 (0-100)
[DeviceService isAttachedDebugger];            // 是否连接调试器
[DeviceService isSimulator];                   // 是否模拟器 ("true"/"false")
[DeviceService deviceAdvertisingIdentifier];   // IDFA
[DeviceService deviceName];                     // 设备名称
[DeviceService deviceTypeNumber];              // 设备类型数字 (1-Mac, 2-iPad, 3-iPhone)
[DeviceService deviceTypeString];               // 设备类型字符串 ("pc"/"Tablet"/"Mobile")
[DeviceService deviceType];                     // 设备详细型号
[DeviceService deviceSystemInfo];              // 设备完整信息字典
```

### NetworkService

```objc
// 同步方法
[NetworkService deviceNetworkProxyStatus];       // 代理状态 ("true"/"false")
[NetworkService deviceVPNConnectionStatus];     // VPN状态 ("true"/"false")
[NetworkService deviceNetworkType];             // 网络类型代码 (0-未知, 1-WiFi, 2-2G, 3-3G, 4-4G, 5-5G)
[NetworkService deviceNetworkDetailType];       // 网络详细类型
[NetworkService deviceMobileNetworkType];      // 移动网络类型 (2G/3G/4G/5G)
[NetworkService isNetworkReachable];            // 网络是否可达
[NetworkService isNetworkUsingWiFi];           // 是否使用WiFi
[NetworkService isNetworkUsingCellular];       // 是否使用移动网络

// 异步方法（推荐使用，避免阻塞主线程）
[NetworkService getDeviceWiFiNetworkInfoWithCompletion:^(NSDictionary *wifiInfo) {
    NSString *ssid = wifiInfo[@"ssid"] ?: @"null";
    NSString *bssid = wifiInfo[@"bssid"] ?: @"null";
    // 在主线程回调
}];

[NetworkService getDeviceCommunicationInfoWithCompletion:^(NSDictionary *info) {
    // info 包含: network, wifiName, wifiBssid, isvpn, proxied
    // 在主线程回调
}];
```

### StorageService

```objc
[StorageService deviceStorageInfo];             // 存储完整信息字典
[StorageService deviceTotalMemorySize];         // 总内存 (GB)
[StorageService deviceUsedMemorySize];          // 已用内存 (GB)
[StorageService deviceTotalStorageSize];        // 总存储空间 (GB)
[StorageService deviceAvailableStorageSize];    // 可用存储空间 (GB)
[StorageService formatStorageSize:bytes];       // 字节数转换为GB字符串
```

### TimeService

```objc
[TimeService getDevicetimeInfo];                // 时间完整信息字典
[TimeService deviceSystemUptime];              // 系统运行时间 (毫秒)
[TimeService deviceProcessUptime];             // 进程运行时间 (毫秒)
[TimeService deviceBootTime];                  // 上次启动时间 (时间戳，毫秒)
```

### BrokenService

```objc
[BrokenService phoneBrokenStatus];             // 是否越狱 (YES/NO)
```

### SystemService

```objc
// 同步方法 - 不含WiFi信息
NSDictionary *info = [[[SystemService alloc] init] deviceInfoWithOutWifi];
// info 包含: 设备信息, 屏幕信息, 电池信息, 系统信息, 存储信息, 网络信息(不含WiFi), 时间信息, 越狱状态

// 同步方法 - 不含WiFi信息，带UUID
NSDictionary *info = [[[SystemService alloc] init] deviceInfoWithOutWifiWithUuid:@"your-uuid"];
// info 在上一方法基础上额外包含 uuid 字段

// 异步方法（推荐使用）- 包含完整信息
[[[SystemService alloc] init] deviceInfoWithCompletion:^(NSDictionary *info) {
    // info 包含:
    // - 设备信息 (idfa, idfv, phoneMark, phoneType, systemVersions, versionCode, ...)
    // - 屏幕信息 (screenResolution, screenWidth, screenHeight, screenBrightness, ...)
    // - 电池信息 (batteryLevel, charged)
    // - 系统信息 (defaultLanguage, defaultTimeZone, cpuNum, simulated, debugged)
    // - 存储信息 (ramTotal, ramCanUse, cashTotal, cashCanUse)
    // - 网络信息 (network, wifiName, wifiBssid, isvpn, proxied)
    // - 时间信息 (totalBootTime, totalBootTimeWake, lastBootTime)
    // - 越狱状态 (rooted: "true"/"false")
    // 在主线程回调返回
}];

// 异步方法 - 带UUID的完整信息
[[[SystemService alloc] init] deviceInfoWithUuid:@"your-uuid" WithCompletion:^(NSDictionary *info) {
    // info 在完整信息基础上额外包含 uuid 字段
}];
```

**Swift 调用：**

```swift
// 同步方法 - 不含WiFi信息
let info = SystemService().deviceInfoWithoutWifi()

// 同步方法 - 不含WiFi信息，带UUID
let info = SystemService().deviceInfoWithoutWifi(uuid: "your-uuid")

// 异步方法 - 包含完整信息
SystemService().deviceInfo { info in
    // 处理完整信息
}

// 异步方法 - 带UUID的完整信息
SystemService().deviceInfo(uuid: "your-uuid") { info in
    // 处理带UUID的完整信息
}
```

## 使用示例

### 获取所有设备信息

SystemService 提供四种方式获取完整的设备信息：

**Objective-C**

```objc
#import <ObjcSystemService/ObjcSystemService.h>

// 1. 同步方法 - 不含WiFi信息（避免权限问题）
NSDictionary *info = [[[SystemService alloc] init] deviceInfoWithOutWifi];

// 2. 同步方法 - 不含WiFi信息，带UUID
NSDictionary *info = [[[SystemService alloc] init] deviceInfoWithOutWifiWithUuid:@"your-uuid"];

// 3. 异步方法 - 包含完整信息（推荐）
[[[SystemService alloc] init] deviceInfoWithCompletion:^(NSDictionary *info) {
    // info 包含设备、网络、存储、时间、越狱状态等完整信息
    NSLog(@"Device Info: %@", info);
}];

// 4. 异步方法 - 带UUID的完整信息
[[[SystemService alloc] init] deviceInfoWithUuid:@"your-uuid" WithCompletion:^(NSDictionary *info) {
    // info 在完整信息基础上额外包含 uuid 字段
}];
```

**Swift**

```swift
import ObjcSystemService

// 1. 同步方法 - 不含WiFi信息
let info = SystemService().deviceInfoWithoutWifi()

// 2. 同步方法 - 不含WiFi信息，带UUID
let info = SystemService().deviceInfoWithoutWifi(uuid: "your-uuid")

// 3. 异步方法 - 包含完整信息
SystemService().deviceInfo { info in
    print("Device Info: \(info)")
}

// 4. 异步方法 - 带UUID的完整信息
SystemService().deviceInfo(uuid: "your-uuid") { info in
    print("Device Info: \(info)")
}
```

### 按需获取特定信息

**Objective-C**

```objc
// 获取设备型号
NSString *deviceType = [DeviceService deviceType];

// 获取电池信息
NSNumber *batteryLevel = [DeviceService deviceBatteryLevel];
NSString *isCharging = [DeviceService deviceBatteryChargingStatus];

// 获取存储信息
NSDictionary *storageInfo = [StorageService deviceStorageInfo];

// 获取系统运行时间
NSString *uptime = [TimeService deviceSystemUptime];

// 获取网络信息（同步，不含WiFi）
NSDictionary *networkInfo = [NetworkService deviceCommunicationInfoWithoutWifi];
```

**Swift**

```swift
let deviceType = DeviceService().deviceType()
let batteryLevel = DeviceService().deviceBatteryLevel()
let storageInfo = StorageService().deviceStorageInfo()
let networkInfo = NetworkService.deviceCommunicationInfoWithoutWifi()
```

### 异步获取 WiFi 和网络信息（推荐）

**Objective-C**

```objc
// 异步获取WiFi信息
[NetworkService getDeviceWiFiNetworkInfoWithCompletion:^(NSDictionary *wifiInfo) {
    if (wifiInfo) {
        NSString *ssid = wifiInfo[@"ssid"];
        NSString *bssid = wifiInfo[@"bssid"];
        NSLog(@"WiFi: %@ (%@)", ssid, bssid);
    }
}];

// 异步获取完整网络通信信息
[NetworkService getDeviceCommunicationInfoWithCompletion:^(NSDictionary *info) {
    NSString *network = info[@"network"];      // 网络类型代码
    NSString *wifiName = info[@"wifiName"];    // WiFi名称
    NSString *wifiBssid = info[@"wifiBssid"];  // WiFi BSSID
    NSString *isVPN = info[@"isvpn"];          // VPN状态
    NSString *isProxied = info[@"proxied"];   // 代理状态
}];
```

**Swift**

```swift
// 异步获取WiFi信息
NetworkService.deviceWiFiNetworkInfo { wifiInfo in
    if let info = wifiInfo {
        let ssid = info["ssid"] as? String ?? "null"
        let bssid = info["bssid"] as? String ?? "null"
        print("WiFi: \(ssid) (\(bssid))")
    }
}

// 异步获取完整网络通信信息
NetworkService.deviceCommunicationInfo { info in
    let network = info["network"] as? String ?? "0"
    let wifiName = info["wifiName"] as? String ?? "null"
    let isVPN = info["isvpn"] as? String ?? "false"
    print("Network: \(network), WiFi: \(wifiName), VPN: \(isVPN)")
}
```

## 子模块（Subspec）与按需集成

默认 `pod 'ObjcSystemService'` 会安装 **`System` 子模块**，并自动依赖其余全部子模块，行为与「整库」一致。

| Subspec | 目录 | 主要系统框架 |
|---------|------|----------------|
| `Broken` | `Classes/Broken/` | Foundation |
| `Device` | `Classes/Device/` | UIKit、AppTrackingTransparency、AdSupport |
| `Network` | `Classes/Network/` | CoreTelephony、SystemConfiguration |
| `Storage` | `Classes/Storage/` | Foundation |
| `Time` | `Classes/Time/` | Foundation |
| `System` | `SystemService.{h,m}` | 依赖上述全部 |

**Podfile 示例**

```ruby
# 全量（默认，含 SystemService 聚合）
pod 'ObjcSystemService'

# 仅设备相关（不编译 Network/Storage 等）
pod 'ObjcSystemService/Device'

# 组合
pod 'ObjcSystemService/Network', 'ObjcSystemService/Storage'
```

说明：无论安装哪些子模块，模块名仍为 **`ObjcSystemService`**（`import ObjcSystemService` / `#import <ObjcSystemService/...>`）；未选中的子目录不会参与编译与链接。

## Requirements

- iOS **10.0+**
- **ARC**
- 使用 **Device** 子模块且涉及广告标识符时，请在 `Info.plist` 中配置 **`NSUserTrackingUsageDescription`**（App Tracking Transparency），并按业务在适当时机请求追踪授权。

## Installation

通过 [CocoaPods](https://cocoapods.org) 集成：

```ruby
pod 'ObjcSystemService'
```

克隆仓库后，在 **`Example`** 目录执行 `pod install`，再打开 `ObjcSystemService.xcworkspace` 运行示例工程。

## Example

示例工程演示在 Objective-C / Swift 中引用本库的方式；运行前请在 `Example` 目录执行：

```bash
pod install
```

## Author

crazyLuobo, yanwenbo_78201@163.com

## License

ObjcSystemService is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
