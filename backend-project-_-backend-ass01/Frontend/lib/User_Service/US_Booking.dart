import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/User_Service/US_PreBooking.dart';
import 'package:tap_on/User_Service/US_ProviderOrderStatus.dart';
import 'package:tap_on/widgets/Loading.dart';
import 'package:http/http.dart' as http;

class US_Booking extends StatefulWidget {
  final Map<String, dynamic> provider;
  const US_Booking({
    required this.provider,
  });

  @override
  State<US_Booking> createState() => _US_BookingState();
}

class _US_BookingState extends State<US_Booking> {
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
  TextEditingController _dayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedWeekdays = widget.provider['available_days'] != null
        ? List<String>.from(widget.provider['available_days'])
        : [];
    _dayController.text = 1.toString();
  }

  void handleAddNewOrder() async {
    LoadingDialog.show(context);

    try {
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final bodyData = {
        "service_id": widget.provider['service_id'],
        "description": widget.provider['description'],
        "days": _dayController.text == '' ? '1' : _dayController.text,
        "status": "pending",
        "date": DateTime.now().toString(),
        "reject_reason": ""
      };
      final response = await http.post(
        Uri.parse('$baseURL/so/new'),
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
            builder: (context) => US_ProviderOrderStatus(
                provider: widget.provider, status: 'success', order: order),
          ),
        );
      } else if (status == 400) {
        LoadingDialog.hide(context); // Hide the loading dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops..., Missing Information',
          text: 'Complete your profile to book a service',
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        ); // Show an error alert
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
        title: Text('Book Service', style: TextStyle(color: Colors.black)),
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
              Text("Provider: ${widget.provider['name'] ?? 'Name'}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                  "Service: ${widget.provider['service_category'] ?? 'Service'}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.provider['image'] != null &&
                          widget.provider['image'] != "N/A"
                      ? Image.memory(
                          base64Decode(widget.provider['image']),
                          height: 100, // Set a height for the image if needed
                          width: 100, // Set a width for the image if needed
                          fit: BoxFit.cover, // Adjust fit as needed
                        )
                      : Icon(Icons.image, size: 100), // Fallback icon
                  SizedBox(height: 10),
                  Text(
                    widget.provider['description'] ?? 'Description',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                "Availability: ${widget.provider['availability'] ?? 'Available'}",
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
                "Amount: LKR ${widget.provider['amountPerDay'] ?? 'N/A'} for a day",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Enter the number of days you want to book",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                controller: _dayController,
                decoration: InputDecoration(
                  labelText: 'Number of days',
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
                            widget.provider['amountPerDay'],
                            _dayController.text == ''
                                ? '1'
                                : _dayController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.yellow,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      child: Text('Book Now'),
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

  void _showConfirmAlert(price, days) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Provider: ${widget.provider['name'] ?? 'Name'}'),
              Text(
                  'Service: ${widget.provider['service_category'] ?? 'Service'}'),
              Text('Amount: LKR $price for $days days'),
              Text('Total: LKR ${price * int.parse(days)}'),
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
                textStyle: TextStyle(fontSize: 12, color: Colors.white),
              ),
              child: Text('Book Now'),
            ),
          ],
        );
      },
    );
  }
}
