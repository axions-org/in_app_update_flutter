import 'package:in_app_update_flutter/src/models/models.dart';
import 'package:in_app_update_flutter/src/platform_interface/in_app_update_flutter_platform_interface.dart';

export 'package:in_app_update_flutter/src/models/models.dart';

/// A Flutter plugin for in-app updates.
///
/// On iOS, use [showUpdateForIos] to present the App Store product page
/// using StoreKit.
///
/// On Android, use [checkUpdateAndroid] to check for updates via Google Play's
/// In-App Updates API, then [startImmediateUpdateAndroid] or
/// [startFlexibleUpdateAndroid] to start the update flow.
class InAppUpdateFlutter {
  /// Shows the platform-specific in-app update UI.
  ///
  /// [appStoreId] is the numeric App Store ID of your app
  /// (found in your App Store Connect URL).
  @Deprecated(
    'Use showStoreUpdateIosByAppStoreId() on iOS or checkUpdateAndroid() + '
    'startImmediateUpdateAndroid()/startFlexibleUpdateAndroid() on Android',
  )
  Future<void> showUpdate({required String appStoreId}) {
    // ignore: deprecated_member_use_from_same_package
    return InAppUpdateFlutterPlatform.instance
        .showUpdate(appStoreId: appStoreId);
  }

  /// iOS: Shows the App Store product page overlay via StoreKit.
  ///
  /// [appStoreId] is the numeric App Store ID of your app
  /// (found in your App Store Connect URL).
  @Deprecated('Use showStoreUpdateIosByAppStoreId() instead.')
  Future<void> showUpdateForIos({required String appStoreId}) {
    return InAppUpdateFlutterPlatform.instance
        .showStoreUpdateIosByAppStoreId(appStoreId: appStoreId);
  }

  /// iOS: Shows the App Store product page overlay via StoreKit.
  ///
  /// [appStoreId] is the numeric App Store ID of your app
  /// (found in your App Store Connect URL).
  Future<void> showStoreUpdateIosByAppStoreId({required String appStoreId}) {
    return InAppUpdateFlutterPlatform.instance
        .showStoreUpdateIosByAppStoreId(appStoreId: appStoreId);
  }

  /// iOS: Resolves the App Store ID from [bundleId] via the iTunes Lookup API,
  /// then shows the App Store product page overlay via StoreKit.
  ///
  /// Throws a [PlatformException] if:
  /// - The network request fails (`NETWORK_ERROR`)
  /// - The bundle ID is not found on the App Store (`BUNDLE_ID_NOT_FOUND`)
  /// - The API returns an unexpected response (`INVALID_RESPONSE`)
  Future<void> showStoreUpdateIosByBundleId({required String bundleId}) {
    return InAppUpdateFlutterPlatform.instance
        .showStoreUpdateIosByBundleId(bundleId: bundleId);
  }

  /// Android: Checks whether an in-app update is available via Play Core.
  ///
  /// Returns an [AppUpdateInfoAndroid] containing update metadata such as
  /// availability, version code, priority, staleness, and allowed update types.
  Future<AppUpdateInfoAndroid> checkUpdateAndroid() {
    return InAppUpdateFlutterPlatform.instance.checkUpdateAndroid();
  }

  /// Android: Starts the immediate (full-screen, blocking) update flow.
  ///
  /// The user must accept the update to continue using the app. If the user
  /// closes the update screen, [UpdateResultAndroid.userCanceled] is returned.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startImmediateUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    return InAppUpdateFlutterPlatform.instance.startImmediateUpdateAndroid(
      allowAssetPackDeletion: allowAssetPackDeletion,
    );
  }

  /// Android: Starts the flexible (background download) update flow.
  ///
  /// The update downloads in the background while the user continues
  /// using the app. Listen to [installStateStreamAndroid] for download
  /// progress, and call [completeUpdateAndroid] when the download is complete.
  ///
  /// If [allowAssetPackDeletion] is `true`, the system may delete asset packs
  /// to free up storage for the update.
  Future<UpdateResultAndroid> startFlexibleUpdateAndroid({
    bool allowAssetPackDeletion = false,
  }) {
    return InAppUpdateFlutterPlatform.instance.startFlexibleUpdateAndroid(
      allowAssetPackDeletion: allowAssetPackDeletion,
    );
  }

  /// Android: Completes a flexible update by triggering an app restart.
  ///
  /// Call this after [installStateStreamAndroid] reports
  /// [InstallStatusAndroid.downloaded].
  Future<void> completeUpdateAndroid() {
    return InAppUpdateFlutterPlatform.instance.completeUpdateAndroid();
  }

  /// Android: A stream of install state changes during a flexible update.
  ///
  /// Emits [InstallStateAndroid] events with download progress and status.
  Stream<InstallStateAndroid> get installStateStreamAndroid {
    return InAppUpdateFlutterPlatform.instance.installStateStreamAndroid;
  }
}
