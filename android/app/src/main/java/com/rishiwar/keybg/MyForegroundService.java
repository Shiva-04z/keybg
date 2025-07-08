package com.rishiwar.keybg;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.core.app.NotificationCompat;

import com.google.firebase.FirebaseApp;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class MyForegroundService extends Service {
    private static final String CHANNEL_ID = "EMI_PRO_FOREGROUND_CHANNEL";
    private static final String USER_ID = "-OTC7uPVN_8n5tqJY_5b"; // Replace dynamically if needed

    @Override
    public void onCreate() {
        super.onCreate();

        try {
            // Initialize Firebase explicitly (safe to call multiple times)
            FirebaseApp.initializeApp(this);
            Log.d("EMIPro", "FirebaseApp initialized successfully");
        } catch (Exception e) {
            Log.e("EMIPro", "FirebaseApp initialization failed", e);
        }

        createNotificationChannel();

        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("EMI Pro Active")
                .setContentText("Monitoring device and payment status")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build();

        startForeground(101, notification);
        Log.d("EMIPro", "Foreground service started");
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        bindLockCheckListener();
        return START_STICKY;
    }

    private void bindLockCheckListener() {
        try {
            DatabaseReference lockRef = FirebaseDatabase.getInstance()
                    .getReference("users")
                    .child(USER_ID)
                    .child("features")
                    .child("isLockEnable");

            lockRef.addValueEventListener(new ValueEventListener() {
                @Override
                public void onDataChange(DataSnapshot snapshot) {
                    Object rawValue = snapshot.getValue();
                    Log.d("EMIPro", "Snapshot raw value: " + rawValue);

                    Boolean isLockEnable = snapshot.getValue(Boolean.class);
                    Log.d("EMIPro", "Parsed isLockEnable = " + isLockEnable);

                    if (Boolean.TRUE.equals(isLockEnable)) {
                        Log.d("EMIPro", "Launching app due to lock enabled");
                        launchApp();
                    }
                }

                @Override
                public void onCancelled(DatabaseError error) {
                    Log.e("EMIPro", "Firebase error: " + error.getMessage(), error.toException());
                }
            });
        } catch (Exception e) {
            Log.e("EMIPro", "Error binding Firebase listener", e);
        }
    }

    private void launchApp() {
        try {
            Intent launchIntent = new Intent(this, MainActivity.class);
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(launchIntent);
            Log.d("EMIPro", "MainActivity launched");
        } catch (Exception e) {
            Log.e("EMIPro", "Error launching MainActivity", e);
        }
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "EMI Pro Foreground Service",
                    NotificationManager.IMPORTANCE_LOW);
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
                Log.d("EMIPro", "Notification channel created");
            } else {
                Log.e("EMIPro", "NotificationManager is null, cannot create channel");
            }
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
