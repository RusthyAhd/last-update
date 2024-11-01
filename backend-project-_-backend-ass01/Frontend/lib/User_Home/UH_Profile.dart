import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/widgets/Loading.dart';

class UH_Profile extends StatefulWidget {
  const UH_Profile({super.key});

  @override
  _UH_ProfileState createState() => _UH_ProfileState();
}

class _UH_ProfileState extends State<UH_Profile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  String fullName = '';
  String phoneNumber = '';
  String email = '';
  DateTime birthday = DateTime.now();
  String gender = 'Male';
  String address = '';
  String location = '';
  File? profilePhoto;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('fullName') ?? '';
    final phone = prefs.getString('phoneNumber');
    final mail = prefs.getString('email');
    final birth = prefs.getString('birthday');
    final add = prefs.getString('address');
    final loc = prefs.getString('location');
    setState(() {
      _nameController.text = name;
      _phoneController.text = phone!;
      _emailController.text = mail!;
      _addressController.text = add!;
      _locationController.text = loc!;
    });
  }

  Future<void> createOrUpdateProfile() async {
    LoadingDialog.show(context); // Show loading dialog
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Prepare the request body
        final requestBody = {
          'fullName': _nameController.text,
          'phoneNumber': _phoneController.text,
          'email': _emailController.text,
          'birthday': birthday.toIso8601String(),
          'gender': gender,
          'address': _addressController.text,
          'location': _locationController.text,
          "profilePhoto": 'N/A',
        };

        SharedPreferences prefs = await SharedPreferences.getInstance();
        final baseURL = dotenv.env['BASE_URL']; // Get the base URL
        final accessToken = prefs.getString('token'); // Get access token
        final response = await http.post(Uri.parse('$baseURL/profile/cu'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': '$accessToken',
            },
            body: json.encode(requestBody)); // Send a POST request to the API
        final data = jsonDecode(response.body); // Decode the response
        final status = data['status']; // Get the status from the response

        if (status == 200) {
          // Successfully created or updated the profile
          await prefs.setString(
              'token', data['data']['token'] ?? ''); // Save the token
          debugPrint(data['data']['user']['phoneNumber']);
          await prefs.setString(
              'phoneNumber',
              data['data']['user']['phoneNumber'] ??
                  ''); // Save the phone number
          await prefs.setString('fullName',
              data['data']['user']['fullName'] ?? ''); // Save the full name
          await prefs.setString(
              'email', data['data']['user']['email'] ?? ''); // Save the email
          await prefs.setString(
              'profileImage',
              data['data']['user']['profileImage'] ??
                  ''); // Save the profile image
          if (data['data']['user']['birthday'] != null) {
            await prefs.setString('birthday',
                data['data']['user']['birthday'] ?? ''); // Save the birthday
          }
          await prefs.setString('gender',
              data['data']['user']['gender'] ?? ''); // Save the gender
          await prefs.setString('location',
              data['data']['user']['location'] ?? ''); // Save the location
          await prefs.setString('address',
              data['data']['user']['address'] ?? ''); // Save the address
          LoadingDialog.hide(context); // Hide the loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Profile updated successfully',
            autoCloseDuration: const Duration(seconds: 2),
            showConfirmBtn: false,
          );
        } else {
          // Handle error
          LoadingDialog.hide(context); // Hide the loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile')),
          );
        }
      } catch (e) {
        print(e);
        LoadingDialog.hide(context); // Hide the loading dialog
      }
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profilePhoto = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Management'),
        backgroundColor: Colors.amber[700],
        elevation: 2,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Center(
                  child: Stack(
                    children: [
                      profilePhoto != null
                          ? CircleAvatar(
                              radius: 50.0,
                              backgroundImage: FileImage(profilePhoto!),
                              backgroundColor: Colors.grey[200],
                            )
                          : CircleAvatar(
                              radius: 50.0,
                              child: Icon(
                                Icons.person,
                                size: 50.0,
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber[700],
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your full name'
                            : null,
                        onSaved: (value) => fullName = value!,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your phone number'
                            : null,
                        onSaved: (value) => phoneNumber = value!,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                        onSaved: (value) => email = value!,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Birthday',
                          hintText: 'Select your birthday',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: birthday,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null && pickedDate != birthday) {
                            setState(() {
                              birthday = pickedDate;
                            });
                          }
                        },
                        controller: TextEditingController(
                          text: "${birthday.toLocal()}"
                              .split(' ')[0], // Show selected date
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: gender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: <String>['Male', 'Female', 'Other']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            gender = newValue!;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.home),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your address' : null,
                        onSaved: (value) => address = value!,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'District',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your district'
                            : null,
                        onSaved: (value) => location = value!,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: createOrUpdateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 60),
                  child: Text('Save Profile', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
