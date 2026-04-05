# in_app_update_flutter

A Flutter plugin for in-app updates on both iOS and Android.

On **iOS**, it presents the App Store product page using `SKStoreProductViewController` (StoreKit), keeping users inside the app during the update flow. On **Android**, it integrates with Google Play's In-App Updates API to support both immediate (blocking) and flexible (background) update flows.

---

## Features

- iOS: Show the App Store update prompt using `SKStoreProductViewController` without navigating users away from the app, via App Store ID or bundle ID
- iOS: Native Swift implementation with zero AppDelegate configuration required
- iOS: Supports both Swift Package Manager (SPM) and CocoaPods
- Android: Check update availability and metadata via the Play Core API
- Android: Immediate update flow — full-screen, blocking prompt the user must accept
- Android: Flexible update flow — background download while the user continues using the app
- Android: Install state stream for monitoring flexible update download progress
- Works on Flutter with a simple, unified API

---

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_update_flutter: ^2.1.0
```

Then run:

```bash
flutter pub get
```

---

## iOS Usage

There are two ways to trigger the App Store update prompt on iOS.

### Option 1: Using the App Store ID (recommended)

Pass the numeric App Store ID directly. This requires no network lookup, works offline, and is the most reliable option.

```dart
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

await InAppUpdateFlutter().showStoreUpdateIosByAppStoreId(appStoreId: '1234567890');
```

**How to find your App Store ID:**

1. Open your app's App Store URL — for example: `https://apps.apple.com/app/id1234567890`
2. The numeric portion after `id` is your App Store ID.

### Option 2: Using the Bundle ID

Pass your app's bundle ID instead. The plugin resolves the numeric App Store ID automatically via the iTunes Lookup API, then presents the update prompt.

**Trade-off:** This option requires a network request before the prompt can appear. If the device is offline, the bundle ID is not found on the App Store, or the API returns an unexpected response, the call will throw a `PlatformException`. Use Option 1 if you already know your App Store ID.

```dart
await InAppUpdateFlutter().showStoreUpdateIosByBundleId(bundleId: 'com.example.myapp');
```

Since this involves a network call, it can fail. Always wrap it in a `try/catch`:

```dart
try {
  await InAppUpdateFlutter().showStoreUpdateIosByBundleId(bundleId: 'com.example.myapp');
} on PlatformException catch (e) {
  switch (e.code) {
    case 'NETWORK_ERROR':
      // iTunes Lookup API was unreachable
    case 'BUNDLE_ID_NOT_FOUND':
      // No app found for this bundle ID on the App Store
    case 'INVALID_RESPONSE':
      // Unexpected response from the iTunes Lookup API
    case 'STORE_ERROR':
      // SKStoreProductViewController failed to load
  }
}
```

**iOS notes:**
- Requires iOS 12.0 or later
- Does not work on simulators
- Not supported in TestFlight builds — test on a real device using a development or App Store build

---

## Android Usage

Android uses Google Play's In-App Updates API. The typical flow is:

1. Call `checkUpdateAndroid()` to retrieve update availability and metadata.
2. Based on the result, start either an immediate or flexible update.

### Immediate Update

An immediate update presents a full-screen prompt that the user must complete before continuing. Use this for critical updates.

```dart
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

final plugin = InAppUpdateFlutter();

final info = await plugin.checkUpdateAndroid();

if (info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable &&
    info.isImmediateUpdateAllowed) {
  final result = await plugin.startImmediateUpdateAndroid();
  // result is UpdateResultAndroid.success or UpdateResultAndroid.userCanceled
}
```

### Flexible Update

A flexible update downloads in the background while the user continues using the app. When the download completes, call `completeUpdateAndroid()` to apply the update.

```dart
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

final plugin = InAppUpdateFlutter();

final info = await plugin.checkUpdateAndroid();

if (info.updateAvailability == UpdateAvailabilityAndroid.updateAvailable &&
    info.isFlexibleUpdateAllowed) {
  await plugin.startFlexibleUpdateAndroid();

  plugin.installStateStreamAndroid.listen((state) {
    if (state.installStatus == InstallStatusAndroid.downloaded) {
      plugin.completeUpdateAndroid();
    }
  });
}
```

### AppUpdateInfoAndroid fields

| Field | Type | Description |
|---|---|---|
| `updateAvailability` | `UpdateAvailabilityAndroid` | Whether an update is available |
| `availableVersionCode` | `int?` | Version code of the available update |
| `updatePriority` | `int` | Developer-assigned priority (0–5) |
| `clientVersionStalenessDays` | `int?` | Days since the update became available |
| `isImmediateUpdateAllowed` | `bool` | Whether immediate update is allowed |
| `isFlexibleUpdateAllowed` | `bool` | Whether flexible update is allowed |
| `installStatus` | `InstallStatusAndroid` | Current install status |

---

## Example

A complete working example is available in the [`example/`](example) directory.

```bash
cd example
flutter run
```

---

## License

[MIT License](LICENSE)

---

## Contributing

Pull requests and feedback are welcome. For major changes, please open an issue first to discuss what you would like to change.
