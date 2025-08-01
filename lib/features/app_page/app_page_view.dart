import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:keybg/features/app_page/app_page_controller.dart';

class AppPageView extends GetView<AppDeviceController> {
  final TextEditingController _wallpaperUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool showTabs = controller.showHiddenApps.value;

      final appBar = AppBar(
        title: Obx(() => Text(
          'App Manager',
          style: TextStyle(
            fontSize: controller.appBarFontSize.value,
            color: controller.appBarTextColor.value,
          ),
        )),
        backgroundColor: controller.appBarColor.value,
        elevation: 4,

        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: _showUiSettingsDialog,
          ),
        ],
        bottom: showTabs
            ? TabBar(
          tabs: [
            Tab(text: 'All Apps'),
            Tab(text: 'Hidden Apps (${controller.hiddenApps.length})'),
          ],
          labelColor: controller.appBarTextColor.value,
          unselectedLabelColor:
          controller.appBarTextColor.value.withOpacity(0.5),
          indicatorColor: controller.appBarTextColor.value,
        )
            : null,
      );

      if (showTabs) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: appBar,
            backgroundColor: Colors.grey[900],
            body: TabBarView(
              children: [
                _buildAllAppsTab(),
                _buildHiddenAppsTab(),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: appBar,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.grey[900],
          body: _buildAllAppsTab(),
        );
      }
    });
  }

  Widget _buildAllAppsTab() {
    return Stack(
      children: [
        Obx(() => controller.wallpaperPath.isNotEmpty
            ? Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(File(controller.wallpaperPath.value)),
              fit: BoxFit.cover,
            ),
          ),
        )
            : Container(color: Colors.grey[900])),
        Obx(
              () => Container(
            height: MediaQuery.of(Get.context!).size.height*2,
            width: MediaQuery.of(Get.context!).size.width,
            color: Colors.black.withOpacity(controller.opacity.value),
          ),
        ),
        Column(
          children: [
            SizedBox(height: 50,),
            Obx(() => controller.showSearchBar.value
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search apps...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  suffixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.transparent,
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) =>
                controller.searchQuery.value = value,
              ),
            )
                : SizedBox(height: 16)),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                return _buildAppGrid(controller.filteredApps);
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHiddenAppsTab() {
    return Obx(() {
      if (controller.hiddenApps.isEmpty) {
        return Center(
          child: Text(
            'No hidden apps',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.hiddenApps.length,
        itemBuilder: (context, index) {
          final packageName = controller.hiddenApps[index];
          final app = controller.apps
              .firstWhere((app) => app.packageName == packageName);
          return Card(
            color: Colors.grey[800],
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: app.icon != null
                  ? Image.memory(
                app.icon!,
                width: controller.iconSize.value,
                height: controller.iconSize.value,
              )
                  : Icon(Icons.apps, size: controller.iconSize.value),
              title: Text(
                app.name,
                style: TextStyle(
                  fontSize: controller.fontSize.value,
                  color: controller.appTextColor.value,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () => controller.launchApp(packageName),
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility, color: Colors.white),
                    onPressed: () => controller.toggleHideApp(packageName),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildAppGrid(List<AppInfo> apps) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.white),
            Text(
              'No apps found',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () => controller.loadInstalledApps(),
              child: Text('Retry', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: controller.gridCount.value,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent:
        controller.iconSize.value + controller.fontSize.value * 2.5 + 24,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) => _buildAppItem(apps[index]),
    );
  }

  Widget _buildAppItem(AppInfo app) {
    final isHidden = controller.hiddenApps.contains(app.packageName);

    return GestureDetector(
      onTap: () => controller.launchApp(app.packageName),
      onLongPress: () => _showAppOptions(app),
      child: Obx(() => Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                app.icon != null
                    ? Image.memory(
                  app.icon!,
                  width: controller.iconSize.value,
                  height: controller.iconSize.value,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.apps,
                    size: controller.iconSize.value,
                    color: Colors.white,
                  ),
                )
                    : Icon(
                  Icons.apps,
                  size: controller.iconSize.value,
                  color: Colors.white,
                ),
                if (isHidden)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.visibility_off,
                        size: 16, color: Colors.red),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              app.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: controller.fontSize.value,
                color: controller.appTextColor.value,
              ),
            ),
            Expanded(child: SizedBox(),)
          ],
        ),
      )),
    );
  }

  void _showAppOptions(AppInfo app) {
    final isHidden = controller.hiddenApps.contains(app.packageName);

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('App Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                _showAppInfo(app);
              },
            ),
            ListTile(
              leading: Icon(
                isHidden ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              title: Text(
                isHidden ? 'Show App' : 'Hide App',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                controller.toggleHideApp(app.packageName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAppInfo(AppInfo app) async {
    InstalledApps.openSettings(app.packageName);
    await Future.delayed(Duration(seconds: 5));
    controller.checkForPackage(app.packageName);
  }

  void _showUiSettingsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Color(0xFF2E2E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        contentPadding: const EdgeInsets.all(0), // Remove padding to allow full control
        title: Row(
          children: [
            Icon(Icons.palette_outlined, color: Colors.white),
            SizedBox(width: 10),
            Text('UI Settings', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          height: 600,
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Obx(
                ()=> Column(
                children: [
                  ExpansionTile(
                    title: Text('App Grid & Icons', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    leading: Icon(Icons.grid_view_outlined, color: Colors.white),
                    initiallyExpanded: true,
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      _buildSettingsSlider(
                        title: 'Grid Columns',
                        value: controller.gridCount.value.toDouble(),
                        min: 2, max: 8, divisions: 6,
                        label: controller.gridCount.value.toString(),
                        onChanged: (v) => controller.gridCount.value = v.toInt(),
                      ),
                      _buildSettingsSlider(
                        title: 'Icon Size',
                        value: controller.iconSize.value,
                        min: 30, max: 80, divisions: 10,
                        label: controller.iconSize.value.round().toString(),
                        onChanged: (v) => controller.iconSize.value = v,
                      ),
                      _buildSettingsSlider(
                        title: 'Font Size',
                        value: controller.fontSize.value,
                        min: 10, max: 24, divisions: 14,
                        label: controller.fontSize.value.round().toString(),
                        onChanged: (v) => controller.fontSize.value = v,
                      ),
                      _buildColorSelector(
                        'Text Color',
                        controller.appTextColor.value,
                            (color) => controller.appTextColor.value = color,
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('App Bar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    leading: Icon(Icons.view_day_outlined, color: Colors.white),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      _buildMaterialColorSelector(
                        'Bar Color',
                        controller.appBarColor.value,
                            (c) => controller.appBarColor.value = c,
                      ),
                      _buildColorSelector(
                        'Text Color',
                        controller.appBarTextColor.value,
                            (c) => controller.appBarTextColor.value = c,
                      ),
                      _buildSettingsSlider(
                        title: 'Font Size',
                        value: controller.appBarFontSize.value,
                        min: 16, max: 24, divisions: 8,
                        label: controller.appBarFontSize.value.round().toString(),
                        onChanged: (v) => controller.appBarFontSize.value = v,
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('Background', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    leading: Icon(Icons.layers_outlined, color: Colors.white),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      _buildSettingsSlider(
                        title: 'Overlay Opacity',
                        value: controller.opacity.value,
                        min: 0, max: 1, divisions: 10,
                        label: (controller.opacity.value * 100).round().toString() + '%',
                        onChanged: (v) {
                          controller.opacity.value = v;

                        },
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                        icon: Icon(Icons.image_outlined, color: Colors.white70),
                        label: Text('Set Wallpaper'),
                        onPressed: () {
                          Get.back();
                          _showWallpaperDialog();
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text('Behavior', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    leading: Icon(Icons.toggle_on_outlined, color: Colors.white),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      SwitchListTile(
                        title: Text('Show Search Bar', style: TextStyle(color: Colors.white)),
                        value: controller.showSearchBar.value,
                        onChanged: (v) => controller.showSearchBar.value = v,
                        activeColor: controller.appBarColor.value,
                        secondary: Icon(Icons.search, color: Colors.white70),
                      ),
                      SwitchListTile(
                        title: Text('Show Hidden Apps Tab', style: TextStyle(color: Colors.white)),
                        value: controller.showHiddenApps.value,
                        onChanged: (v) => controller.showHiddenApps.value = v,
                        activeColor: controller.appBarColor.value,
                        secondary: Icon(Icons.visibility_off_outlined, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.resetUiSettings();
              Get.back();
            },
            child: Text('Reset', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  ExpansionPanel _buildSettingsPanel({
    required bool isExpanded,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return ExpansionPanel(
      isExpanded: isExpanded,
      backgroundColor: Color(0xFF3C3C3C),
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(title,
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        );
      },
      body: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        width: double.infinity,
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSettingsSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(title, style: TextStyle(color: Colors.white70)),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
          activeColor: controller.appBarColor.value,
        ),
        Divider(color: Colors.white24),
      ],
    );
  }

  Widget _buildColorSelector(
      String title, Color currentColor, ValueChanged<Color> onChanged) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white70)),
      trailing: DropdownButton<Color>(
        dropdownColor: Colors.grey[800],
        value: currentColor,
        onChanged: (color) => onChanged(color!),
        items: [
          Colors.white,
          Colors.black,
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.yellow,
          Colors.orange,
          Colors.purple,
        ].map((color) {
          return DropdownMenuItem(
              value: color,
              child: Container(width: 20, height: 20, color: color));
        }).toList(),
      ),
    );
  }

  Widget _buildMaterialColorSelector(String title, MaterialColor currentColor,
      ValueChanged<MaterialColor> onChanged) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.white70)),
      trailing: DropdownButton<MaterialColor>(
        dropdownColor: Colors.grey[800],
        value: currentColor,
        onChanged: (color) => onChanged(color!),
        items: [
          Colors.blue, Colors.red, Colors.green, Colors.yellow, Colors.orange,
          Colors.purple, Colors.teal, Colors.indigo, Colors.pink, Colors.amber,
          Colors.cyan, Colors.lime, Colors.brown, Colors.grey, Colors.blueGrey,
        ].map((color) {
          return DropdownMenuItem(
              value: color,
              child: Container(width: 20, height: 20, color: color));
        }).toList(),
      ),
    );
  }

  void _showWallpaperDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text('Change Wallpaper', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wallpaperUrlController,
              decoration: InputDecoration(
                hintText: 'Paste image URL',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[700],
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.pickImage(),
              child: Text(
                'Choose from Gallery',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.appBarColor.value,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final url = _wallpaperUrlController.text.trim();
              if (url.isNotEmpty) {
                Get.back();
                await controller.downloadAndSetWallpaper(url);
              }
            },
            child: Text('Set Wallpaper', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}