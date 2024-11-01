import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tap_on/Home%20page.dart';

class UT_Waiting extends StatefulWidget {
  const UT_Waiting({super.key});

  @override
  _UT_WaitingState createState() => _UT_WaitingState();
}

class _UT_WaitingState extends State<UT_Waiting> {
  GoogleMapController? mapController;
  final LatLng _center =
      const LatLng(6.7956, 79.9004); // Coordinates for the map

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map widget
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.0,
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                // Add your back button functionality here
              },
            ),
          ),

          // Centered Pickup Button
          Positioned(
            bottom: 250,
            left: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle pickup button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button background color
                    shape: CircleBorder(), // Circular button shape
                    padding: EdgeInsets.all(24), // Button padding
                  ),
                  child: Text("Pickup"),
                ),
              ],
            ),
          ),

          // Connecting to a driver text and progress bar
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Connecting to a driver....',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  minHeight: 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                    // Try now button functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Button background color
                  ),
                  child: Text("Try Again"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
