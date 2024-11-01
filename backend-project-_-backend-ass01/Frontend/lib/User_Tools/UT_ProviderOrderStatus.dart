import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:tap_on/User_Service/US_Booking.dart';
import 'package:tap_on/User_Service/US_PreBooking.dart';

class UT_ProviderOrderStatus extends StatelessWidget {
  final Map<String, dynamic> provider;
  final String status;
  final Map<String, dynamic> order;
  const UT_ProviderOrderStatus({
    required this.provider,
    required this.status,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            Text('Request Successfully', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                'Your Request has been confirmed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              SizedBox(height: 20),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  textStyle: TextStyle(fontSize: 12, color: Colors.white),
                ),
                child: Text('Request Another Tool'),
              ),
              SizedBox(height: 20),
              Text(
                'Thank you for choosing us!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
