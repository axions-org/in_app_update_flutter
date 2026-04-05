## 2.1.0

- Added `showStoreUpdateIosByBundleId()` — resolves the App Store ID from a bundle ID via the iTunes Lookup API and presents the App Store update prompt
- Added `showStoreUpdateIosByAppStoreId()` — explicit replacement for `showUpdateForIos()`, which is now deprecated
- Fixed iOS production safety issues: removed retained `flutterResult` and `controller` instance variables, pass `result` through the call chain to support concurrent calls safely
- Fixed iOS: `topViewController()` resolves the topmost presented view controller at call time instead of capturing root at registration
- Fixed iOS: added `[weak self]` and `DispatchQueue.main.async` to `loadProduct` closure to prevent retain cycle and guarantee UI calls on the main thread
- Fixed Android: explicitly unregister `InstallStateUpdatedListener` in `unregisterActivityListener()` to prevent listener leak on abrupt activity detach

## 2.0.0

- Added Android in-app updates support via Google Play's In-App Updates API
- Added `checkUpdateAndroid()` to retrieve update availability and metadata
- Added `startImmediateUpdateAndroid()` for full-screen, blocking update flow
- Added `startFlexibleUpdateAndroid()` for background download update flow
- Added `completeUpdateAndroid()` to apply a downloaded flexible update
- Added `installStateStreamAndroid` stream for monitoring flexible update download progress
- Added `AppUpdateInfoAndroid`, `InstallStateAndroid`, `InstallStatusAndroid`, `UpdateAvailabilityAndroid`, and `UpdateResultAndroid` models
- Renamed `showUpdate()` to `showUpdateForIos()` (old method is deprecated)
- Updated Android toolchain to latest stable versions

## 1.0.4

- Added Swift Package Manager (SPM) support for iOS while maintaining CocoaPods backward compatibility
- Restructured iOS plugin sources into SPM-compatible directory layout
- Updated podspec metadata (version, summary, description, homepage, author)
- Enabled PrivacyInfo.xcprivacy resource bundle
- Fixed iOS unit tests to match actual plugin API
- Shortened package description to meet pub.dev requirements

## 1.0.3
