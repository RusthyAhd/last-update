import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/User_Service/US_PreBooking.dart';
import 'package:tap_on/User_Service/US_ProviderOrderStatus.dart';
import 'package:tap_on/User_Tools/UT_ProviderOrderStatus.dart';
import 'package:tap_on/widgets/Loading.dart';
import 'package:http/http.dart' as http;

class UT_ToolRequest extends StatefulWidget {
  final Map<String, dynamic> product;
  final String shopEmail;
  const UT_ToolRequest({
    required this.product,
    required this.shopEmail,
  });

  @override
  State<UT_ToolRequest> createState() => _UT_ToolRequestState();
}

class _UT_ToolRequestState extends State<UT_ToolRequest> {
  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> selectedWeekdays = [];
  TextEditingController _qytController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedWeekdays = widget.product['available_days'] != null
        ? List<String>.from(widget.product['available_days'])
        : [];
    _qytController.text = 1.toString();
  }

  void handleAddNewOrder() async {
    LoadingDialog.show(context);

    try {
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final qyt = _qytController.text == ''
          ? '1'
          : int.parse(_qytController.text) >
                  int.parse(widget.product['quantity'])
              ? widget.product['quantity']
              : _qytController.text;

      final bodyData = {
        "tool_id": widget.product['id'],
        "shop_id": widget.shopEmail,
        "title": widget.product['title'],
        "qty": int.parse(qyt),
        "days": 1,
        "status": "pending",
        "date": DateTime.now().toString(),
      };
      final response = await http.post(
        Uri.parse('$baseURL/to/new'),
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
        final order = data['data'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UT_ProviderOrderStatus(
                provider: widget.product,
                status: 'success',
                order: widget.product),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Request Tools', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: SingleChildScrollView(
          // Wrap the Column in SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service provider info
              SizedBox(height: 15),
              // Service name and description
              Text("Tool: ${widget.product['title'] ?? 'Name'}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.product['image'] != null &&
                          widget.product['image'] != "N/A"
                      ? Image.memory(
                          base64Decode(widget.product['image']),
                          height: 100, // Set a height for the image if needed
                          width: 100, // Set a width for the image if needed
                          fit: BoxFit.cover, // Adjust fit as needed
                        )
                      : Icon(Icons.image, size: 100), // Fallback icon
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 15),
              Text(
                "Availability: ${widget.product['availability'] ?? 'Available'}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text("Available Days:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: weekdays.map((day) {
                  return FilterChip(
                    label: Text(day),
                    selected: selectedWeekdays.contains(day),
                    onSelected: (isSelected) {},
                  );
                }).toList(),
              ),
              SizedBox(height: 15),
              Text(
                "Amount: LKR ${widget.product['price'] ?? 'N/A'} for a tool",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Avaialable QYT: ${widget.product['quantity'] ?? 'N/A'} ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Enter the number of quantity you want to request",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                controller: _qytController,
                decoration: InputDecoration(
                  labelText: 'Number of quantity',
                  hintText: '1',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 55),
              // Action buttons
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showConfirmAlert(
                            widget.product['price'],
                            _qytController.text == ''
                                ? '1'
                                : int.parse(_qytController.text) >
                                        int.parse(widget.product['quantity'])
                                    ? widget.product['quantity']
                                    : _qytController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.yellow,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      child: Text('Request Now'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmAlert(price, qyt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tool: ${widget.product['title'] ?? 'title'}'),
              Text('Amount: LKR $price for $qyt qyt'),
              Text('Total: LKR ${double.parse(price) * int.parse(qyt)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                handleAddNewOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.yellow,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                textStyle: TextStyle(fontSize: 14, color: Colors.white),
              ),
              child: Text('Request Tools'),
            ),
          ],
        );
      },
    );
  }
}
