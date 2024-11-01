import 'dart:convert';
import 'package:http/http.dart' as http;

class DirectionsService {
  final String apiKey;

  DirectionsService(this.apiKey);

  Future<List<dynamic>?> getDirections(
      String origin, String destination) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin&destination=$destination&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['routes']; // You can customize this as needed
    } else {
      throw Exception('Failed to load directions');
    }
  }
}
