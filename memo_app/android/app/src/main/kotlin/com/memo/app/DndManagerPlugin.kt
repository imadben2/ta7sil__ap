package com.memo.app

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * DndManagerPlugin
 *
 * Platform channel plugin for controlling Android Do Not Disturb (DND) mode.
 * Allows the Flutter app to check DND permission status, request permission,
 * get current DND state, and enable/disable DND mode programmatically.
 *
 * Requires Android API 23+ (Marshmallow) for DND access.
 */
class DndManagerPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var notificationManager: NotificationManager

    companion object {
        private const val CHANNEL_NAME = "memo.app/dnd_manager"
        private const val METHOD_HAS_PERMISSION = "hasDndPermission"
        private const val METHOD_REQUEST_PERMISSION = "requestDndPermission"
        private const val METHOD_GET_STATE = "getCurrentDndState"
        private const val METHOD_SET_MODE = "setDndMode"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_HAS_PERMISSION -> {
                result.success(hasDndPermission())
            }
            METHOD_REQUEST_PERMISSION -> {
                requestDndPermission()
                result.success(null)
            }
            METHOD_GET_STATE -> {
                result.success(getCurrentDndState())
            }
            METHOD_SET_MODE -> {
                val enable = call.argument<Boolean>("enable") ?: false
                val success = setDndMode(enable)
                result.success(success)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Check if the app has DND permission
     *
     * @return true if app has notification policy access permission, false otherwise
     */
    @RequiresApi(Build.VERSION_CODES.M)
    private fun hasDndPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            notificationManager.isNotificationPolicyAccessGranted
        } else {
            false
        }
    }

    /**
     * Request DND permission by opening system settings
     *
     * Opens the notification policy access settings screen where user can grant permission.
     */
    @RequiresApi(Build.VERSION_CODES.M)
    private fun requestDndPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
        }
    }

    /**
     * Get current DND state
     *
     * @return Current interruption filter state:
     *         1 = INTERRUPTION_FILTER_ALL (normal mode, all notifications)
     *         2 = INTERRUPTION_FILTER_PRIORITY (priority only)
     *         3 = INTERRUPTION_FILTER_NONE (total silence)
     *         4 = INTERRUPTION_FILTER_ALARMS (alarms only)
     *         0 = INTERRUPTION_FILTER_UNKNOWN (unknown/error)
     */
    @RequiresApi(Build.VERSION_CODES.M)
    private fun getCurrentDndState(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            notificationManager.currentInterruptionFilter
        } else {
            NotificationManager.INTERRUPTION_FILTER_UNKNOWN
        }
    }

    /**
     * Enable or disable DND mode
     *
     * @param enable true to enable DND (alarms only), false to disable (normal mode)
     * @return true if operation succeeded, false otherwise
     */
    @RequiresApi(Build.VERSION_CODES.M)
    private fun setDndMode(enable: Boolean): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && hasDndPermission()) {
                val filter = if (enable) {
                    // INTERRUPTION_FILTER_ALARMS: Total silence except alarms
                    NotificationManager.INTERRUPTION_FILTER_ALARMS
                } else {
                    // INTERRUPTION_FILTER_ALL: Normal mode, all notifications allowed
                    NotificationManager.INTERRUPTION_FILTER_ALL
                }
                notificationManager.setInterruptionFilter(filter)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            android.util.Log.e("DndManagerPlugin", "Error setting DND mode: ${e.message}")
            false
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
