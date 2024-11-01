import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:tap_on/Service_Provider/SP_Register.dart';

class SP_Location extends StatefulWidget {
  const SP_Location({super.key});

  @override
  _SP_LocationState createState() => _SP_LocationState();
}

class _SP_LocationState extends State<SP_Location> {
  final TextEditingController _locationController = TextEditingController();
  bool _isLoadingLocation = false;
  String _currentAddress = "";
  LatLng? currentPosition;
  double? _latitude;
  double? _longitude;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
        _isLoadingLocation = false;

        _addMarker(LatLng(_latitude!, _longitude!), 'My Current Location');

        // Ensure the controller is initialized
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(_latitude!, _longitude!),
              15,
            ),
          );
        }
      });
    } catch (e) {
      _showError('Error fetching location: $e');
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _addMarker(LatLng position, String markerId) {
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(
          title: markerId,
          snippet: "Lat: ${position.latitude}, Lng: ${position.longitude}"),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  void _goToCurrentLocation() async {
    final loc.Location location = loc.Location();
    final currentLocation = await location.getLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      setState(() {
        currentPosition = LatLng(
          currentLocation.latitude ?? 0.0,
          currentLocation.longitude ?? 0.0,
        );
      });

      // Ensure the controller is initialized before using it
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentPosition!, zoom: 14),
          ),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SP_Register()),
            );
          },
        ),
        title: Text('Set Delivery Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Enter a location',
                suffixIcon: Icon(Icons.save),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: Icon(Icons.my_location),
                label: Text('Use My Current Location'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.amber,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            _isLoadingLocation
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_currentAddress.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Current Address: $_currentAddress',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      if (_latitude != null && _longitude != null)
                        Text(
                          'Latitude: $_latitude, Longitude: $_longitude',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      if (_latitude == null && _longitude == null)
                        Text(
                          'No location selected',
                          style: TextStyle(fontSize: 16.0),
                        ),
                    ],
                  ),
            SizedBox(height: 16.0),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(48.8566, 2.3522),
                      zoom: 6,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    markers: _markers,
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton(
                      onPressed: _goToCurrentLocation,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.add_location_alt),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SP_Register()));
                },
                icon: Icon(Icons.search),
                label: Text('Save'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  backgroundColor: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
