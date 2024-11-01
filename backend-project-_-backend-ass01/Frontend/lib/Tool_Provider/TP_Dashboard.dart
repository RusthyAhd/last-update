import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:tap_on/Tool_Provider/TP_AcceptTools.dart';
import 'package:tap_on/Tool_Provider/TP_AcceptedOrder.dart';
import 'package:tap_on/Tool_Provider/TP_AddTool.dart';
import 'package:tap_on/Tool_Provider/TP_Feedback.dart';
import 'package:tap_on/Tool_Provider/TP_History.dart';
import 'package:tap_on/Tool_Provider/TP_Notification.dart';
import 'package:tap_on/Tool_Provider/TP_Profile.dart';
import 'package:tap_on/Tool_Provider/TP_ToolManager.dart';
import 'package:http/http.dart' as http;

class TP_Dashboard extends StatefulWidget {
  const TP_Dashboard({super.key});

  @override
  State<TP_Dashboard> createState() => _TP_DashboardState();
}

class _TP_DashboardState extends State<TP_Dashboard> {
  String userName = '';
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    await getUserName();
    await handleGetAllOrder();
  }

  Future<void> getUserName() async {
    // Get the user name from the shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('toolProviderName') ?? 'N/A';
    setState(() {
      userName = name;
    });
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

      debugPrint(data.toString());

      if (status == 200) {
        final orderData = data['data'];
        if (orderData.length > 0) {
          final List<Map<String, dynamic>> newOrders = [];
          for (var order in orderData) {
            if (order['status'] == 'pending') {
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
                'cusLocation': order['customer_location'] ?? 'N/A',
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Incoming Orders',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header with logo and shop name
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.yellow[700],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 40,
                    child: ClipOval(
                      child: Image.asset(
                        'profile.png',
                        fit: BoxFit.cover,
                        width: 80, // Set width to match the radius
                        height: 80, // Set height to match the radius
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 40, // Adjust size to fit
                            color: Colors.white, // Change color if needed
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Orders button
            ListTile(
              leading: Icon(Icons.list_alt),
              title: Text('Order History'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TP_History()));
                // Handle Orders button press
              },
            ),

            // Menu Manager button
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Tool'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TP_AddTool())); // Handle Menu Manager button press
              },
            ),

            // Performance button
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Menu Manager'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TP_ToolManager()));
                // Handle Performance button press
              },
            ),

            // Notifications button
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TP_Notfication()));

                // Handle Notifications button press
              },
            ),

            // Shop Profile button
            ListTile(
              leading: Icon(Icons.store),
              title: Text('Shop Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TP_Profile()));
                // Handle Shop Profile button press
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TP_Feedback()));
                // Handle Shop Profile button press
              },
            ),

            const SizedBox(
              height: 25,
            ),
            // Log Out button
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('toolProviderId');
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));

                // Handle Log Out button press
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 8, 0, 0),
                backgroundColor: const Color.fromARGB(255, 219, 135, 9),
                minimumSize: Size(70, 50),
              ),
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return orderItem(
                    subStatus: orders[index]['subStatus'],
                    orderId: orders[index]['orderId'],
                    date: orders[index]['date'],
                    itemCount: orders[index]['itemCount'],
                    statusColor: orders[index]['statusColor'],
                    itemname: orders[index]['itemname'],
                    order: orders[index],
                  );
                },
              ),
              // Handle the "Accept" button press
              // ListView(
              //   children: [
              //     orderItem(
              //       subStatus: '2ND ORDER',
              //       orderId: '162267901',
              //       date: '12 Sept 2024, 9:31 am',
              //       itemCount: 4,
              //       itemname: 'Hammer',
              //       statusColor: Colors.green,
              //     ),
              //   ],
              // ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Your orders show here'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TP_AcceptedOrder()), // Navigate to accepted orders page
          );
        },
        backgroundColor:
            const Color.fromARGB(255, 255, 214, 7), // Color of the button
        child: const Text(
          'Accept',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  orderItem({
    required String subStatus,
    required String orderId,
    required String date,
    required int itemCount,
    required String itemname,
    required MaterialColor statusColor,
    required Map<String, dynamic> order,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $orderId',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 5),
            Text('Item: $itemname ($itemCount pcs)'),
            Text('Date: $date'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ($subStatus)',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TP_AcceptTools(
                                  order: order, status: 'accept')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Button color
                      ),
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TP_AcceptTools(
                                  order: order, status: 'reject')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Button color
                      ),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
