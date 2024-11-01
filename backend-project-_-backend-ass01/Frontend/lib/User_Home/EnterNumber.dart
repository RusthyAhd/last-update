import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tap_on/User_Home/Verification.dart';
import 'package:http/http.dart' as http;
import 'package:tap_on/constants.dart';
import 'package:quickalert/quickalert.dart';
import 'package:tap_on/widgets/Loading.dart';

class EnterNumber extends StatefulWidget {
  const EnterNumber({super.key});

  @override
  _EnterNumberState createState() => _EnterNumberState();
}

class _EnterNumberState extends State<EnterNumber> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? validatePhoneNumber(String? value) {
    // Check if the number starts with 0 and is followed by 9 digits
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    } else if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
      return 'Please enter a valid Sri Lankan phone number';
    }

    return null;
  }

  // handleOTPSend function
  void handleOTPSend() async {
    final phoneNumber = _phoneController.text; // Get the phone number
    LoadingDialog.show(context); // Show loading dialog
    try {
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      final response = await http.get(Uri.parse(
          '$baseURL/auth/otp/$phoneNumber')); // Send a GET request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response
      // Check if the status is 200
      if (status == 200) {
        LoadingDialog.hide(context); // Hide the loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Verification(phoneNumber: phoneNumber.toString()),
          ),
        ); // Navigate to the Verification screen
      } else {
        // Show an error alert if the status is not 200
        LoadingDialog.hide(context); // Hide the loading dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'Sorry, something went wrong',
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        ); // Show an error alert
      }
    } catch (e) {
      // Show an error alert if an error occurs
      LoadingDialog.hide(context); // Hide the loading dialog
      debugPrint('Something went wrong $e'); // Print the error
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.orange,
      body: SingleChildScrollView(
        // SingleChildScrollView wrapped correctly
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/image02.jpeg',
                  height: height * 0.50,
                  width: width,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: height * 0.50,
                  width: width,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white],
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    appName,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    slogan,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          labelText: "Enter your Number",
                        ),
                        keyboardType: TextInputType.phone,
                        validator: validatePhoneNumber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        handleOTPSend();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
