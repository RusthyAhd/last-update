import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TP_AcceptedOrder extends StatefulWidget {
  const TP_AcceptedOrder({super.key});

  @override
  State<TP_AcceptedOrder> createState() => _TP_AcceptedOrderState();
}

class _TP_AcceptedOrderState extends State<TP_AcceptedOrder> {
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
            if (order['status'] == 'accept') {
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
        backgroundColor: Colors.yellow[700],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'TapOn ShopOwner',
              style: TextStyle(
                fontSize: 20, // You can adjust the size
                fontWeight: FontWeight.bold, // Optional: Makes the text bold
              ),
            ),
            Text(
              'Accepted Orders',
              style: TextStyle(
                fontSize: 16, // You can adjust the size
                fontWeight: FontWeight.normal, // Optional: Normal text weight
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: orders.length, // Adjust based on your data
                itemBuilder: (context, index) {
                  return orderItem(
                    context: context, // Pass the context here
                    orderId: orders[index]['orderId'],
                    orderName: orders[index]['itemname'],
                    date: orders[index]['date'],
                    customerName: orders[index]['customername'],
                    customerLocation: orders[index]['customerLocation'],
                    customerMobile: orders[index]['customermobile'],
                    status: orders[index]['subStatus'],
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Your Accepted orders show here',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget orderItem({
    required BuildContext context, // Add BuildContext as a required parameter
    required String orderId,
    required String orderName,
    required String date,
    required String customerName,
    required String customerLocation,
    required String customerMobile,
    required String status,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $orderId',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Order: $orderName',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: $date',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Customer Name: $customerName',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Customer Location: $customerLocation',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Customer Mobile: $customerMobile',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: $status',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     ElevatedButton(
            //       onPressed: () {},
            //       style: ElevatedButton.styleFrom(
            //         foregroundColor: Colors.white,
            //         backgroundColor: Colors.red,
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //       ),
            //       child: const Text('Reject'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
