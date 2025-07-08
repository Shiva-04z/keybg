import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keybg/features/home_page/home_page_controller.dart';
import 'package:keybg/models/features.dart';
import 'package:keybg/naviagtion/RoutesConstant.dart';
import 'package:keybg/services/dpc_service.dart';

class HomePageView extends GetView<HomePageController> {
  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> pinControllers = List.generate(
      6,
      (_) => TextEditingController(),
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('EMI Payment Portal'),
          centerTitle: true,
          backgroundColor: Colors.white,
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Retailer'),
              Tab(icon: Icon(Icons.credit_card), text: 'EMI Status'),
              Tab(icon: Icon(Icons.lock), text: 'Unlock'),
              Tab(icon: Icon(Icons.settings), text: 'Features'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.fullscreen),
              onPressed: () {
                Get.toNamed(RoutesConstant.testPage);
                 },
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: TabBarView(
            children: [
              // Retailer Tab
              _buildRetailerTab(context),

              // EMI Status Tab
              _buildEmiStatusTab(context),

              // Unlock Tab
              _buildUnlockTab(context, pinControllers),

              // Features Tab
              _buildFeaturesTab(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetailerTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Obx(() {
        final retailer = controller.retailer.value;
        final features = controller.features.value;

        if (retailer == null || features == null) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Retailer Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.store, color: Colors.blue),
                      title: Text('Shop Name'),
                      subtitle: Text(retailer.shopName),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.blue),
                      title: Text('Email'),
                      subtitle: Text(retailer.email),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.blue),
                      title: Text('Phone'),
                      subtitle: Text(retailer.phoneNumber),
                    ),
                    Divider(),
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: Icon(Icons.qr_code, color: Colors.blue),
                        title: Text('QR Code'),
                        subtitle: Text('Make Payment via this QR'),
                        children: [
                          SizedBox(height: 10),
                          Obx(
                            () => Center(
                              child: Text(
                                " To Pay: ${controller.emi.value?.paymentAmount}",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 300,
                            width: 200,

                            child: Image(image: NetworkImage(retailer.qrUrl)),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  Widget _buildEmiStatusTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Obx(() {
        final emi = controller.emi.value;

        if (emi == null) {
          return Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final isPaymentDue = emi.dueDate.isBefore(now);

        return Column(
          children: [
            // Show payment due card only if payment is due
            if (isPaymentDue) ...[
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Card(
                    elevation: 4,
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Payment Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          SizedBox(height: 16),
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'EMI PAYMENT DUE',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please make payment before due date',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ] else ...[
              Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          color: Colors.green[50],
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'No Payment Due',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Icon(
                                    Icons.check_circle,
                                    size: 48,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Next Payment Date:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    emi.dueDate.toLocal().toString().split(' ')[0],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
            // EMI Overview Card (always shown, but now below payment card)
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 4,
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMI Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildEmiDetailRow('EMI Name', emi.emiName),
                        _buildEmiDetailRow(
                          'Total Amount',
                          '₹${emi.totalAmount}',
                        ),
                        _buildEmiDetailRow(
                          'Amount Left',
                          '₹${emi.totalAmountLeft}',
                        ),
                        _buildEmiDetailRow('EMI Left', '${emi.emiLeft}'),
                        _buildEmiDetailRow(
                          'Payment Amount',
                          '₹${emi.paymentAmount}',
                        ),
                        _buildEmiDetailRow(
                          'Due Date',
                          emi.dueDate.toLocal().toString().split(' ')[0],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmiDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockTab(
    BuildContext context,
    List<TextEditingController> pinControllers,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // PIN Entry Section
          Text(
            'Enter 6-Digit Unlocking PIN',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return Container(
                width: 40,
                margin: EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: pinControllers[index],
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    if (value.length == 1 && index < 5) {
                      FocusScope.of(context).nextFocus();
                    } else if (value.isEmpty && index > 0) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                ),
              );
            }),
          ),
          SizedBox(height: 32),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final enteredPin =
                      pinControllers
                          .map((controller) => controller.text)
                          .join();
                  if (enteredPin.length == 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Processing payment...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    // Process payment here
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter 6-digit PIN'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },

                icon: Icon(Icons.key, color: Colors.white),
                label: Text(
                  'Submit Code',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 32),

          // Help Section
          Obx(() {
            final retailer = controller.retailer.value;
            if (retailer == null) return SizedBox();

            return Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Need Help? Contact Retailer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.blue),
                      title: Text('Phone Number'),
                      subtitle: Text(retailer.phoneNumber),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.blue),
                      title: Text('Email'),
                      subtitle: Text(retailer.email),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Connecting to retailer support'),
                          ),
                        );
                      },
                      icon: Icon(Icons.phone, color: Colors.white),
                      label: Text(
                        'Call Retailer',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: Colors.blue[800],
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Obx(() {
        final features = controller.features.value;
        if (features == null) {
          return Center(child: CircularProgressIndicator());
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildFeatureItem('USB Debug', features.isUSBDebug),
                    _buildFeatureItem('Camera', features.isCamera),
                    _buildFeatureItem(
                      'App Installation',
                      features.isAppInstallation,
                    ),
                    _buildFeatureItem('Soft Reset', features.isSoftReset),
                    _buildFeatureItem('Soft Boot', features.isSoftBoot),
                    _buildFeatureItem('Hard Reset', features.isHardReset),
                    _buildFeatureItem(
                      'Outgoing Calls',
                      features.isOutgoingCalls,
                    ),
                    _buildFeatureItem('Settings', features.isSetting),
                    _buildFeatureItem(
                      'Developer Options',
                      features.isDeveloperOptions,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Blocked Apps:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(features.apps.join(", ")),
                    SizedBox(height: 16),
                    Text('Warning Audio: ${features.warningAudio}'),
                    Text('Warning Wallpaper: ${features.warningWallpaper}'),
                    Text('Password Change: ${features.passwordChange}'),
                    Text('Wallpaper URL: ${features.wallpaperUrl}'),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFeatureItem(String label, bool value) {
    return ListTile(
      title: Text(label),
      trailing: Icon(
        value ? Icons.check_circle : Icons.cancel,
        color: value ? Colors.green : Colors.red,
      ),
    );
  }
}

class FeaturesPage extends StatelessWidget {
  final Features features;
  const FeaturesPage({Key? key, required this.features}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Features')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildFeatureItem('USB Debug', features.isUSBDebug),
            _buildFeatureItem('Camera', features.isCamera),
            _buildFeatureItem('App Installation', features.isAppInstallation),
            _buildFeatureItem('Soft Reset', features.isSoftReset),
            _buildFeatureItem('Soft Boot', features.isSoftBoot),
            _buildFeatureItem('Hard Reset', features.isHardReset),
            _buildFeatureItem('Outgoing Calls', features.isOutgoingCalls),
            _buildFeatureItem('Settings', features.isSetting),
            _buildFeatureItem('Developer Options', features.isDeveloperOptions),
            SizedBox(height: 16),
            Text(
              'Blocked Apps:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(features.apps.join(", ")),
            SizedBox(height: 16),
            Text('Warning Audio: ${features.warningAudio}'),
            Text('Warning Wallpaper: ${features.warningWallpaper}'),
            Text('Password Change: ${features.passwordChange}'),
            Text('Wallpaper URL: ${features.wallpaperUrl}'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String label, bool value) {
    return ListTile(
      title: Text(label),
      trailing: Icon(
        value ? Icons.check_circle : Icons.cancel,
        color: value ? Colors.green : Colors.red,
      ),
    );
  }
}
