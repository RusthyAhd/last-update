import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:http/http.dart' as http;
import 'package:tap_on/User_Home/UH_OrderView.dart';

class UH_Notification extends StatefulWidget {
  const UH_Notification({super.key});

  @override
  State<UH_Notification> createState() => _UH_NotificationState();
}

class _UH_NotificationState extends State<UH_Notification> {
  List<Map<String, dynamic>> notifications = [];
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
      final userId = prefs.getString('userId');

      final response = await http.get(
          Uri.parse('$baseURL/profile/get/all/order?user_id=$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token',
          }); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      if (status == 200) {
        final notificationData = data['data'];
        if (notificationData.length > 0) {
          final List<Map<String, dynamic>> newNotifications = [];
          final List<Map<String, dynamic>> newOrders = [];
          for (var notify in notificationData) {
            switch (notify['status']) {
              case 'pending':
                newNotifications.add({
                  'title': 'Thank you for your order',
                  'subtitle': 'Your order has been placed successfully.',
                });
                break;
              case 'accept':
                newNotifications.add({
                  'title': 'Order Accepted',
                  'subtitle':
                      '${notify['order_id']} Order has been accepted by the service provider.',
                });
                break;
              case 'reject':
                newNotifications.add({
                  'title': 'Order Rejected',
                  'subtitle':
                      '${notify['order_id']} Your order has been rejected by the service provider.',
                });
                break;
              case 'completed':
                newNotifications.add({
                  'title': 'Order Completed',
                  'subtitle':
                      '${notify['order_id']} Your order has been completed.',
                });
                break;
              default:
                newNotifications.add({
                  'title': 'New Notification',
                  'subtitle':
                      'You have a new notification. Please check your notifications.',
                });
                break;
            }
            newOrders.add({
              'subStatus': notify['status'] ?? 'N/A',
              'orderId': notify['order_id'] ?? 'N/A',
              'date': notify['date'] ?? 'N/A',
              'ordername': notify['title'] ?? 'N/A',
              'statusColor': notify['statusColor'] ?? Colors.brown,
              'customername': notify['customer_name'] ?? 'N/A',
              'customermobile': notify['customer_number'] ?? 'N/A',
              'customerLocation': notify['customer_address'] ?? 'N/A',
              "days": notify['days'] ?? 'N/A',
              "price": notify['total_price'] ?? 'N/A',
            });
          }
          setState(() {
            notifications.clear();
            notifications = newNotifications.reversed.toList();
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
  void dispose() {
    notifications.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.yellow[700],
          title: const Text("Notification Page"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
        ),
        body: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationTile(
              title: notification['title'],
              subtitle: notification['subtitle'],
              order: orders[index],
            );
          },
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Map<String, dynamic> order;

  const NotificationTile(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.order});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications, color: Colors.black),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UH_OrderView(order: order),
          ),
        );
      },
    );
  }
}
