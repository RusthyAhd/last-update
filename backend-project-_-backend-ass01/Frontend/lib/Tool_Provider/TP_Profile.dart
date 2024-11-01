import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Tool_Provider/TP_Dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:tap_on/services/geo_services.dart';

class TP_Profile extends StatefulWidget {
  const TP_Profile({super.key});

  @override
  _TP_ProfileState createState() => _TP_ProfileState();
}

class _TP_ProfileState extends State<TP_Profile> {
  // TextEditingControllers for each field
  TextEditingController emailController =
      TextEditingController(text: 'teatime.ho@merchant.lk');
  TextEditingController phoneController =
      TextEditingController(text: '0740710280');
  TextEditingController OwnerNameController =
      TextEditingController(text: 'Hamthy');
  TextEditingController shopNameController =
      TextEditingController(text: 'Tea Time (Homagama)');
  TextEditingController shopAddressController = TextEditingController(
      text:
          'Institute of Technology University of Moratuwa, \nHomagama-Diyagama Rd');
  TextEditingController shopLocationController =
      TextEditingController(text: 'City, Postal Code');
  TextEditingController shopDescriptionController = TextEditingController(
      text: 'Our shop provides the best quality tea in town.');
  Map<String, dynamic> shopData = {};

  List<String> districtOptions = [
    "Colombo",
    "Gampaha",
    "Kalutara",
    "Kandy",
    "Matale",
    "Nuwara Eliya",
    "Galle",
    "Matara",
    "Hambantota",
    "Jaffna",
    "Kilinochchi",
    "Mannar",
    "Vavuniya",
    "Batticaloa",
    "Ampara",
    "Trincomalee",
    "Polonnaruwa",
    "Anuradhapura",
    "Dambulla",
    "Kurunegala",
    "Puttalam",
    "Ratnapura",
    "Kegalle",
    "Badulla",
    "Monaragala",
  ];

  String selectedDistrict = '';

  // Boolean flags to toggle the editability of each field
  bool isEmailEditable = false;
  bool isPhoneEditable = false;
  bool isOwnerNameEditable = false;
  bool isShopNameEditable = false;
  bool isShopAddressEditable = false;
  bool isShopDescriptionEditable = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    await getShopProfile();
  }

  Future<void> getShopProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      final token =
          prefs.getString('token'); // Get the token from shared preferences
      final providerEmail = prefs.getString('toolProviderEmail');

      final response = await http
          .get(Uri.parse('$baseURL/shop/find?email=$providerEmail'), headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      }); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      if (response.statusCode == 200) {
        final profile = data['data'];
        String location;
        if (profile['location'] != null &&
            profile['location'] != '' &&
            profile['location'] != 0.0 &&
            profile['location'] != 1.0) {
          location = await getCityFromCoordinates(
              double.parse(profile['location_long'].toString()),
              double.parse(profile['location_lat'].toString()));
        } else {
          location = 'unknown';
        }
        final shopDetails = {
          'id': profile['_id'] ?? '',
          'shop_name': profile['shop_name'] ?? '',
          'name': profile['name'] ?? '',
          'email': profile['email'] ?? '',
          'phone': profile['phone'] ?? '',
          'address': profile['address'] ?? '',
          'location': location ?? 'unknown',
          'category': profile['category'] ?? '',
        };
        setState(() {
          shopData = shopDetails;
          emailController.text = profile['email'];
          phoneController.text = profile['phone'];
          OwnerNameController.text = profile['name'];
          shopNameController.text = profile['shop_name'];
          shopAddressController.text = profile['address'];
          shopLocationController.text = location ?? 'unknown';
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: data['message'],
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        );
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

  void handleUpdateUserProfile() async {
    // Check if any changes were made
    if (shopData['email'] == emailController.text &&
        shopData['phone'] == phoneController.text &&
        shopData['name'] == shopNameController.text &&
        shopData['address'] == shopAddressController.text &&
        shopData['shop_name'] == shopNameController.text &&
        shopData['location'] == shopLocationController.text) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'No changes detected',
        backgroundColor: Colors.black,
        titleColor: Colors.white,
        textColor: Colors.white,
      );
      return;
    }
    // update the user profile
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      final token =
          prefs.getString('token'); // Get the token from shared preferences

      final locationCordinates =
          await getCoordinatesFromCity(shopLocationController.text);

      final shopprofileData = {
        "name": shopData['name'],
        "shop_name": shopNameController.text,
        "phone": phoneController.text,
        "address": shopAddressController.text,
        "location_long": locationCordinates["longitude"],
        "location_lat": locationCordinates["latitude"],
        "email": emailController.text,
        "category": shopData['category'],
      };
      final response = await http.put(
          Uri.parse('$baseURL/shop/update/${shopData['id']}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token',
          },
          body: json.encode(shopprofileData)); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      if (response.statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Profile updated successfully',
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: data['message'],
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        );
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
    emailController.dispose();
    phoneController.dispose();
    shopNameController.dispose();
    shopAddressController.dispose();
    shopLocationController.dispose();
    shopDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shop Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TP_Dashboard()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Shop Logo and Name
              CircleAvatar(
                radius: 50.0,
                backgroundImage: AssetImage(
                    'assets/tea_time_logo.png'), // Add your logo here
              ),
              SizedBox(height: 15),
              Text(
                shopData['shop_name'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),
              Text(
                shopData['address'] ?? 'N/A',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),

              // Profile Information Cards
              buildProfileCard('Account Information'),
              buildEditableTile('Email', emailController, isEmailEditable, () {
                setState(() {
                  isEmailEditable = !isEmailEditable;
                });
              }),
              buildEditableTile(
                  'Phone Number', phoneController, isPhoneEditable, () {
                setState(() {
                  isPhoneEditable = !isPhoneEditable;
                });
              }),
              buildEditableTile(
                  'Owner Name', OwnerNameController, isOwnerNameEditable, () {
                setState(() {
                  isOwnerNameEditable = !isOwnerNameEditable;
                });
              }),
              buildEditableTile(
                  'Shop Name', shopNameController, isShopNameEditable, () {
                setState(() {
                  isShopNameEditable = !isShopNameEditable;
                });
              }),
              buildEditableTile(
                  'Shop Address', shopAddressController, isShopAddressEditable,
                  () {
                setState(() {
                  isShopAddressEditable = !isShopAddressEditable;
                });
              }),

              // Dropdown for selecting district
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0), // Proper padding for the location section
                child: _buildDropdownField(
                  labelText: 'District',
                  hintText: 'Select your district',
                  value: selectedDistrict.isNotEmpty ? selectedDistrict : null,
                  items: districtOptions,
                  icon: Icons.location_on,
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value!;
                    });
                  },
                ),
              ),

              buildEditableTile('Shop Description', shopDescriptionController,
                  isShopDescriptionEditable, () {
                setState(() {
                  isShopDescriptionEditable = !isShopDescriptionEditable;
                });
              }),

              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  handleUpdateUserProfile();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => TP_Dashboard(),
                  //   ),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  backgroundColor: Colors.amber[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to create section titles
  Widget buildProfileCard(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.amber[700],
          ),
        ),
      ),
    );
  }

  // Editable tiles with card design
  Widget buildEditableTile(String label, TextEditingController controller,
      bool isEditable, VoidCallback onTap) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: isEditable
            ? TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
              )
            : Text(
                controller.text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
        trailing: Icon(Icons.edit, color: Colors.amber[700]),
        onTap: onTap,
      ),
    );
  }

  // Dropdown menu for district selection
  Widget _buildDropdownField({
    required String labelText,
    required String hintText,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.amber[700]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        icon: Icon(Icons.arrow_drop_down, color: Colors.amber[700]),
      ),
    );
  }
}
