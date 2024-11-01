import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/User_Service/US_ProviderOrderStatus.dart';
import 'package:tap_on/widgets/Loading.dart';
import 'package:http/http.dart' as http;

class US_PreBooking extends StatefulWidget {
  final Map<String, dynamic> provider;
  const US_PreBooking({
    required this.provider,
  });

  @override
  _US_PreBookingState createState() => _US_PreBookingState();
}

class _US_PreBookingState extends State<US_PreBooking> {
  DateTime _selectedDate = DateTime.now();
  String _formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _formattedTime = "";

  //function to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // current date
      firstDate: DateTime(2000), // earliest date
      lastDate: DateTime(2100), // latest date
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
        "days": '1',
        "status": "pending",
        "date": _formattedDate,
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

  // Function to pick time
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _formattedTime = picked.format(context); // Format the selected time
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Service'),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: MemoryImage(base64Decode(widget.provider[
                                'image'])), // Replace with your service image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Service Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.provider['service_category'] ?? 'Service',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              widget.provider['name'] ?? 'Name',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Description Field
              Text(
                'Description: \n${widget.provider['description']}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              // TextField(
              //   decoration: InputDecoration(
              //     labelText: 'Description',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              SizedBox(height: 20),

              // Booking Date & Slot Selector
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Selected date: $_formattedDate",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Selected time: $_formattedTime",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor:
                              Colors.black, // Background color of the button
                        ),
                        onPressed: () => _pickDate(context),
                        child: Text('Pick Date'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => _pickTime(context),
                        child: Text("Pick Time"),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              Text(
                'Price details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(
                height: 10,
              ),
              // Price Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildPriceRow(
                      'Price',
                      '${widget.provider['amountPerDay']} * 1',
                      '${widget.provider['amountPerDay']}'),
                  // buildPriceRow('Discount (4% off)', '', '-Rs.1.00',
                  //     isDiscount: true),
                  Divider(),
                  buildPriceRow(
                      'Total Amount', '', '${widget.provider['amountPerDay']} ',
                      isTotal: true),
                ],
              ),
              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showConfirmAlert(widget.provider['amountPerDay'], '1');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.yellow),
                  child: Text('PreBook Requast'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPriceRow(String label, String unit, String price,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDiscount ? Colors.green : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Row(
            children: [
              if (unit.isNotEmpty) Text(unit),
              SizedBox(width: 10),
              Text(
                price,
                style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  fontSize: isTotal ? 18 : 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmAlert(price, days) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Pre Booking'),
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
