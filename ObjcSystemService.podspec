#
# Be sure to run `pod lib lint ObjcSystemService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
# 子模块与 Classes 下目录对应：Broken / Device / Network / Storage / Time；System 为 SystemService 聚合层。
# 按需集成示例：
#   pod 'ObjcSystemService'                          # 默认 System（含全部子模块）
#   pod 'ObjcSystemService/Device'                   # 仅 ObjcSystemService/Classes/Device
#   pod 'ObjcSystemService/Network', 'ObjcSystemService/Storage'  # 多选组合
# Swift/OC 仍使用同一模块名：import ObjcSystemService 或 #import <ObjcSystemService/...>，未选中的子模块不会参与编译链接。
#

Pod::Spec.new do |s|
  s.name             = 'ObjcSystemService'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ObjcSystemService.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/yanwenbo78201/ObjcSystemService'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yanwenbo78201' => 'yanwenbo78201@gmail.com' }
  s.source           = { :git => 'https://github.com/yanwenbo78201/ObjcSystemService.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.requires_arc = true

  # 未写子路径时安装「System」及其依赖，行为与原先全量引入一致
  s.default_subspecs = 'System'

  # 生成 Clang 模块，Swift 可 import ObjcSystemService
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES'
  }

  s.subspec 'Broken' do |ss|
    ss.source_files = 'ObjcSystemService/Classes/Broken/**/*.{h,m}'
    ss.public_header_files = 'ObjcSystemService/Classes/Broken/**/*.h'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'Device' do |ss|
    ss.source_files = 'ObjcSystemService/Classes/Device/**/*.{h,m}'
    ss.public_header_files = 'ObjcSystemService/Classes/Device/**/*.h'
    ss.frameworks = 'Foundation', 'UIKit', 'AppTrackingTransparency', 'AdSupport'
  end

  s.subspec 'Network' do |ss|
    ss.source_files = 'ObjcSystemService/Classes/Network/**/*.{h,m}'
    ss.public_header_files = 'ObjcSystemService/Classes/Network/**/*.h'
    ss.frameworks = 'Foundation', 'CoreTelephony', 'SystemConfiguration'
  end

  s.subspec 'Storage' do |ss|
    ss.source_files = 'ObjcSystemService/Classes/Storage/**/*.{h,m}'
    ss.public_header_files = 'ObjcSystemService/Classes/Storage/**/*.h'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'Time' do |ss|
    ss.source_files = 'ObjcSystemService/Classes/Time/**/*.{h,m}'
    ss.public_header_files = 'ObjcSystemService/Classes/Time/**/*.h'
    ss.frameworks = 'Foundation'
  end

  s.subspec 'System' do |ss|
    ss.source_files = 'ObjcSystemService/Classes/SystemService.{h,m}'
    ss.public_header_files = 'ObjcSystemService/Classes/SystemService.h'
    ss.dependency 'ObjcSystemService/Broken'
    ss.dependency 'ObjcSystemService/Device'
    ss.dependency 'ObjcSystemService/Network'
    ss.dependency 'ObjcSystemService/Storage'
    ss.dependency 'ObjcSystemService/Time'
    ss.frameworks = 'Foundation'
  end

  # s.resource_bundles = {
  #   'ObjcSystemService' => ['ObjcSystemService/Assets/*.png']
  # }

  # s.dependency 'AFNetworking', '~> 2.3'
end
