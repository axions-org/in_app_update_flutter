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
- Android: Immediate update flow that shows a full-screen prompt the user must accept
- Android: Flexible update flow that downloads in the background while the user keeps using the app
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

1. Open your app's App Store URL, for example `https://apps.apple.com/app/id1234567890`
2. The numeric portion after `id` is your App Store ID.

**iOS notes:**
- Requires iOS 13.0 or later
- Does not work on simulators
- Not supported in TestFlight builds. Test on a real device using a development or App Store build.

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

## Error Handling

Both iOS and Android methods can throw exceptions. Wrap calls in try-catch blocks to handle errors:

```dart
try {
  await InAppUpdateFlutter().showUpdateForIos(appStoreId: '1234567890');
} on PlatformException catch (e) {
  // e.code: STORE_ERROR, STORE_NOT_LOADED
  // e.message: description of the failure
  print('iOS update failed: ${e.code}: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

### Android error codes

| Code | Meaning |
|---|---|
| `NO_ACTIVITY` | Plugin not attached to an Activity (config change or background state) |
| `CHECK_UPDATE_FAILED` | Play Core could not check for updates (network, Play Store disabled, etc.) |
| `UPDATE_NOT_AVAILABLE` | No update available or the requested update type is not allowed |
| `ALREADY_RUNNING` | An update flow is already in progress. Wait for it to complete. |
| `COMPLETE_UPDATE_FAILED` | `completeUpdate()` could not trigger the install |

### iOS error codes

| Code | Meaning |
|---|---|
| `STORE_ERROR` | `SKStoreProductViewController` failed to load the product page |
| `STORE_NOT_LOADED` | Product page loaded but returned `false` (unexpected state) |

---

## Migration Guide (v1.x → v2.0)

### What changed

In v1.x, the plugin only supported iOS via `showUpdate()`. Version 2.0 added Android support and renamed the iOS method for clarity.

### Step-by-step

| Before (v1.x) | After (v2.0) |
|---|---|
| `InAppUpdateFlutter().showUpdate(appStoreId: '...')` | `InAppUpdateFlutter().showUpdateForIos(appStoreId: '...')` |

If you were using the deprecated `showUpdate()` method, replace it with `showUpdateForIos()`. The old method still works but will be removed in a future release.

For new Android integration, add calls to `checkUpdateAndroid()`, `startImmediateUpdateAndroid()` / `startFlexibleUpdateAndroid()`, `completeUpdateAndroid()`, and `installStateStreamAndroid` as shown in the [Android Usage](#android-usage) section.

---

## Full API Reference

### `InAppUpdateFlutter`

| Method | Returns | Platforms | Description |
|---|---|---|---|
| `showUpdateForIos({required String appStoreId})` | `Future<void>` | iOS | Present App Store product page overlay via StoreKit |
| `showUpdate({required String appStoreId})` | `Future<void>` | iOS | **Deprecated.** Use `showUpdateForIos` instead |
| `checkUpdateAndroid()` | `Future<AppUpdateInfoAndroid>` | Android | Query Play Core for available update metadata |
| `startImmediateUpdateAndroid({bool allowAssetPackDeletion = false})` | `Future<UpdateResultAndroid>` | Android | Start a full-screen blocking update flow |
| `startFlexibleUpdateAndroid({bool allowAssetPackDeletion = false})` | `Future<UpdateResultAndroid>` | Android | Start a background download update flow |
| `completeUpdateAndroid()` | `Future<void>` | Android | Trigger app restart to apply a downloaded flexible update |
| `installStateStreamAndroid` | `Stream<InstallStateAndroid>` | Android | Monitor flexible update download progress |

### Models (Android)

**`AppUpdateInfoAndroid`**, returned by `checkUpdateAndroid()`:

| Field | Type | Description |
|---|---|---|
| `updateAvailability` | `UpdateAvailabilityAndroid` | Whether an update is available |
| `availableVersionCode` | `int?` | Version code of the available update |
| `updatePriority` | `int` | Developer-assigned priority (0–5) |
| `clientVersionStalenessDays` | `int?` | Days since the update became available |
| `isImmediateUpdateAllowed` | `bool` | Whether immediate update is allowed |
| `isFlexibleUpdateAllowed` | `bool` | Whether flexible update is allowed |
| `installStatus` | `InstallStatusAndroid` | Current install status |

**`UpdateAvailabilityAndroid`**

| Value | Meaning |
|---|---|
| `unknown` | Play Core could not determine availability |
| `updateNotAvailable` | No update is available |
| `updateAvailable` | An update is available on the Play Store |
| `developerTriggeredUpdateInProgress` | An update started previously is still in progress |

**`InstallStatusAndroid`**

| Value | Meaning |
|---|---|
| `unknown` | Install status unknown |
| `pending` | Download is pending |
| `downloading` | Download is in progress |
| `downloaded` | Download complete, ready to install |
| `installing` | Update is being installed |
| `installed` | Update installed successfully |
| `failed` | Update failed |
| `canceled` | Update canceled by user |

**`UpdateResultAndroid`**

| Value | Meaning |
|---|---|
| `success` | Update accepted and completed |
| `userCanceled` | User closed the update prompt |
| `inAppUpdateFailed` | Update flow failed (error or unexpected result) |

**`InstallStateAndroid`**, emitted by `installStateStreamAndroid`:

| Field | Type | Description |
|---|---|---|
| `status` | `InstallStatusAndroid` | Current install status |
| `bytesDownloaded` | `int` | Bytes downloaded so far |
| `totalBytesToDownload` | `int` | Total bytes to download |

---

## Troubleshooting

### iOS

| Issue | Cause / Solution |
|---|---|
| `FlutterError(code: STORE_ERROR, message: "Failed to load product")` | Invalid App Store ID or no network. Verify the ID in your App Store Connect URL (`apps.apple.com/app/idXXXXXXXXX`). |
| Does nothing on simulator | `SKStoreProductViewController` is not supported on iOS simulators. Test on a real device. |
| Does nothing in TestFlight | In-app updates do not work in TestFlight builds. Use an App Store or development build. |

### Android

| Issue | Cause / Solution |
|---|---|
| `PlatformException(code: CHECK_UPDATE_FAILED)` | No Play Store installed, Play Store signed in to a different account, or no network. |
| `PlatformException(code: UPDATE_NOT_AVAILABLE)` | The update is not yet live on Play Store, or `isImmediateUpdateAllowed` / `isFlexibleUpdateAllowed` is `false` for this update. |
| `PlatformException(code: ALREADY_RUNNING)` | An update was already started. Wait for it to finish before starting another. |
| `completeUpdateAndroid()` does nothing | Only call after `installStateStreamAndroid` emits `InstallStatusAndroid.downloaded`. |
| Flexible update progress not updating | Ensure you are subscribed to `installStateStreamAndroid` before calling `startFlexibleUpdateAndroid()`. |

---

## License

[MIT License](LICENSE)

---

## Contributing

Bug reports, feature requests, and pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full guide.
