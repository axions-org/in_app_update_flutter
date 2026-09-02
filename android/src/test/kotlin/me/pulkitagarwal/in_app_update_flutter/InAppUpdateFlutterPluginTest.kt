package me.pulkitagarwal.in_app_update_flutter

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.Mockito

internal class InAppUpdateFlutterPluginTest {
    @Test
    fun onMethodCall_checkForUpdateAndroid_withoutActivity_returnsError() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("checkForUpdateAndroid", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
    }

    @Test
    fun onMethodCall_startImmediateUpdateAndroid_withoutActivity_returnsError() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("startImmediateUpdateAndroid", mapOf("allowAssetPackDeletion" to false))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
    }

    @Test
    fun onMethodCall_startFlexibleUpdateAndroid_withoutActivity_returnsError() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("startFlexibleUpdateAndroid", mapOf("allowAssetPackDeletion" to false))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
    }

    @Test
    fun onMethodCall_completeUpdateAndroid_withoutActivity_returnsError() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("completeUpdateAndroid", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error("NO_ACTIVITY", "Plugin is not attached to an activity", null)
    }

    @Test
    fun onMethodCall_unknownMethod_returnsNotImplemented() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("unknownMethod", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }

    @Test
    fun onMethodCall_showStoreUpdateIos_returnsNotImplemented() {
        val plugin = InAppUpdateFlutterPlugin()

        val call = MethodCall("showStoreUpdateIos", mapOf("appStoreId" to "544007664"))
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }
}
