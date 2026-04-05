// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:in_app_update_flutter/in_app_update_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showStoreUpdateIosByAppStoreId test', (WidgetTester tester) async {
    final InAppUpdateFlutter plugin = InAppUpdateFlutter();
    if (Platform.isIOS) {
      await plugin.showStoreUpdateIosByAppStoreId(appStoreId: '544007664');
    } else if (Platform.isAndroid) {
      final info = await plugin.checkUpdateAndroid();
      expect(info, isA<AppUpdateInfoAndroid>());
    }
  });
}
