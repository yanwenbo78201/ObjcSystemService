# ObjcSystemService

[![CI Status](https://img.shields.io/travis/crazyLuobo/ObjcSystemService.svg?style=flat)](https://travis-ci.org/crazyLuobo/ObjcSystemService)
[![Version](https://img.shields.io/cocoapods/v/ObjcSystemService.svg?style=flat)](https://cocoapods.org/pods/ObjcSystemService)
[![License](https://img.shields.io/cocoapods/l/ObjcSystemService.svg?style=flat)](https://cocoapods.org/pods/ObjcSystemService)
[![Platform](https://img.shields.io/cocoapods/p/ObjcSystemService.svg?style=flat)](https://cocoapods.org/pods/ObjcSystemService)

面向 iOS 的 Objective-C 工具库，收集设备、网络、存储、时间等信息，并提供越狱/调试等环境检测。已配置 **Clang 模块**（`DEFINES_MODULE`），**Swift 与 Objective-C 均可使用**。

## 功能概览

| 组件 | 说明 |
|------|------|
| **SystemService** | 一键汇总：调用各子服务并合并为单个字典（含 `rooted` 等字段） |
| **DeviceService** | 系统版本、机型、屏幕、电量、语言时区、模拟器/调试器、IDFA/IDFV（依赖 ATT/AdSupport）等 |
| **NetworkService** | 运营商与网络类型、代理/VPN、Wi‑Fi 信息、可达性等 |
| **StorageService** | 内存与磁盘用量、格式化辅助方法 |
| **TimeService** | 系统/进程运行时长、上次启动时间等 |
| **BrokenService** | `phoneBrokenStatus` 等设备异常/越狱相关判断 |

聚合层 **`SystemService`** 的 `-deviceInfo` 会合并 `DeviceService`、`StorageService`、`NetworkService`、`TimeService` 的字典，并写入 `rooted`（由 `BrokenService` 推导的字符串 `"true"` / `"false"`）。

## 使用示例

**Objective-C**

```objc
#import <ObjcSystemService/ObjcSystemService.h>
// 或按需：#import <ObjcSystemService/SystemService.h> 等

NSDictionary *info = [[[SystemService alloc] init] deviceInfo];
```

**Swift**（建议在 Podfile 中使用 `use_frameworks!` 或对该 Pod 开启 modular headers）

```swift
import ObjcSystemService

let info = SystemService().deviceInfo()
```

仅需要某一类能力时，可直接调用对应 `*Service` 的类方法（需通过 CocoaPods **子模块** 引入对应源码，见下文）。

### 异步获取 WiFi 信息

NetworkService 提供异步方法获取 WiFi 信息，避免阻塞主线程：

**Objective-C**

```objc
[NetworkService getDeviceWiFiNetworkInfoWithCompletion:^(NSDictionary *wifiInfo) {
    NSString *ssid = wifiInfo[@"ssid"] ?: @"null";
    NSString *bssid = wifiInfo[@"bssid"] ?: @"null";
    // 处理 WiFi 信息
}];

// 获取完整网络通信信息（异步）
[NetworkService getDeviceCommunicationInfoWithCompletion:^(NSDictionary *info) {
    // info 包含 network、wifiName、wifiBssid、isvpn、proxied 等字段
}];
```

**Swift**

```swift
NetworkService.getWiFiNetworkInfo { wifiInfo in
    let ssid = wifiInfo?["ssid"] as? String ?? "null"
    let bssid = wifiInfo?["bssid"] as? String ?? "null"
    // 处理 WiFi 信息
}

// 获取完整网络通信信息（异步）
NetworkService.getCommunicationInfo { info in
    // info 包含 network、wifiName、wifiBssid、isvpn、proxied 等字段
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
