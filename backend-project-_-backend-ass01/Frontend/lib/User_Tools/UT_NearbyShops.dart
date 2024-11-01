import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';
import 'package:tap_on/User_Tools/UT_ToolMenu.dart';
import 'package:http/http.dart' as http;
import 'package:tap_on/services/geo_services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;

class UT_NearbyShops extends StatefulWidget {
  final String userLocation;
  final String tool;
  UT_NearbyShops({
    required this.userLocation,
    required this.tool,
  });

  @override
  State<UT_NearbyShops> createState() => _UT_NearbyShopsState();
}

class _UT_NearbyShopsState extends State<UT_NearbyShops> {
  double _latitude = 6.9271;
  double _longitude = 79.8612;
  late GoogleMapController mapController;
  final Set<google_maps.Marker> _markers = {};

  final List<Map<String, dynamic>> serviceProviders = [
    // {
    //   'id': '6710fa1daf3e9327c922ca0d',
    //   'name': 'Icom hardware',
    //   'address': 'ViharaMahathevi Park Road,Town Hall , Colombo',
    //   'rating': 4.5,
    //   'Shipping': 'Free Shipping ',
    //   'image': 'assets/images/muhammed.jpeg',
    // },
    // {
    //   'id': '6710fa1daf3e9327c922ca0d',
    //   'name': 'Salman Store',
    //   'address': 'No.19,Old Boc Lane Kinniya-04',
    //   'rating': 2.9,
    //   'Shipping': 'Free Shipping ',
    //   'image': 'assets/images/salman.jpeg',
    // },
    // {
    //   'id': '6710fa1daf3e9327c922ca0d',
    //   'name': 'Guy Hawkins',
    //   'address': 'Diyagama,Homagama,colombo-5.',
    //   'rating': 4.0,
    //   'Shipping': 'Free Shipping ',
    //   'image': 'assets/images/sarukan.jpeg',
    // },
  ];

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

      final coordinates = await getCoordinatesFromCity(widget.userLocation);

      setState(() {
        _latitude = coordinates['latitude'] ?? 6.9271;
        _longitude = coordinates['longitude'] ?? 79.8612;
      });

      final bodyData = {
        'category': widget.tool,
        "location_long": coordinates['longitude'],
        "location_lat": coordinates['latitude'],
      };

      final response = await http.post(
        Uri.parse('$baseURL/shop/get/all/category/location'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode(bodyData),
      ); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      debugPrint(data.toString());

      if (status == 200) {
        final services = data['data'];
        if (services.length > 0) {
          List<Map<String, dynamic>> providers = [];
          Set<google_maps.Marker> providerMarkers = {};
          for (var service in services) {
            providers.add({
              'id': service['_id'] ?? 'N/A',
              'name': service['shop_name'] ?? 'N/A',
              'address': service['address'] ?? 'N/A',
              'rating': service['rating'] ?? 0.0,
              'Shipping': service['shipping'] ?? 'N/A',
              'image': service['pic'] ?? 'N/A',
              'email': service['_id'] ?? 'N/A',
              'phone': service['phone'] ?? 'N/A',
            });
            if (service['location_lat'] == null ||
                service['location_long'] == null) {
              continue;
            }
            providerMarkers.add(
              google_maps.Marker(
                markerId: google_maps.MarkerId(service['shop_name'] ?? 'N/A'),
                position: google_maps.LatLng(
                    service['location_lat'], service['location_long']),
                infoWindow: google_maps.InfoWindow(
                    title: service['shop_name'] ?? 'N/A'),
              ),
            );
          }
          setState(() {
            serviceProviders.clear();
            serviceProviders.addAll(providers);
            _markers.clear();
            _markers.addAll(providerMarkers);
          });
        }
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
      // Applying a Gradient Background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.yellow[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // AppBar with Custom Styling
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.black, size: 30),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      },
                    ),
                    const Text(
                      'Nearby Tool Shops',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 30),
                    // Placeholder to balance the title alignment
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),

            //Map Placeholder with Glassmorphism Effect
            // Container(
            //   height: 250,
            //   margin: EdgeInsets.symmetric(horizontal: 20),
            //   decoration: BoxDecoration(
            //     color: Colors.white.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(20),
            //     boxShadow: const [
            //       BoxShadow(
            //         color: Colors.black26,
            //         blurRadius: 10,
            //         offset: Offset(0, 5),
            //       )
            //     ],
            //     border:
            //         Border.all(color: Colors.white.withOpacity(0.4), width: 1),
            //   ),
            //   child: FlutterMap(
            //     options: MapOptions(
            //       initialCenter: latlong.LatLng(
            //           _latitude, _longitude), // Starting position
            //       initialZoom: 13.0,
            //       onTap: (tapPosition, point) {
            //         //_addMarker(point);
            //       },
            //     ),
            //     children: [
            //       TileLayer(
            //         urlTemplate:
            //             "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            //       ),
            //       //MarkerLayer(markers: _markers),
            //       flutter_map_lib.MarkerLayer(markers: _markers),
            //     ],
            //   ),
            // ),

            Container(
              height: 250,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
                border:
                    Border.all(color: Colors.white.withOpacity(0.4), width: 1),
              ),
              child: Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            _latitude ?? 6.9388614, _longitude ?? 79.8542005),
                        zoom: 13,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                      markers: _markers,
                    ),

                    // FloatingActionButton positioned on the map
                    // Positioned(
                    //   bottom: 10,
                    //   right: 10,
                    //   child: FloatingActionButton(
                    //     onPressed: _goToCurrentLocation,
                    //     backgroundColor: Colors.grey,
                    //     child: Icon(Icons.add_location_alt),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // List of Service Providers with Enhanced Design
            Expanded(
              child: ListView.builder(
                itemCount: serviceProviders.length,
                itemBuilder: (context, index) {
                  final provider = serviceProviders[index];

                  return GestureDetector(
                    child: Card(
                      elevation: 10,
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey[200]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Provider Image with Circular Design
                            // CircleAvatar(
                            //   radius: 35,
                            //   backgroundImage: MemoryImage(
                            //     base64Decode(provider['image']),
                            //   ),
                            // ),
                            SizedBox(width: 16),
                            // Provider Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    provider['address'],
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),

                                  SizedBox(height: 8),
                                  // Rating Bar with Star Design
                                  Row(
                                    children: [
                                      RatingBar.builder(
                                        initialRating: provider['rating'],
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 20,
                                        itemPadding:
                                            EdgeInsets.symmetric(horizontal: 2),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {},
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        provider['rating'].toString(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // "Choose" Button with Ripple Effect
                            ElevatedButton(
                              onPressed: () {
                                // Pass the shop's name and relevant products
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UT_ToolMenu(
                                      shopName: provider['name'],
                                      shopId: provider['id'],
                                      shopEmail: provider['email'],
                                      shopPhone: provider['phone'],
                                      // products: const [
                                      //   {
                                      //     'title': 'Hammer (New)',
                                      //     'price': 'Rs 1,000',
                                      //     'image': 'assets/images/hammer.jpg',
                                      //     'description':
                                      //         'This is a high-quality new hammer made for heavy-duty usage.',
                                      //   },
                                      //   {
                                      //     'title': 'Pliers (Used)',
                                      //     'price': 'Rs 300',
                                      //     'image': 'assets/images/pliers.jpg',
                                      //     'description':
                                      //         'Used pliers in good condition. Suitable for small repairs.',
                                      //   },
                                      //   {
                                      //     'title': 'Screwdrivers (New)',
                                      //     'price': 'Rs 900',
                                      //     'image':
                                      //         'assets/images/Screwdrivers.jpg',
                                      //     'description':
                                      //         'This is a high-quality new hammer made for heavy-duty usage.',
                                      //   },
                                      //   {
                                      //     'title': 'Wire Stripper (Used)',
                                      //     'price': 'Rs 500',
                                      //     'image':
                                      //         'assets/images/Wire Stripper.jpeg',
                                      //     'description':
                                      //         'This is a high-quality new hammer made for heavy-duty usage.',
                                      //   },
                                      //   {
                                      //     'title':
                                      //         'Flame Retardant Shirt (New)',
                                      //     'price': 'Rs 680',
                                      //     'image':
                                      //         'assets/images/Flame Retardant Shirt.jpg',
                                      //     'description':
                                      //         'This is a high-quality new hammer made for heavy-duty usage.',
                                      //   },
                                      //   // Add more products for the shop here...
                                      // ],
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                elevation: 5,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Choose',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
