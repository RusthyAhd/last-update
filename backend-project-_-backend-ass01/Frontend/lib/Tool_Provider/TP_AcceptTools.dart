import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Service_Provider/SP_Dashboard.dart';
import 'package:tap_on/Tool_Provider/TP_Dashboard.dart';
import 'package:tap_on/services/geo_services.dart';
import 'package:tap_on/widgets/Loading.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TP_AcceptTools extends StatefulWidget {
  final Map<String, dynamic> order;
  final String status;
  const TP_AcceptTools({
    required this.order,
    required this.status,
  });

  @override
  State<TP_AcceptTools> createState() => _TP_AcceptToolsState();
}

class _TP_AcceptToolsState extends State<TP_AcceptTools> {
  TextEditingController _reasonController = TextEditingController();

  void handleAcceptOrder() async {
    LoadingDialog.show(context);
    try {
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final bodyData = {
        "order_id": widget.order['orderId'],
        "status": "accept",
        "reason": ""
      };
      final response = await http.put(
        Uri.parse('$baseURL/to/change/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode(bodyData),
      ); // Send a GET request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response
      // Check if the status is 200
      if (status == 200) {
        LoadingDialog.hide(context); // Hide the loading dialog
        // Navigate to the Verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TP_Dashboard(),
          ),
        );
      } else {
        // Show an error alert if the status is not 200
        LoadingDialog.hide(context); // Hide the loading dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'Sorry, something went wrong',
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        ); // Show an error alert
      }
    } catch (e) {
      // Show an error alert if an error occurs
      LoadingDialog.hide(context); // Hide the loading dialog
      debugPrint('Something went wrong $e'); // Print the error
    }
  }

  void _launchMapsUrl(String location) async {
    final coordinates = await getCoordinatesFromCity(location);
    final latitude = coordinates['latitude'];
    final longitude = coordinates['longitude'];
    final String googleUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl));
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Could not launch maps',
        backgroundColor: Colors.black,
        titleColor: Colors.white,
        textColor: Colors.white,
      );
    }
  }

  void handleRejectOrder() async {
    LoadingDialog.show(context);
    if (_reasonController.text.isEmpty || _reasonController.text == '') {
      LoadingDialog.hide(context);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Please enter a reason for rejection',
        backgroundColor: Colors.black,
        titleColor: Colors.white,
        textColor: Colors.white,
      );
      return;
    }
    try {
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final bodyData = {
        "order_id": widget.order['orderId'],
        "status": "accept",
        "reason": _reasonController.text
      };
      final response = await http.put(
        Uri.parse('$baseURL/to/change/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode(bodyData),
      ); // Send a GET request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response
      // Check if the status is 200
      if (status == 200) {
        LoadingDialog.hide(context); // Hide the loading dialog
        // Navigate to the Verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TP_Dashboard(),
          ),
        );
      } else {
        // Show an error alert if the status is not 200
        LoadingDialog.hide(context); // Hide the loading dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'Sorry, something went wrong',
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        ); // Show an error alert
      }
    } catch (e) {
      // Show an error alert if an error occurs
      LoadingDialog.hide(context); // Hide the loading dialog
      debugPrint('Something went wrong $e'); // Print the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title:
            Text(widget.status == 'accept' ? 'Accept Order' : 'Reject Order'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Information
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Request ID', style: TextStyle(color: Colors.grey)),
                  Text(widget.order['orderId'],
                      style: TextStyle(color: Colors.blue)),
                ],
              ),
              SizedBox(height: 16),
              Text(widget.order['ordername'] ?? '',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Date:', style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 8),
                  Text(widget.order['date']),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: const [
                  Text('Time:', style: TextStyle(color: Colors.grey)),
                  SizedBox(width: 8),
                  Text('12:00 PM'),
                ],
              ),
              SizedBox(height: 25),

              // Customer Details
              Text(
                "About Customer",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding:
                    EdgeInsets.all(10), // Optional padding around the Container
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Background color of the container
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Customer Details'),
                      trailing: TextButton(
                        onPressed: () {
                          _launchMapsUrl(widget.order['cusLocation']);
                        },
                        child: Text('Get Direction'),
                      ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(widget.order['customername']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.order['customermobile'],
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              launchUrl(Uri.parse(
                                  'sms:${widget.order['customermobile']}'));
                            },
                            icon: Icon(Icons.chat),
                            label: Text('Chat'),
                          ),
                          // Call Button
                          IconButton(
                            icon: Icon(Icons.phone),
                            onPressed: () {
                              launchUrl(Uri.parse(
                                  'tel:${widget.order['customermobile']}'));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Price Details
              Text('Price Detail', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildPriceRow('Price',
                        '${widget.order['price'] / widget.order['itemCount']} x ${widget.order['itemCount']} = ${widget.order['price']}'),
                    Divider(),
                    _buildPriceRow('Sub Total', '${widget.order['price']}'),
                    Divider(),
                    _buildPriceRow('Total Amount', '${widget.order['price']}',
                        isBold: true),
                  ],
                ),
              ),

              if (widget.status == 'reject')
                Column(
                  children: [
                    SizedBox(height: 16),
                    Text('Reason for Rejection',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _reasonController,
                        decoration: InputDecoration(
                          hintText: 'Enter reason for rejection',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 50),
              widget.status == 'accept'
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          handleAcceptOrder();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.yellow,
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          textStyle:
                              TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        child: Text('Accept Order'),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          handleRejectOrder();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          textStyle:
                              TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        child: Text('Reject Order'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String title, String price, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          price,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
