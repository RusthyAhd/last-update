import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Tool_Provider/TP_AddTool.dart';
import 'package:tap_on/widgets/Loading.dart';
import 'package:http/http.dart' as http;

class TP_ToolManager extends StatefulWidget {
  const TP_ToolManager({super.key});

  @override
  _TP_ToolManagerState createState() => _TP_ToolManagerState();
}

class _TP_ToolManagerState extends State<TP_ToolManager> {
  final List<Map<String, dynamic>> menuItems = [
    // {
    //   'id': 5878694,
    //   'name': 'Hammer',
    //   'quantity': 01,
    //   'price': 249.00,
    //   'available': true,
    //   'image': 'assets/hammmer.png'
    // },
    // {
    //   'id': 5878695,
    //   'name': 'Brush ',
    //   'quantity': 04,
    //   'price': 595.00,
    //   'available': false,
    //   'image': 'assets/rotti.png'
    // },
  ];

  // Controllers for the form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  bool available = true;

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
      final providerId = prefs.getString('toolProviderId');
      debugPrint(providerId);

      final response = await http
          .get(Uri.parse('$baseURL/tool/get/all/$providerId'), headers: {
        'Content-Type': 'application/json',
        'Authorization': '$token',
      }); // Send a POST request to the API
      final data = jsonDecode(response.body); // Decode the response
      final status = data['status']; // Get the status from the response

      debugPrint(data.toString());

      if (status == 200) {
        final tools = data['data'];
        setState(() {
          menuItems.clear();
          for (var tool in tools) {
            menuItems.add({
              'id': tool['tool_id'] ?? 0,
              'name': tool['service'] ?? 'Service Name',
              'price': tool['item_price'] ?? 0.0,
              'quantity': tool['qty'] ?? 0,
              'available': tool['availability'] == 'Available' ? true : false,
              'image': tool['pic'] ?? '',
            });
          }
        });
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

  void handleEditTool(Map<String, dynamic> tool, int index) async {
    try {
      LoadingDialog.show(context); // Show the loading dialog
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final baseURL = dotenv.env['BASE_URL']; // Get the base URL
      final token =
          prefs.getString('token'); // Get the token from shared preferences

      final requestBody = {
        'title': nameController.text == '' ? tool['name'] : nameController.text,
        'price': priceController.text == ''
            ? tool['price']
            : double.tryParse(priceController.text) ?? 0.0,
        'qty': quantityController.text == ''
            ? tool['quantity']
            : int.tryParse(quantityController.text) ?? 0,
        'availability': available ? 'Available' : 'Not Available',
        'pic': tool['image'],
      };

      final response =
          await http.put(Uri.parse('$baseURL/tool/update/${tool['id']}'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': '$token',
              },
              body: json.encode(requestBody)); // Send a POST request to the API

      final data = jsonDecode(response.body); // Decode the response

      final status = data['status']; // Get the status from the response

      if (status == 200) {
        // Successfully updated the service
        LoadingDialog.hide(context); // Hide the loading dialog
        menuItems[index]['name'] =
            nameController.text == '' ? tool['name'] : nameController.text;
        menuItems[index]['price'] = priceController.text == ''
            ? tool['price']
            : double.tryParse(priceController.text) ?? 0.0;
        menuItems[index]['available'] = available;
        menuItems[index]['quantity'] = quantityController.text == ''
            ? tool['quantity']
            : int.tryParse(quantityController.text) ?? 0;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: 'Service updated successfully',
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          textColor: Colors.white,
        );
      } else {
        // Handle error
        LoadingDialog.hide(context); // Hide the loading dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Oops...',
          text: 'Failed to update service',
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
        text: 'An error occurred. Please try again.',
        backgroundColor: Colors.black,
        titleColor: Colors.white,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Text('Menu Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TP_AddTool()),
                      );
                      // Add Item action
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.yellow),
                    child: Text('+ Item'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    var item = menuItems[index];

                    return Card(
                      elevation: 4,
                      child: ListTile(
                        leading: SizedBox(
                          width: screenWidth * 0.2,
                          height: screenHeight * 0.1,
                          child: item['image'] == ''
                              ? Icon(Icons.image)
                              : Image(
                                  image: MemoryImage(
                                  base64Decode(item['image']),
                                )),
                        ),
                        title: Text(item['name']),
                        subtitle: Text(
                            'Quantity: ${item['quantity']}\nLKR ${item['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                item['available']
                                    ? 'Available'
                                    : 'Not Available',
                                style: TextStyle(
                                    color: item['available']
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ),

                            SizedBox(width: 8),
                            // Edit Button
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Open the dialog to edit item
                                _editItemDialog(context, item, index);
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                _editItemDialog(context, item, index);
                              },
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Moved the _editItemDialog method inside the _MenuScreenState class
  void _editItemDialog(
      BuildContext context, Map<String, dynamic> item, int index) {
    // Pre-fill form fields with existing values
    nameController.text = item['name'];
    priceController.text = item['price'].toString();
    quantityController.text = item['quantity'].toString();
    available = item['available'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Item"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Price'),
                  ),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quantity'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Available:'),
                      Switch(
                        value: available,
                        onChanged: (bool value) {
                          setState(() {
                            available = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                // Update the item details
                handleEditTool(item, index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
