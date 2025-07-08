package com.rishiwar.keybg;

import static android.os.UserManager.*;

import android.annotation.SuppressLint;
import android.app.WallpaperManager;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Bundle;
import android.os.UserManager;

import androidx.annotation.NonNull;

import java.net.URL;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String DPC_CHANNEL = "com.rishiwar.keybg/dpc";
    private static final String FOREGROUND_CHANNEL = "com.rishiwar.keybg/foreground";

    @SuppressLint("NewApi")
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Device Policy Controller Methods
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), DPC_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    DevicePolicyManager dpm = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
                    ComponentName admin = new ComponentName(this, MyDeviceAdminReceiver.class);
                    Context context = this;

                    switch (call.method) {
                        case "lockDevice":
                            if (dpm.isAdminActive(admin)) {
                                dpm.lockNow();
                                result.success("Device Locked");
                            } else {
                                result.error("NOT_ADMIN", "Device Admin not active", null);
                            }
                            break;

                        case "disableFactoryReset":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                dpm.addUserRestriction(admin, DISALLOW_FACTORY_RESET);
                                result.success("Factory Reset Disabled");
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "enableFactoryReset":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                dpm.clearUserRestriction(admin, DISALLOW_FACTORY_RESET);
                                result.success("Factory Reset Enabled");
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "setUSBDebugging":
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && dpm.isDeviceOwnerApp(getPackageName())) {
                                boolean enableUSB = call.argument("enable");
                                dpm.setUsbDataSignalingEnabled(enableUSB);
                                result.success("USB Debugging " + (enableUSB ? "Enabled" : "Disabled"));
                            } else {
                                result.error("UNSUPPORTED", "Only supported on Android 9+ and with Device Owner", null);
                            }
                            break;

                        case "setCamera":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                boolean enableCamera = call.argument("enable");
                                dpm.setCameraDisabled(admin, !enableCamera);
                                result.success("Camera " + (enableCamera ? "Enabled" : "Disabled"));
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "setAppInstallation":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                boolean allowInstall = call.argument("enable");
                                if (allowInstall) {
                                    dpm.clearUserRestriction(admin, DISALLOW_INSTALL_APPS);
                                } else {
                                    dpm.addUserRestriction(admin, DISALLOW_INSTALL_APPS);
                                }
                                result.success("App Installation " + (allowInstall ? "Enabled" : "Disabled"));
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "setDeveloperOptions":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                boolean enableDev = call.argument("enable");
                                if (enableDev) {
                                    dpm.clearUserRestriction(admin, DISALLOW_DEBUGGING_FEATURES);
                                } else {
                                    dpm.addUserRestriction(admin, DISALLOW_DEBUGGING_FEATURES);
                                }
                                result.success("Developer Options " + (enableDev ? "Enabled" : "Disabled"));
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "setHardReset":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                boolean allow = call.argument("enable");
                                if (allow) {
                                    dpm.clearUserRestriction(admin, DISALLOW_FACTORY_RESET);
                                } else {
                                    dpm.addUserRestriction(admin, DISALLOW_FACTORY_RESET);
                                }
                                result.success("Hard Reset " + (allow ? "Enabled" : "Disabled"));
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "setSoftBoot":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                boolean disablePowerOptions = call.argument("enable") == Boolean.FALSE;

                                if (disablePowerOptions) {
                                    dpm.addUserRestriction(admin, DISALLOW_SAFE_BOOT);
                                    dpm.setLockTaskPackages(admin, new String[]{getPackageName()});
                                    startLockTask();

                                    result.success("Power options disabled via Lock Task Mode");
                                } else {
                                    dpm.clearUserRestriction(admin, DISALLOW_SAFE_BOOT);
                                    stopLockTask();
                                    result.success("Power options enabled");
                                }
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "setWallpaper":
                            try {
                                String wallpaperUrl = call.argument("url");
                                new Thread(() -> {
                                    try {
                                        Bitmap bitmap = BitmapFactory.decodeStream(new URL(wallpaperUrl).openStream());
                                        WallpaperManager.getInstance(context).setBitmap(bitmap);
                                        runOnUiThread(() -> result.success("Wallpaper set"));
                                    } catch (Exception e) {
                                        runOnUiThread(() -> result.error("WALLPAPER_ERROR", e.getMessage(), null));
                                    }
                                }).start();
                            } catch (Exception e) {
                                result.error("WALLPAPER_ERROR", e.getMessage(), null);
                            }
                            break;

                        case "playWarningAudio":
                            try {
                                MediaPlayer player = MediaPlayer.create(context, R.raw.warning_sound);
                                player.start();
                                result.success("Audio played");
                            } catch (Exception e) {
                                result.error("AUDIO_ERROR", e.getMessage(), null);
                            }
                            break;

                        case "blockApps":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                List<String> apps = call.argument("apps");
                                for (String pkg : apps) {
                                    dpm.setApplicationHidden(admin, pkg, true);
                                }
                                result.success("Apps blocked");
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "disableIncomingCalls":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                // Hide phone and dialer apps to block incoming call UI
                                dpm.setApplicationHidden(admin, "com.android.phone", true);
                                dpm.setApplicationHidden(admin, "com.android.dialer", true);
                                result.success("Incoming calls disabled");
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "enableIncomingCalls":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                // Unhide phone and dialer apps
                                dpm.setApplicationHidden(admin, "com.android.phone", false);
                                dpm.setApplicationHidden(admin, "com.android.dialer", false);
                                result.success("Incoming calls enabled");
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "disableOutgoingCalls":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                // Block outgoing calls
                                dpm.addUserRestriction(admin, UserManager.DISALLOW_OUTGOING_CALLS);
                                result.success("Outgoing calls disabled");
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        case "enableOutgoingCalls":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                // Allow outgoing calls
                                dpm.clearUserRestriction(admin, UserManager.DISALLOW_OUTGOING_CALLS);
                                result.success("Outgoing calls enabled");
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;


                        case "setPassword":
                            if (dpm.isDeviceOwnerApp(getPackageName())) {
                                String password = call.argument("password");
                                dpm.resetPassword(password, 0);
                                result.success("Password changed");
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                });

        // Foreground service channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), FOREGROUND_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    Intent intent = new Intent(this, MyForegroundService.class);
                    switch (call.method) {
                        case "startService":
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(intent);
                            } else {
                                startService(intent);
                            }
                            result.success("Service started");
                            break;

                        case "stopService":
                            stopService(intent);
                            result.success("Service stopped");
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }
}
