import 'package:flutter/material.dart';
import 'package:tap_on/User_Service/US_Location.dart';

class US_ProviderConfirmation extends StatelessWidget {
  const US_ProviderConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[600],
      body: SafeArea(
        child: Column(
          children: [
            // Top Banner with ETA
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.black,
              child: const Center(
                child: Text(
                  "On the way to pick up your service\nin 2 mins",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Service Provider Info
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Plumber Info
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 30,
                    child: Icon(Icons.plumbing, size: 40, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Plumber",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Mohammed Rishaf",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Task Completed",
                        style: TextStyle(fontSize: 14, color: Colors.green),
                      ),
                      Row(
                        children: [
                          Text(
                            "Rating: ",
                            style: TextStyle(fontSize: 14),
                          ),
                          Icon(Icons.star, color: Colors.yellow, size: 14),
                          Text("4.9", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),

                  // Contact buttons (Message & Call)
                  Row(
                    children: [
                      IconButton(
                        icon:
                            Icon(Icons.message, size: 28, color: Colors.black),
                        onPressed: () {
                          // Message functionality
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.call, size: 28, color: Colors.black),
                        onPressed: () {
                          // Call functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Service Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Service Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Our plumber is your go-to expert for all plumbing needs. With years of experience, they handle everything from leaks to renovations with precision and professionalism, ensuring top-quality results every time.",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Map Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: Center(
                  child: Text("Map View Here", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Trip Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Trip Fare",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "LKR 259.00",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Distance for this journey",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "4.58 Km",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Duration for this journey",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "12.67 Mins",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Spacer(),

            // Cancel Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => US_Location(category: '')),
                  );
                  // Cancel button functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Background color
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
