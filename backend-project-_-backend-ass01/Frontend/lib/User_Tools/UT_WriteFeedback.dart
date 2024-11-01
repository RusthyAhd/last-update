import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';




class UT_WriteFeedback extends StatefulWidget {
  const UT_WriteFeedback({super.key});

  @override
  _UT_WriteFeedbackState createState() => _UT_WriteFeedbackState();
}

class _UT_WriteFeedbackState extends State<UT_WriteFeedback> {
  final TextEditingController _reviewController = TextEditingController();
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Review'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  'https://via.placeholder.com/100', // Placeholder for product image
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bjorg chair White Plastic',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Armchair in polypropylene. Seat and legs in solid natural beech wood.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Upload photo or video
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cloud_upload, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Click here to upload'),
                        ],
                      )
                    : Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(height: 24),
            // Write review
            TextField(
              controller: _reviewController,
              maxLength: 400,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Would you like to write anything about this product?',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle submit action
                },
                child: Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
