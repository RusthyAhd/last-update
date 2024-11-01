import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SP_History extends StatefulWidget {
  const SP_History({super.key});

  @override
  _SP_HistoryState createState() => _SP_HistoryState();
}

class _SP_HistoryState extends State<SP_History> {
  String selectedDateFilter = 'Date'; // To store the selected date filter
  String orderIdFilter = '';
  // List of all orders. You can add new orders to this list dynamically.
  List<Map<String, dynamic>> allOrders = [
    // {
    //   'status': 'COMPLETED',
    //   'subStatus': '2ND ORDER',
    //   'orderId': '162267901',
    //   'date': '12 Sept 2024, 9:31 am',
    //   'ordername': 'Homemaitanance',
    //   'statusColor': Colors.green,
    //   'dateFilter': 'Today',
    // },
    // {
    //   'status': 'COMPLETED',
    //   'subStatus': 'NEW CUSTOMER',
    //   'orderId': '162250430',
    //   'date': '11 Sept 2024, 12:15 pm',
    //   'ordername': 'Homemaitanance',
    //   'statusColor': Colors.green,
    //   'dateFilter': 'Yesterday',
    // },
    // {
    //   'status': 'CANCELLED',
    //   'subStatus': 'NEW CUSTOMER',
    //   'reason': 'Change my mind',
    //   'orderId': '162246651',
    //   'date': '11 Sept 2024, 8:36 am',
    //   'ordername': 'Homemaitanance',
    //   'statusColor': Colors.red,
    //   'dateFilter': 'Yesterday',
    // },
  ];

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
      final providerId = prefs.getString('serviceProviderId');

      final response = await http
          .get(Uri.parse('$baseURL/so/get/all/$providerId'), headers: {
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
                'ordername': order['description'] ?? 'N/A',
                'statusColor': order['statusColor'] ?? Colors.green,
                'customername': order['customer_name'] ?? 'N/A',
                'customermobile': order['customer_number'] ?? 'N/A',
                'customerLocation': order['customer_address'] ?? 'N/A',
                "days": order['days'] ?? 'N/A',
                "price": order['total_price'] ?? 'N/A',
              });
            }
          }
          setState(() {
            allOrders.clear();
            allOrders = newOrders;
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
    // Filter the orders based on the selected date filter
    List<Map<String, dynamic>> filteredOrders = allOrders.where((order) {
      // Check if selected date filter matches the order's date filter
      bool matchesDateFilter = selectedDateFilter == 'Date' ||
          order['dateFilter'] == selectedDateFilter;
      // Check if the Order ID matches the input
      bool matchesOrderId =
          orderIdFilter.isEmpty || order['orderId'].contains(orderIdFilter);

      return matchesDateFilter && matchesOrderId;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Service History '),
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
                      setState(() {
                        selectedDateFilter = newValue!;
                      });
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
                    onChanged: (value) {
                      setState(
                        () {
                          orderIdFilter = value;
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                // Reset Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDateFilter = 'Date';
                      orderIdFilter = ''; // Reset filter
                    });
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                var order = filteredOrders[index];
                return orderItem(
                  status: order['subStatus'],
                  subStatus: order['ordername'],
                  reason: order['reason'] ?? '',
                  orderId: order['orderId'],
                  date: order['date'],
                  ordername: order['ordername'],
                  statusColor: order['statusColor'],
                );
              },
            ),
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
    required String ordername,
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
                      color: const Color.fromARGB(255, 224, 224, 224),
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
