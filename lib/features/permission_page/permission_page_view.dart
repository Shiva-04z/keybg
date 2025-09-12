import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keybg/features/permission_page/permission_page_controller.dart';
import 'package:keybg/services/overlay_service.dart';

class PermissionPageView extends GetView<PermissionPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Permissions'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[700],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[500]!],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'The app needs these permissions to function properly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      PermissionCard(
                        icon: Icons.admin_panel_settings,
                        title: 'Admin Permission',
                        description: 'Allows the app to perform administrative tasks',
                        permissionGranted: controller.adminPermission,
                        onRequestPermission: controller.requestAdminPermission,
                      ),
                      SizedBox(height: 16),
                      PermissionCard(
                        icon: Icons.analytics,
                        title: 'Usage Access',
                        description: 'Allows the app to collect usage statistics',
                        permissionGranted: controller.usageAccessPermission,
                        onRequestPermission: controller.requestUsageAccess,
                      ),
                      SizedBox(height: 16),
                      PermissionCard(
                        icon: Icons.battery_charging_full,
                        title: 'Battery Restriction Bypass',
                        description: 'Prevents the app from being restricted by battery optimization',
                        permissionGranted: controller.batteryRestrictionBypass,
                        onRequestPermission: controller.requestBatteryRestrictionBypass,
                      ),
                      SizedBox(height: 16),
                      PermissionCard(
                        icon: Icons.picture_in_picture,
                        title: 'Display Over Other Apps',
                        description: 'Allows the app to display content over other applications',
                        permissionGranted: controller.displayOverOtherApps,
                        onRequestPermission: controller.requestDisplayOverOtherApps,
                      ),
                      SizedBox(height: 16),
                      PermissionCard(
                        icon: Icons.notifications,
                        title: 'Notification Permission',
                        description: 'Allows the app to show notifications',
                        permissionGranted: controller.notificationPermission,
                        onRequestPermission: controller.requestNotificationPermission,
                      ),
                      SizedBox(height: 24),
                      Obx(() {
                        final allGranted = controller.adminPermission.value &&
                            controller.usageAccessPermission.value &&
                            controller.batteryRestrictionBypass.value &&
                            controller.displayOverOtherApps.value &&
                            controller.notificationPermission.value;

                        return ElevatedButton(
                          onPressed:
                               () {
                                OverlayService.showOverlay();
                               },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final RxBool permissionGranted;
  final Function onRequestPermission;

  const PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.permissionGranted,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: permissionGranted.value
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    permissionGranted.value ? 'Granted' : 'Required',
                    style: TextStyle(
                      color: permissionGranted.value
                          ? Colors.green[800]
                          : Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: permissionGranted.value
                  ? Text(
                'Permission granted',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              )
                  : ElevatedButton(
                onPressed: () => onRequestPermission(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Grant Permission'),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}