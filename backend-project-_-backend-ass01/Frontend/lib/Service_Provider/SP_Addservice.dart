import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Service_Provider/SP_Dashboard.dart';
import 'package:tap_on/services/geo_services.dart';
import 'package:tap_on/widgets/Loading.dart';
import 'package:http/http.dart' as http;

class SP_Addservice extends StatefulWidget {
  const SP_Addservice({super.key});

  @override
  _SP_AddserviceState createState() => _SP_AddserviceState();
}

class _SP_AddserviceState extends State<SP_Addservice> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  bool isNew = true;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  File? _image;
  double _totalAmount = 0.0; // Store total amount, initially 0
  double _discount = 0.0; // To store the discount value
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  // Function to update total amount based on the price entered
  void _updateTotalAmount() {
    setState(() {
      _totalAmount = double.tryParse(_priceController.text) ?? 0.0;
    });
  }

  // Function to apply the discount
  void _applyDiscount() {
    setState(() {
      _discount = double.tryParse(_discountController.text) ?? 0.0;
      _totalAmount = (double.tryParse(_priceController.text) ?? 0.0) -
          _discount; // Adjust total amount
    });
  }

  // Weekdays selection
  final List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> selectedWeekdays = [];

// Function to pick a time
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  //pick image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  bool enableTimeDuration = false;
  TextEditingController timeDurationController = TextEditingController();

  void handleSaveService() async {
    // Save the service details
    LoadingDialog.show(context); // Show loading dialog
    try {
      final locationCordinates =
          await getCoordinatesFromCity(_locationController.text);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      final token =
          prefs.getString('token'); // Get the token from shared preferences
      final providerId = prefs.getString('serviceProviderId');

      final serviceData = {
        'service': _serviceController.text,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'service_category': selectedCategory,
        'pic': _image != null
            ? base64Encode(_image!.readAsBytesSync())
            : '', // Encode the image
        'price': _totalAmount,
        'availability':
            'Available', // Set the availability to "Available" by default
        'available_days': selectedWeekdays,
        'available_hours':
            '${startTime!.format(context)} - ${endTime!.format(context)}',
        'condition': isNew,
        "location_long": locationCordinates["longitude"] == 0.0
            ? 1.0
            : locationCordinates["longitude"],
        "location_lat": locationCordinates["latitude"] == 0.0
            ? 1.0
            : locationCordinates["latitude"],
      };
      final response =
          await http.post(Uri.parse('$baseURL/service/new/$providerId'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': '$token',
              },
              body: json.encode(serviceData)); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      if (status == 200) {
        LoadingDialog.hide(context); // Hide the loading dialog
        // QuickAlert.show(
        //   context: context,
        //   type: QuickAlertType.success,
        //   title: 'Success',
        //   text: 'Service details saved successfully',
        //   backgroundColor: Colors.black,
        //   titleColor: Colors.white,
        //   textColor: Colors.white,
        // );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SP_Dashboard()),
        );
      } else {
        LoadingDialog.hide(context); // Hide the loading dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: data['message'],
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      LoadingDialog.hide(context); // Hide the loading dialog
      print(e);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Oops...',
        text: 'Failed to save service details',
        backgroundColor: Colors.black,
        titleColor: Colors.white,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Your Service"),
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Use a form key to validate inputs
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _serviceController,
                  decoration: InputDecoration(
                    labelText: 'Your Service',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Your Service Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 280,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text("Enable Reference ID"),
                  value: false,
                  onChanged: (bool value) {},
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Ref ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Condition
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Condition'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: isNew,
                      onChanged: (value) {
                        setState(
                          () {
                            isNew = value!;
                          },
                        );
                      },
                    ),
                    const Text('New'),
                    Radio<bool>(
                      value: false,
                      groupValue: isNew,
                      onChanged: (value) {
                        setState(() {
                          isNew = value!;
                        });
                      },
                    ),
                    const Text('Used'),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Service  Category'),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 8.0, // Horizontal space between items
                    runSpacing:
                        4.0, // Vertical space between lines (if wrapping occurs)

                    children: [
                      ChoiceChip(
                        label: const Text('Plumber'),
                        selected: selectedCategory == 'Plumber',
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = 'Plumber';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Electrician'),
                        selected: selectedCategory == 'Electrician',
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = 'Electrician';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Carpentry'),
                        selected: selectedCategory == 'Carpentry',
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = 'Carpentry';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Painting'),
                        selected: selectedCategory == 'Painting',
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = 'Painting';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Gardening'),
                        selected: selectedCategory == 'Gardening',
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = 'Gardening';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Repairing'),
                        selected: selectedCategory == 'Repairing',
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = 'Repairing';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Building'),
                        selected: selectedCategory == 'Building',
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = 'Building';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Phone Repairing'),
                        selected: selectedCategory == 'Phone Repairing',
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = 'Phone Repairing';
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('beauty professional'),
                        selected: selectedCategory == 'beauty professional',
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = 'beauty professional';
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),
                Text("Service Image"),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[300],
                    child: _image == null
                        ? Icon(Icons.camera_alt)
                        : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),

                SizedBox(height: 16),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text("Enable Time Duration"),
                  value: enableTimeDuration,
                  onChanged: (bool value) {
                    setState(() {
                      enableTimeDuration = value;
                      if (!enableTimeDuration) {
                        // Clear the time duration if the switch is disabled
                        timeDurationController.clear();
                      }
                    });
                  },
                ),

                // Conditionally show and validate the "Time Duration" field
                if (enableTimeDuration) ...[
                  SizedBox(height: 8),
                  TextFormField(
                    controller: timeDurationController,
                    decoration: InputDecoration(
                      labelText: 'Time Duration (in hours)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a time duration';
                      }
                      return null;
                    },
                  ),
                ],

                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Only submit if the form is valid
                      if (enableTimeDuration) {
                        print(
                            'Time Duration: ${timeDurationController.text} hours');
                      }
                    }
                  },
                  child: Text("Submit"),
                ),

                // Input field for the price
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Price',
                    hintText: 'Enter price in numbers',
                  ),
                  onChanged: (value) {
                    _updateTotalAmount(); // Update total when price is entered
                  },
                ),

                SizedBox(height: 16),
                // Display the total amount
                Text(
                  "Total Price: Rs.${_totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Enter Discount'),
                          content: TextField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Discount Amount',
                              hintText: 'Enter discount in numbers',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close dialog
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                _applyDiscount(); // Apply the discount
                                Navigator.of(context).pop(); // Close dialog
                              },
                              child: Text('Apply'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("+ Add Discounts"),
                ),
                SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Working Dates"),
                ),
                Wrap(
                  spacing: 8.0,
                  children: weekdays.map((day) {
                    return FilterChip(
                      label: Text(day),
                      selected: selectedWeekdays.contains(day),
                      onSelected: (isSelected) {
                        setState(() {
                          isSelected
                              ? selectedWeekdays.add(day)
                              : selectedWeekdays.remove(day);
                        });
                      },
                    );
                  }).toList(),
                ),

                SizedBox(height: 16),
                Text("Working Hours"),

// Time Range
                ListTile(
                  title: Text(
                    startTime == null || endTime == null
                        ? 'Set available time range'
                        : 'Selected Time Range: ${startTime!.format(context)} - ${endTime!.format(context)}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    await _selectTime(context, true); // Select start time
                    await _selectTime(context, false); // Select end time
                  },
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      handleSaveService();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: (Colors.yellow[700]),
                        foregroundColor: Colors.black // Full width button
                        ),
                    child: Text('Add Service'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
