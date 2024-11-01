import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String, double>> getCoordinatesFromCity(String city) async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search?city=$city&format=json'),
    );
    final data = jsonDecode(response.body);
    if (data.isNotEmpty) {
      final lat = double.parse(data[0]['lat']);
      final lon = double.parse(data[0]['lon']);
      return {'latitude': lat, 'longitude': lon};
    }
    throw Exception('No coordinates found for the specified city');
  } catch (error) {
    print('**Error fetching coordinates: $error');
    //throw error;
    return {'latitude': 0.0, 'longitude': 0.0};
  }
}

Future<String> getCityFromCoordinates(double latitude, double longitude) async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['address'] != null && data['address']['city'] != null) {
        return data['address']['city'];
      } else if (data['address']['town'] != null) {
        return data['address']['town'];
      } else if (data['address']['village'] != null) {
        return data['address']['village'];
      }
      throw Exception('City not found for the specified coordinates');
    } else {
      throw Exception('Failed to load city information');
    }
  } catch (error) {
    print('Error fetching city: $error');
    //throw error;
    return '';
  }
}
