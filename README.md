# in_app_update_flutter

A Flutter plugin for in-app updates on both iOS and Android.

On **iOS**, it presents the App Store product page using `SKStoreProductViewController` (StoreKit), keeping users inside the app during the update flow. On **Android**, it integrates with Google Play's In-App Updates API to support both immediate (blocking) and flexible (background) update flows.

---

## Screenshots

| iOS | Android Immediate | Android Flexible |
|-----|------------------|-----------------|
| ![iOS in-app update](https://raw.githubusercontent.com/axions-org/in_app_update_flutter/production/assets/screenshots/ios-in-app-update.png) | ![Android immediate update](https://raw.githubusercontent.com/axions-org/in_app_update_flutter/production/assets/screenshots/android-immediate-update.png) | ![Android flexible update](https://raw.githubusercontent.com/axions-org/in_app_update_flutter/production/assets/screenshots/android-flexible-update.png) |

---

## Features

- iOS: Show the App Store update prompt using `SKStoreProductViewController` without navigating users away from the app
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
  in_app_update_flutter: ^3.0.0
```

Then run:

```bash
flutter pub get
```

---

## iOS Usage

Pass your numeric App Store ID to `showUpdateForIos`. The ID can be found in your App Store Connect URL or the app's public App Store link.

```dart
import 'package:in_app_update_flutter/in_app_update_flutter.dart';

await InAppUpdateFlutter().showUpdateForIos(appStoreId: '1234567890');
```

**How to find your App Store ID:**

1. Open your app's App Store URL — for example: `https://apps.apple.com/app/id1234567890`
2. The numeric portion after `id` is your App Store ID.

**iOS notes:**
- Requires iOS 13.0 or later
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
    if (state.status == InstallStatusAndroid.downloaded) {
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
