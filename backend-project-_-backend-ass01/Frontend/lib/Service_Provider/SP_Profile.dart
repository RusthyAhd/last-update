import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tap_on/Service_Provider/SP_Dashboard.dart';
import 'package:tap_on/services/geo_services.dart';

class SP_Profile extends StatefulWidget {
  const SP_Profile({super.key});

  @override
  _SP_ProfileState createState() => _SP_ProfileState();
}

class _SP_ProfileState extends State<SP_Profile> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for each field
  TextEditingController emailController =
      TextEditingController(text: 'rishaf.ho@merchant.lk');
  TextEditingController phoneController =
      TextEditingController(text: '0740710280');
  TextEditingController NameController = TextEditingController(text: 'Rishaf');
  TextEditingController shopNameController =
      TextEditingController(text: 'Shop Name(if have)');
  TextEditingController AddressController =
      TextEditingController(text: 'No-02,Kinniya');
  TextEditingController LocationController =
      TextEditingController(text: 'city,postal code');
  TextEditingController DescriptionController =
      TextEditingController(text: 'More Details in occupation(achievement) ');
  File? _image;
  // Boolean flags to toggle the editability of each field
  bool isEmailEditable = false;
  bool isPhoneEditable = false;
  bool isNameEditable = false;
  bool isShopNameEditable = false;
  bool isAddressEditable = false;
  bool isLocationEditable = false;
  bool isDescriptionEditable = false;
  String _previousEmail = '';
  Map<String, dynamic> userData = {
    'name': '',
    'email': '',
    'phone': '',
    'address': '',
    'location': '',
    'description': '',
  };

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    await getUserProfile();
  }

  // Function to pick an image from the gallery or take a new picture
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Show dialog to choose between camera and gallery
    final pickedFile = await showDialog<XFile>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context)
                    .pop(await picker.pickImage(source: ImageSource.camera));
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context)
                    .pop(await picker.pickImage(source: ImageSource.gallery));
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );

    // Set the image if one was selected
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> getUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      final token =
          prefs.getString('token'); // Get the token from shared preferences
      final providerEmail = prefs.getString('serviceProviderEmail');

      final response = await http.get(
          Uri.parse('$baseURL/service-provider/find?email=$providerEmail'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token',
          }); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      if (status == 200) {
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
        final userDetails = {
          'name': profile['name'] ?? '',
          'email': profile['email'] ?? '',
          'phone': profile['phone'] ?? '',
          'address': profile['address'] ?? '',
          'location': location ?? 'unknown',
          'description': profile['description'] ?? '',
        };
        setState(() {
          userData = userDetails;
          emailController.text = profile['email'];
          phoneController.text = profile['phone'];
          NameController.text = profile['name'];
          shopNameController.text = profile['service_title'];
          AddressController.text = profile['address'];
          LocationController.text = location ?? 'unknown';
          DescriptionController.text = profile['description'];
          _previousEmail = providerEmail ?? profile['email'];
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
    if (userData['email'] == emailController.text &&
        userData['phone'] == phoneController.text &&
        userData['name'] == NameController.text &&
        userData['address'] == AddressController.text &&
        userData['description'] == DescriptionController.text &&
        userData['service_title'] == shopNameController.text &&
        userData['location'] == LocationController.text) {
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
          await getCoordinatesFromCity(LocationController.text);

      final profileData = {
        "previous_email": _previousEmail,
        'name': NameController.text,
        'service_title': shopNameController.text,
        'phone': phoneController.text,
        'address': AddressController.text,
        "location_long": locationCordinates["longitude"] == 0.0
            ? 1.0
            : locationCordinates["longitude"],
        "location_lat": locationCordinates["latitude"] == 0.0
            ? 1.0
            : locationCordinates["latitude"],
        'description': DescriptionController.text,
        'email': emailController.text,
      };
      final response =
          await http.put(Uri.parse('$baseURL/service-provider/update/provider'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': '$token',
              },
              body: json.encode(profileData)); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      if (status == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Profile updated successfully',
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        );
        _previousEmail = emailController.text;
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
    NameController.dispose();
    shopNameController.dispose();
    AddressController.dispose();
    LocationController.dispose();
    DescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provider Profile'),
        backgroundColor: Colors.amber[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SP_Dashboard()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _image == null
                    ? Text('No image selected.')
                    : ClipOval(
                        child: Image.file(
                          _image!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                SizedBox(height: 20),
                // Button to pick a new image
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Change Profile'),
                ),

                SizedBox(height: 10),
                Text(
                  userData['name'],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  userData['address'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                buildInfoSection('Account'),
                buildEditableTile('Email', emailController, isEmailEditable,
                    () {
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
                buildEditableTile('Name', NameController, isNameEditable, () {
                  setState(() {
                    isNameEditable = !isNameEditable;
                  });
                }),
                buildEditableTile(
                    'Shop Name', shopNameController, isShopNameEditable, () {
                  setState(() {
                    isShopNameEditable = !isShopNameEditable;
                  });
                }),
                buildEditableTile(
                    ' Address', AddressController, isAddressEditable, () {
                  setState(() {
                    isAddressEditable = !isAddressEditable;
                  });
                }),
                buildEditableTile(
                    'Shop Location', LocationController, isLocationEditable,
                    () {
                  setState(() {
                    isLocationEditable = !isLocationEditable;
                  });
                }),
                buildEditableTile('Shop Description', DescriptionController,
                    isDescriptionEditable, () {
                  setState(() {
                    isDescriptionEditable = !isDescriptionEditable;
                  });
                }),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        handleUpdateUserProfile();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => SP_Dashboard()),
                        //);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: (Colors.black),
                        foregroundColor: Colors.yellow
                        // Full width button
                        ),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoSection(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Function to build an editable/non-editable tile
  Widget buildEditableTile(String label, TextEditingController controller,
      bool isEditable, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: isEditable
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (label == 'Email') {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                      .hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                } else if (label == 'Phone Number') {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit phone number';
                  }
                }
                return null;
              },
            )
          : Text(
              controller.text,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap, // Toggle edit mode for the specific field
    );
  }
}
