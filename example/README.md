# in_app_update_flutter_example

A complete working example demonstrating how to use the `in_app_update_flutter` plugin on both iOS and Android.

## What it shows

- **iOS**: A single button that presents the App Store product page via StoreKit (`SKStoreProductViewController`).
- **Android**: A full step-by-step flow:
  1. **Check** for an available update via Play Core.
  2. **Start an immediate** (blocking) update or **flexible** (background) update.
  3. **Monitor** flexible update download progress with a progress bar.
  4. **Complete** the flexible update to restart the app and install.

## Running the example

```bash
cd example
flutter run
```

- **iOS**: Requires a real device (simulator not supported by StoreKit). Use your own App Store ID in `lib/main.dart`.
- **Android**: Requires a device with the Play Store installed and signed in. The app must be published on the Play Store with an update ready to test.

## Learn more

See the [plugin README](https://github.com/axions-org/in_app_update_flutter) for full documentation.
