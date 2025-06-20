package com.rishiwar.keybg;


import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.os.Bundle;
import android.os.UserManager;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.rishiwar.keybg/dpc";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    DevicePolicyManager dpm = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
                    ComponentName admin = new ComponentName(this, MyDeviceAdminReceiver.class);

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
                                dpm.addUserRestriction(admin, UserManager.DISALLOW_FACTORY_RESET);
                                result.success("Factory Reset Disabled");
                            } else {
                                result.error("NOT_OWNER", "Not a device owner app", null);
                            }
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }
}
