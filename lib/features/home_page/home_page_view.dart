import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keybg/features/home_page/home_page_controller.dart';

class HomePageView extends GetView<HomePageController> {
  @override
  HomePageController get controller => HomePageController();

  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> pinControllers = List.generate(
      6,
          (_) => TextEditingController(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('EMI Payment Portal'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen),
            onPressed: () {
              // Toggle kiosk mode
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kiosk mode toggled')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // EMI Status Card
                Card(
                  elevation: 4,
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'EMI Payment Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                        SizedBox(height: 12),
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 48,
                          color: Colors.red,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'EMI is not Paid',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Due Date: 25th June 2023',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Amount Due: ₹12,345',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // PIN Entry Section
                Text(
                  'Enter 6-Digit Unlocking PIN',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),
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
                SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Submit payment
                        final enteredPin = pinControllers
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
                      icon: Icon(Icons.payment,color: Colors.white,),
                      label: Text('Submit',style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Mail option
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sending payment details via email'),
                          ),
                        );
                      },
                      icon: Icon(Icons.mail),
                      label: Text('Mail Details'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),

                // Help Section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Helpline: 1800-123-4567',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Email: support@emipayments.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connecting to customer support'),
                              ),
                            );
                          },
                          icon: Icon(Icons.phone, color: Colors.white,),
                          label: Text('Contact Us', style:TextStyle(color: Colors.white) ,),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}