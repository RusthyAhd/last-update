import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/User_Tools/UT_ToolDetails.dart';
import 'package:http/http.dart' as http;

class UT_ToolMenu extends StatefulWidget {
  final String shopName; // Shop name to display relevant tools
  //final List<Map<String, String>> products; // List of products in the shop
  final String shopId;
  final String shopEmail;
  final String shopPhone;

  const UT_ToolMenu({
    super.key,
    required this.shopName,
    required this.shopId,
    required this.shopEmail,
    required this.shopPhone,
    //required this.products
  });

  @override
  State<UT_ToolMenu> createState() => _UT_ToolMenuState();
}

class _UT_ToolMenuState extends State<UT_ToolMenu> {
  final List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    await getAllTools();
  }

  Future<void> getAllTools() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      final token =
          prefs.getString('token'); // Get the token from shared preferences

      final response = await http
          .get(Uri.parse('$baseURL/tool/get/all/${widget.shopId}'), headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      }); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      if (status == 200) {
        final tools = data['data'];
        setState(() {
          products.clear();
          for (var tool in tools) {
            products.add({
              'id': tool['tool_id'] ?? 'N/A',
              'title': tool['title'] ?? 'Service Name',
              'price': tool['item_price'].toString() ?? 'N/A',
              'quantity': tool['qty'].toString(),
              'image': tool['pic'] ?? '',
              'description': tool['description'] ?? tool['title'],
              "availability": tool['availability'] ?? 'N/A',
              "available_days": tool['available_days'] ?? [],
              "available_hours": tool['available_hours'] ?? 'N/A',
            });
          }
        });
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
        title: Text(
          '${widget.shopName} Products',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        // Add gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.yellow[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // List of items specific to this shop
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return productTile(
                        context,
                        product['title']!,
                        product['price']!,
                        product['image']!,
                        product['description']!,
                        widget.shopEmail,
                        product);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget productTile(
      BuildContext context,
      String title,
      String price,
      String image,
      String description,
      String shopEmail,
      Map<String, dynamic> product) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners for the card
      ),
      elevation: 5, // Add shadow to the card for a raised effect
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(12), // Add more padding inside the tile
        leading: Hero(
          // Hero animation for smooth image transition
          tag: title, // Ensure tag is unique for each product
          child: image != "N/A"
              ? Image(
                  image: MemoryImage(
                    base64Decode(image),
                  ),
                  height: 100, // Set a height for the image if needed
                  width: 100, // Set a width for the image if needed
                  fit: BoxFit.cover, // Adjust fit as needed
                )
              : CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.build),
                ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          price,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
        onTap: () {
          // Navigate to ProductDetailsPage with product details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UT_ToolDetails(
                  title: title,
                  price: price,
                  image: image,
                  description: description,
                  shopEmail: shopEmail,
                  product: product,
                  shopPhone: widget.shopPhone),
            ),
          );
        },
      ),
    );
  }
}
