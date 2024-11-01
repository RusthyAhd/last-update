import 'package:flutter/material.dart';
import 'package:tap_on/User_Home/EnterNumber.dart';




class LaunchPage extends StatelessWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.amber[700],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circle Avatar with image
              CircleAvatar(
                radius: 180,
                backgroundColor: const Color.fromARGB(255, 252, 250, 250),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40), 
              const Text(
                'Discover new interests.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Empower your team with our application',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EnterNumber()));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Button color
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, color: Colors.blue)),
                child: Text('GET STARTED'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
