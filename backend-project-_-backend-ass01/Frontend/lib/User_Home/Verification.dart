import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:tap_on/User_Home/EnterNumber.dart';
import 'package:http/http.dart' as http;
import 'package:tap_on/widgets/Loading.dart';

class Verification extends StatefulWidget {
  final String phoneNumber;
  Verification({
    required this.phoneNumber,
  });

  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  // List of TextEditingControllers for the 6 text fields
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  // List of FocusNodes for the 6 text fields
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    // Dispose the controllers and focus nodes
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // handleVerifyOTP function
  void handleVerifyOTP() async {
    LoadingDialog.show(context); // Show loading dialog
    // Combine the OTP from the 6 text fields
    final otp = _controllers.map((controller) => controller.text).join();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // Verify the OTP
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      final response =
          await http.post(Uri.parse('$baseURL/auth/otp/verify'), body: {
        'otp': otp.toString(),
        'phoneNumber': widget.phoneNumber,
      }); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response
      // Check if the status is 200
      if (status == 200) {
        await prefs.setString(
            'token', data['data']['token'] ?? ''); // Save the token
        await prefs.setString(
            'userId', data['data']['user']['_id'] ?? ''); // Save the user ID
        await prefs.setString('phoneNumber',
            data['data']['user']['phoneNumber'] ?? ''); // Save the phone number
        await prefs.setString('fullName',
            data['data']['user']['fullName'] ?? ''); // Save the full name
        await prefs.setString(
            'email', data['data']['user']['email'] ?? ''); // Save the email
        // await prefs.setString(
        //     'profileImage',
        //     data['data']['user']['profileImage'] ??
        //         ''); // Save the profile image
        if (data['data']['user']['birthday'] != null) {
          await prefs.setString('birthday',
              data['data']['user']['birthday'] ?? ''); // Save the birthday
        }
        await prefs.setString(
            'gender', data['data']['user']['gender'] ?? ''); // Save the gender
        await prefs.setString('location',
            data['data']['user']['location'] ?? ''); // Save the location
        await prefs.setString('address',
            data['data']['user']['address'] ?? ''); // Save the address
        LoadingDialog.hide(context); // Hide the loading dialog
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const HomePage())); // Navigate to the Home page
      } else {
        LoadingDialog.hide(context);

        // Show an error message if the OTP is incorrect
        final message = data['message']; // Get the message from the response
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'OTP Error',
          text: message,
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        ); // Show an error alert
      }
    } catch (e) {
      // Show an error message if an error occurs
      LoadingDialog.hide(context); // Hide the loading dialog
      debugPrint('Something went wrong - $e'); // Print the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC342),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter SMS Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      counterText: '', // Removes character counter
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        // Move to the next field if the current one is filled
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        // Move to the previous field if the current one is cleared
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index - 1]);
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EnterNumber()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                  ),
                  child: const Text('Resend Code'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    handleVerifyOTP();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'You should receive the code shortly',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
