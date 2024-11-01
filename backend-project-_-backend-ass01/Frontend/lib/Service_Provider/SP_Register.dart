import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Service_Provider/SP_Dashboard.dart';
import 'package:tap_on/Service_Provider/SP_Location.dart';
import 'package:tap_on/Service_Provider/SP_Login.dart';
import 'package:tap_on/services/geo_services.dart';
import 'package:tap_on/widgets/Loading.dart';

class SP_Register extends StatefulWidget {
  const SP_Register({super.key});
  @override
  _SP_RegisterState createState() => _SP_RegisterState();
}

class _SP_RegisterState extends State<SP_Register> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController serviceTitleController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoadingLocation = false;
  String _currentAddress = "";
  double? _latitude;
  double? _longitude;

  List<String> locationOptions = [
    "Colombo",
    "Gampaha",
    "Kalutara",
    "Kandy",
    "Matale",
    "Nuwara Eliya",
    "Galle",
    "Matara",
    "Hambantota",
    "Jaffna",
    "Kilinochchi",
    "Mannar",
    "Vavuniya",
    "Batticaloa",
    "Ampara",
    "Trincomalee",
    "Polonnaruwa",
    "Anuradhapura",
    "Dambulla",
    "Kurunegala",
    "Puttalam",
    "Ratnapura",
    "Kegalle",
    "Badulla",
    "Monaragala",
  ];

  String selectedLocation = "";

  String? selectedCategory; // To store selected category
  final List<String> categories = [
    'Plumber',
    'Electrician',
    'Carpenter',
    'Painter',
    'Gardener',
    'Fridge Repair',
    'Beauty Professional',
    'Phone Repair',
    'Other'
  ]; // Category list

  bool isAgreed = false;

  // Method to handle registration process
  Future<void> registerServiceProvider() async {
    LoadingDialog.show(context); // Show loading dialog
    if (_formKey.currentState!.validate() && isAgreed) {
      try {
        final locationCordinates =
            await getCoordinatesFromCity(selectedLocation);
        // Preparing the data to send to backend
        Map<String, dynamic> providerData = {
          "name": nameController.text,
          "service_title": serviceTitleController.text,
          "phone": phoneController.text.toString(),
          "address": addressController.text,
          "location_long": locationCordinates["longitude"] == 0.0
              ? 1.0
              : locationCordinates["longitude"],
          "location_lat": locationCordinates["latitude"] == 0.0
              ? 1.0
              : locationCordinates["latitude"],
          "email": emailController.text,
          "category": selectedCategory!,
          "description": descriptionController.text,
          "password": passwordController.text,
          "pic": "N/A"
        };
        // API call for service provider registration
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final baseURL = dotenv.env['BASE_URL']; // Get the base URL
        final response = await http.post(
            Uri.parse('$baseURL/service-provider/registration'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(providerData)); // Send a POST request to the API
        final data = jsonDecode(response.body); // Decode the response
        final status = data['status']; // Get the status from the response

        if (status == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('serviceProviderId', data['data']['_id'] ?? '');
          await prefs.setString(
              'serviceProviderEmail', data['data']['email'] ?? '');
          await prefs.setString(
              'toolProvidershopName', data['data']['shop_name'] ?? '');
          await prefs.setString(
              'serviceProviderName', data['data']['name'] ?? '');
          LoadingDialog.hide(context); // Hide the loading dialog
          // Successfully saved data to MongoDB, navigate to the dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SP_Dashboard(),
            ),
          );
          print('Provider Details successfully Registered');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
        } else {
          // Handle error from the backend
          print('Failed to save data. Status code: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save data: ${response.body}')),
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
      } catch (error) {
        LoadingDialog.hide(context); // Hide the loading dialog
        print('Error occurred while submitting data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred while submitting data')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = 'Location services are disabled.';
        _isLoadingLocation = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = 'Location permissions are denied';
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = 'Location permissions are permanently denied';
        _isLoadingLocation = false;
      });
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
      _locationController.text = place.locality ?? '';
      _isLoadingLocation = false;
    });
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
              MaterialPageRoute(builder: (context) => SP_Login()),
            );
            // Action when the button is pressed
          },
        ),
        backgroundColor: Colors.yellow[700],
        title: Text('Service Provider Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: nameController,
                labelText: 'Name',
                hintText: 'Enter your name',
                icon: Icons.person,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: serviceTitleController,
                labelText: 'Service Title',
                hintText: 'Enter your occupation',
                icon: Icons.work,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: phoneController,
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                keyboardType: TextInputType.phone,
                icon: Icons.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: addressController,
                labelText: 'Address',
                hintText: 'Enter your address',
                icon: Icons.home,
              ),

              // Add Location Button styled like an input field
              InkWell(
                onTap: () {
                  _getCurrentLocation();
                }, // Handle the location selection here
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.add_location,
                          color: Colors.black), // Updated color to grey
                      labelText: 'Add Location',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _locationController.text != '' ||
                              _locationController.text.isNotEmpty
                          ? _locationController.text
                          : 'Select your location',
                      style: TextStyle(
                        color: selectedLocation != null
                            ? Colors.black
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Location Input Field with Icon
              _buildDropdownField(
                labelText: "Select Your District",
                hintText: 'Choose your district',
                value: selectedLocation.isNotEmpty ? selectedLocation : null,
                items: locationOptions,
                icon: Icons.location_on,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: emailController,
                labelText: 'Email',
                hintText: 'Enter your email',
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Password Field
              _buildTextField(
                controller: passwordController,
                labelText: 'Password',
                hintText: 'Enter your password',
                obscureText: true,
                icon: Icons.lock,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Confirm Password Field
              _buildTextField(
                controller: confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                obscureText: true,
                icon: Icons.lock,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Description Field
              _buildTextField(
                controller: descriptionController,
                labelText: 'Description',
                hintText: 'Enter a brief description of your services',
                maxLines: 3,
                icon: Icons.description,
              ),
              const SizedBox(height: 16.0),
              // Dropdown for category selection
              _buildDropdownField(
                labelText: 'Select Category',
                hintText: 'Choose your category',
                value: selectedCategory,
                items: categories,
                icon: Icons.category,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Terms and Conditions',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'By using the Handyman App, you agree to these terms. Provide '
                'accurate information during registration. You are responsible for '
                'keeping your account details secure. Must ensure tools are '
                'described accurately, safe, and functional. The app only connects '
                'users and providers. We are not responsible for the quality or '
                'outcome of services or tools provided. You must provide accurate '
                'contact information.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  const Text('Do You Agree?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  Checkbox(
                    value: isAgreed,
                    onChanged: (bool? value) {
                      setState(() {
                        isAgreed = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  onPressed: isAgreed ? registerServiceProvider : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.yellow[700], // Button color
                  ), // Disable if not agreed
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build text field with icon
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool obscureText = false,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }

  // Method to build dropdown field with icon
  Widget _buildDropdownField({
    required String labelText,
    required String hintText,
    required String? value,
    required List<String> items,
    required IconData icon,
    ValueChanged<String?>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
