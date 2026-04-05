#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint in_app_update_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'in_app_update_flutter'
  s.version          = '2.1.0'
  s.summary          = 'Show an in-app update prompt using the native App Store product page.'
  s.description      = <<-DESC
A Flutter plugin to show an in-app update prompt using the native App Store product page on iOS, keeping users inside your app.
                       DESC
  s.homepage         = 'https://github.com/pulkit7724/in_app_update_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Pulkit' => 'pulkit7724@github.com' }
  s.source           = { :path => '.' }
  s.source_files = 'in_app_update_flutter/Sources/in_app_update_flutter/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.resource_bundles = {'in_app_update_flutter_privacy' => ['in_app_update_flutter/Sources/in_app_update_flutter/PrivacyInfo.xcprivacy']}
end
