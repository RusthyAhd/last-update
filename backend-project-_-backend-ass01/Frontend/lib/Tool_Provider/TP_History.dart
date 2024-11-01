import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TP_History extends StatefulWidget {
  const TP_History({super.key});

  @override
  State<TP_History> createState() => _TP_HistoryState();
}

class _TP_HistoryState extends State<TP_History> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    await handleGetAllOrder();
  }

  Future<void> handleGetAllOrder() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      final token =
          prefs.getString('token'); // Get the token from shared preferences
      final providerId = prefs.getString('toolProviderId');

      final response = await http
          .get(Uri.parse('$baseURL/to/get/all/$providerId'), headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      }); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      if (status == 200) {
        final orderData = data['data'];
        if (orderData.length > 0) {
          final List<Map<String, dynamic>> newOrders = [];
          for (var order in orderData) {
            if (order['status'] != 'pending') {
              newOrders.add({
                'subStatus': order['status'] ?? 'N/A',
                'orderId': order['order_id'] ?? 'N/A',
                'date': order['date'] ?? 'N/A',
                'statusColor': order['statusColor'] ?? Colors.green,
                'itemname': order['title'] ?? 'N/A',
                'itemCount': order['qty'] ?? 'N/A',
                'customername': order['customer_name'] ?? 'N/A',
                'customermobile': order['customer_number'] ?? 'N/A',
                'customerLocation': order['customer_address'] ?? 'N/A',
                'price': order['total_price'] ?? 'N/A',
              });
            }
          }
          setState(() {
            orders.clear();
            orders = newOrders;
          });
        }
      }
    } catch (e) {
      print(e);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'An error occurred. Please try again.',
        backgroundColor: Colors.black,
        titleColor: Colors.white,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Date filter dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ['Date', 'Today', 'Yesterday'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      // Handle date change
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                // Search field for Order ID
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Order ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                // Reset Button
                ElevatedButton(
                  onPressed: () {
                    // Handle reset
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return orderItem(
                  status: orders[index]['subStatus'],
                  subStatus: orders[index]['itemname'],
                  orderId: orders[index]['orderId'],
                  date: orders[index]['date'],
                  itemCount: orders[index]['itemCount'],
                  statusColor: orders[index]['statusColor'],
                  itemname: orders[index]['itemname'],
                );
              },
            ),
            // ListView(
            //   children: [
            //     orderItem(
            //       status: 'RENTED',
            //       subStatus: '2ND ORDER',
            //       orderId: '162267901',
            //       date: '12 Sept 2024, 9:31 am',
            //       itemCount: 4,
            //       itemname: 'Hammer',
            //       statusColor: Colors.green,
            //     ),
            //     orderItem(
            //       status: 'RENTED',
            //       subStatus: 'NEW CUSTOMER',
            //       orderId: '162250430',
            //       date: '11 Sept 2024, 12:15 pm',
            //       itemCount: 1,
            //       itemname: 'Hammer',
            //       statusColor: Colors.green,
            //     ),
            //     orderItem(
            //       status: 'CANCELLED',
            //       subStatus: 'NEW CUSTOMER | PASSENGER',
            //       reason: 'Change my mind',
            //       orderId: '162246651',
            //       date: '11 Sept 2024, 8:36 am',
            //       itemCount: 2,
            //       itemname: 'Hammer',
            //       statusColor: Colors.red,
            //     ),
            //   ],
            // ),
          ),
        ],
      ),
    );
  }

  Widget orderItem({
    required String status,
    String? subStatus,
    String? reason,
    required String orderId,
    required String date,
    required int itemCount,
    required String itemname,
    required Color statusColor,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                if (subStatus != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(subStatus),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text('Order ID: $orderId'),
            Text(date),
            if (reason != null) ...[
              SizedBox(height: 4),
              Text(
                reason,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
