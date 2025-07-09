package com.rishiwar.keybg;


import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

public class MyDeviceAdminReceiver extends DeviceAdminReceiver {
    @Override
    public void onEnabled(Context context, Intent intent) {
        Toast.makeText(context, "Device Admin Enabled", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onDisabled(Context context, Intent intent) {
        Toast.makeText(context, "Device Admin Disabled", Toast.LENGTH_SHORT).show();
    }



    @Override
    public void onProfileProvisioningComplete(Context context, Intent intent) {
        // Launch main activity after provisioning
        Intent launch = new Intent(context, MainActivity.class)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(launch);
    }
}
