import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:tap_on/Tool_Provider/TP_Dashboard.dart';
import 'package:tap_on/Tool_Provider/TP_Location.dart';
import 'package:tap_on/Tool_Provider/TP_Login.dart';
import 'package:tap_on/services/geo_services.dart';
import 'package:tap_on/widgets/Loading.dart';

class TP_Register extends StatefulWidget {
  const TP_Register({super.key});

  @override
  _TP_RegisterState createState() => _TP_RegisterState();
}

class _TP_RegisterState extends State<TP_Register> {
  // Create controllers for each TextField
  final TextEditingController nameController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoadingLocation = false;
  String _currentAddress = "";
  double? _latitude;
  double? _longitude;

  List<String> genderOptions = [
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

  String selectedGender = "";
  bool isAgreed = false; // Track if the user has agreed to the terms
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  String? selectedCategory; // Variable to hold the selected category

  // List of categories for the dropdown
  final List<String> categories = [
    'Plumbing Tools',
    'Electrical Tools',
    'Carpenting Tools',
    'Painting Tools',
    'Gardening Tools',
    'Repairing Tools',
    'Building Tools',
    'Phone Accessories',
    'Other',
  ];

  get selectedLocation => null;

  // Function to handle the submission of form data
  Future<void> registerOwner() async {
    if (_formKey.currentState!.validate() && isAgreed) {
      // Prepare the data for submission
      Map<String, String> shopownerData = {
        'name': nameController.text,
        'shop_name': shopNameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'location': selectedGender,
        'email': emailController.text,
        'category': selectedCategory ?? '',
        'password': passwordController.text,
        'confirmPassword': confirmPasswordController.text,
      };

      print('Submitting data: $shopownerData'); // Debug print

      try {
        // Send POST request to backend with user data
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final baseURL = dotenv.env['BASE_URL']; // Get the base URL
        final token =
            prefs.getString('token'); // Get the token from shared preferences
        var response = await http.post(
          Uri.parse('$baseURL/shopregistration'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$token',
          },
          body: jsonEncode(shopownerData),
        );

        if (response.statusCode == 200) {
          // Successfully saved data to MongoDB, navigate to the dashboard
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TP_Dashboard(),
            ),
          );
          print('Shopowner Details successfully Registered');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
        } else {
          // Handle error from the backend
          print('Failed to save data. Status code: ${response.statusCode}');
          print(
              'Response body: ${response.body}'); // Print response body for more info
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save data: ${response.body}')),
          );
        }
      } catch (error) {
        print('Error occurred while submitting data: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error occurred while submitting data')),
        );
      }
    }
  }

  Future<void> registerToolProvider() async {
    LoadingDialog.show(context); // Show loading dialog
    if (_formKey.currentState!.validate() && isAgreed) {
      try {
        final userLocation = _locationController.text != '' ||
                _locationController.text.isNotEmpty
            ? _locationController.text
            : selectedGender;
        final locationCordinates = await getCoordinatesFromCity(userLocation);
        // Preparing the data to send to backend
        Map<String, dynamic> providerData = {
          "name": nameController.text,
          "shop_name": shopNameController.text,
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
          "password": passwordController.text,
          "confirmPassword": confirmPasswordController.text,
          "pic": "N/A"
        };
        // API call for service provider registration
        final baseURL = dotenv.env['BASE_URL']; // Get the base URL
        final response = await http.post(
            Uri.parse('$baseURL/shop/registration'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(providerData)); // Send a POST request to the API
        final data = jsonDecode(response.body); // Decode the response
        final status = data['status']; // Get the status from the response

        if (status == 200) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('toolProviderId', data['data']['_id'] ?? '');
          await prefs.setString(
              'toolProviderEmail', data['data']['email'] ?? '');
          await prefs.setString(
              'toolProvidershopName', data['data']['shop_name'] ?? '');
          await prefs.setString('toolProviderName', data['data']['name'] ?? '');
          LoadingDialog.hide(context); // Hide the loading dialog
          // Successfully saved data to MongoDB, navigate to the dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TP_Dashboard(),
            ),
          );
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
    } else {
      LoadingDialog.hide(context);
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
              MaterialPageRoute(builder: (context) => TP_Login()),
            );
            // Action when the button is pressed
          },
        ),
        backgroundColor: Colors.yellow[700],
        title: const Text(
          'Shop Owner Registration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Assign the form key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTextField(
                  controller: nameController,
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  icon: Icons.person,
                ),
                _buildTextField(
                  controller: shopNameController,
                  labelText: 'Shop Name',
                  hintText: 'Enter your shop name',
                  icon: Icons.store,
                ),
                _buildTextField(
                  controller: phoneController,
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
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
                            color: Colors.blue), // Updated color to grey
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

                _buildDropdownField(
                  labelText: 'Select Your District',
                  hintText: 'Select your district',
                  value: selectedGender.isNotEmpty ? selectedGender : null,
                  items: genderOptions,
                  icon: Icons.location_on,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                _buildTextField(
                  controller: emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                _buildTextField(
                  controller: confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                _buildDropdownField(
                  labelText: 'Category',
                  hintText: 'Select your category',
                  value: selectedCategory,
                  items: categories,
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
                const SizedBox(height: 20),
                const Text('Terms and Conditions',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  'By using the Handyman App, you agree to these terms. Provide '
                  'accurate information during registration. You are responsible for '
                  'keeping your account details secure. Must ensure tools are '
                  'described accurately, safe, and functional. The app only connects '
                  'users and providers. We are not responsible for the quality or '
                  'outcome of services or tools provided.',
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
                    onPressed: isAgreed ? registerToolProvider : null,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.yellow[700],
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ).copyWith(elevation: ButtonStyleButton.allOrNull(5)),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    IconData? icon,
    bool obscureText = false,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String labelText,
    required String hintText,
    required String? value,
    required List<String> items,
    IconData? icon,
    ValueChanged<String?>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
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
