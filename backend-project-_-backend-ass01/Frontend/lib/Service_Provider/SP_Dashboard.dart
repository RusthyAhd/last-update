import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tap_on/Home%20page.dart';
import 'package:tap_on/Service_Provider/SP_AcceptedAllOrders.dart';
import 'package:tap_on/Service_Provider/SP_AcceptedOrders.dart';
import 'package:tap_on/Service_Provider/SP_Addservice.dart';
import 'package:tap_on/Service_Provider/SP_Feedback.dart';
import 'package:tap_on/Service_Provider/SP_History.dart';
import 'package:tap_on/Service_Provider/SP_Notification.dart';
import 'package:tap_on/Service_Provider/SP_Profile.dart';
import 'package:tap_on/Service_Provider/SP_Servicemanager.dart';
import 'package:tap_on/widgets/Loading.dart';
import 'package:http/http.dart' as http;

class SP_Dashboard extends StatefulWidget {
  const SP_Dashboard({super.key});

  @override
  State<SP_Dashboard> createState() => _SP_DashboardState();
}

class _SP_DashboardState extends State<SP_Dashboard> {
  String userName = '';
  List<Map<String, dynamic>> orders = [
    // {
    //   'subStatus': '2ND ORDER',
    //   'orderId': '162267901',
    //   'date': '12 Sept 2024, 9:31 am',
    //   'ordername': 'Santize full home',
    //   'statusColor': Colors.brown,
    //   'customername': 'Rishaf',
    //   'customermobile': '0755354023',
    //   'customerLocation': 'No-2,Kinniya',
    // },
    // {
    //   'subStatus': '2ND ORDER',
    //   'orderId': '162267901',
    //   'date': '12 Sept 2024, 9:31 am',
    //   'ordername': 'Santize full home',
    //   'statusColor': Colors.brown,
    //   'customername': 'Rishaf',
    //   'customermobile': '0755354023',
    //   'customerLocation': 'No-2,Kinniya',
    // },
    // {
    //   'subStatus': '2ND ORDER',
    //   'orderId': '162267901',
    //   'date': '12 Sept 2024, 9:31 am',
    //   'ordername': 'Santize full home',
    //   'statusColor': Colors.brown,
    //   'customername': 'Rishaf',
    //   'customermobile': '0755354023',
    //   'customerLocation': 'No-2,Kinniya',
    // },
    // {
    //   'subStatus': '2ND ORDER',
    //   'orderId': '162267901',
    //   'date': '12 Sept 2024, 9:31 am',
    //   'ordername': 'Santize full home',
    //   'statusColor': Colors.brown,
    //   'customername': 'Rishaf',
    //   'customermobile': '0755354023',
    //   'customerLocation': 'No-2,Kinniya',
    // },
  ];

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    await handleGetAllOrder();
    await getUserName();
  }

  Future<void> getUserName() async {
    // Get the user name from the shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('serviceProviderName') ?? 'N/A';
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
      final providerId = prefs.getString('serviceProviderId');

      final response = await http
          .get(Uri.parse('$baseURL/so/get/all/$providerId'), headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      }); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      debugPrint(data.toString());

      if (status == 200) {
        final orderData = data['data'];
        if (orderData.length > 0) {
          orders.clear();
          for (var order in orderData) {
            if (order['status'] == 'pending') {
              orders.add({
                'subStatus': order['status'] ?? 'N/A',
                'orderId': order['order_id'] ?? 'N/A',
                'date': order['date'] ?? 'N/A',
                'ordername': order['description'] ?? 'N/A',
                'statusColor': order['statusColor'] ?? Colors.brown,
                'customername': order['customer_name'] ?? 'N/A',
                'customermobile': order['customer_number'] ?? 'N/A',
                'customerLocation': order['customer_address'] ?? 'N/A',
                'cusLocation': order['customer_location'] ?? 'N/A',
                "days": order['days'] ?? 'N/A',
                "price": order['total_price'] ?? 'N/A',
              });
            }
          }
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
    orders.clear();
    super.dispose();
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
              'TapOn Provider',
              style: TextStyle(
                fontSize: 20, // You can adjust the size
                fontWeight: FontWeight.bold, // Optional: Makes the text bold
              ),
            ),
            Text(
              'Incoming Orders',
              style: TextStyle(
                fontSize: 16, // You can adjust the size
                fontWeight: FontWeight.normal, // Optional: Normal text weight
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
                    MaterialPageRoute(builder: (context) => SP_History()));
                // Handle Orders button press
              },
            ),

            // Menu Manager button
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Service'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SP_Addservice())); // Handle Menu Manager button press
              },
            ),

            // Performance button
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Service Manager'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SP_Servicemanager()));
                // Handle Performance button press
              },
            ),

            // Notifications button
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SP_Notification()));

                // Handle Notifications button press
              },
            ),

            // Shop Profile button
            ListTile(
              leading: Icon(Icons.store),
              title: Text('Provider Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SP_Profile()));
                // Handle Shop Profile button press
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SP_Feedback()));
                // Handle Shop Profile button press
              },
            ),

            const SizedBox(
              height: 25,
            ),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove('serviceProviderId');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.yellow,
                  minimumSize: Size(70, 50),
                ),
                child: Text('Log Out'),
              ),
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
                      context: context,
                      subStatus: orders[index]['subStatus'],
                      orderId: orders[index]['orderId'],
                      date: orders[index]['date'],
                      ordername: orders[index]['ordername'],
                      statusColor: orders[index]['statusColor'],
                      customername: orders[index]['customername'],
                      customermobile: orders[index]['customermobile'],
                      customerLocation: orders[index]['customerLocation'],
                      order: orders[index],
                    );
                  }

                  // Handle the "Accept" button press
                  ),
            ),
            // Expanded(
            //   child: ListView(
            //     children: [
            //       orderItem(
            //           context: context,
            //           subStatus: '2ND ORDER',
            //           orderId: '162267901',
            //           date: '12 Sept 2024, 9:31 am',
            //           ordername: 'Santize full home',
            //           statusColor: Colors.brown,
            //           customername: 'Rishaf',
            //           customermobile: '0755354023',
            //           customerLocation: 'No-2,Kinniya'),
            //     ],
            //   ),
            // ),
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
                    SP_AcceptedAllOrders()), // Handle the "Accept" button press
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

  Widget orderItem({
    required BuildContext context,
    required String subStatus,
    required String orderId,
    required String date,
    required String customername,
    required String customermobile,
    required String customerLocation,
    required String ordername,
    required MaterialColor statusColor,
    required Map<String, dynamic> order,
  }) {
    return Card(
      color: const Color.fromARGB(255, 233, 231, 207),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $orderId',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 5),
            Text(
              '$ordername ',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8),
            Text('Date: ${date.split("T")[0]}'),
            Text('Customer Name: $customername'),
            Text('Customer Location: $customerLocation'),
            Text('Customer Mobile: $customermobile'),
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
                            builder: (context) => SP_AcceptedOrder(
                                order: order, status: 'accept'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 197, 39),
                          foregroundColor: Colors.black // Button color
                          ),
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SP_AcceptedOrder(
                                order: order, status: 'reject'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black // Button color
                          ), // Handle the "Reject" button press

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
