import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:tap_on/Tool_Provider/TP_Dashboard.dart';
import 'package:tap_on/Tool_Provider/TP_Register.dart';
import 'package:tap_on/widgets/Loading.dart';
import 'package:http/http.dart' as http;

class TP_Login extends StatefulWidget {
  const TP_Login({super.key});

  @override
  State<TP_Login> createState() => _TP_LoginState();
}

class _TP_LoginState extends State<TP_Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> handleTPLogin() async {
    LoadingDialog.show(context); // Show the loading dialog
    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        LoadingDialog.hide(context); // Hide the loading dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: 'Oops...',
          text: 'Please fill in all fields.',
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        );
        return;
      } else {
        // Add login logic here
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final baseURL = dotenv.env['BASE_URL']; // Get the base URL
        final token =
            prefs.getString('token'); // Get the token from shared preferences
        final credentials = {
          "email": emailController.text,
          "password": passwordController.text,
        };
        final response = await http.post(Uri.parse('$baseURL/shop/login/owner'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': '$token',
            },
            body: json.encode(credentials)); // Send a POST request to the API
        final data = jsonDecode(response.body); // Decode the response
        final status = data['status']; // Get the status from the response

        debugPrint(data.toString());

        if (status == 200) {
          await prefs.setString(
              'toolProviderId', data['data']['user']['_id'] ?? '');
          await prefs.setString(
              'toolProviderEmail', data['data']['user']['email'] ?? '');
          await prefs.setString(
              'toolProviderName', data['data']['user']['name'] ?? '');
          LoadingDialog.hide(context); // Hide the loading dialog
          // Successfully saved data to MongoDB, navigate to the dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TP_Dashboard(),
            ),
          );
          print('Provider Login successfully ');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
        } else {
          // Handle error from the backend
          print('Failed to save data. Status code: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save data: ${data['message']}')),
          );
          // Show an error alert if the status is not 200
          LoadingDialog.hide(context); // Hide the loading dialog
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Oops...',
            text: data['message'],
            backgroundColor: Colors.black,
            titleColor: Colors.white,
            textColor: Colors.white,
          ); // Show an error alert
        }
      }
    } catch (e) {
      LoadingDialog.hide(context); // Hide the loading dialog
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              // Action when the button is pressed
            },
          ),
          title: const Text('TapOn'),
          backgroundColor: Colors.amber[700],
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40), // Space between logo and text fields

              // Mobile number or email field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Mobile number or email',
                ),
              ),
              SizedBox(height: 20),

              // Password field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 20),

              // Log in button
              ElevatedButton(
                onPressed: () {
                  handleTPLogin();
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => TP_Dashboard()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Log in'),
              ),
              SizedBox(height: 10),

              // Forgot password text
              Center(
                child: TextButton(
                  onPressed: () {
                    // Add forgot password logic here
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Colors.amber[700],
                    ),
                  ),
                ),
              ),

              Spacer(), // Push the "Create new account" button to the bottom

              // Create new account button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TP_Register()));
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 18,
                  ),
                  side: BorderSide(color: Colors.amber),
                ),
                child: Text('Register as Shop Owner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
