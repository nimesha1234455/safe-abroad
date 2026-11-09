import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agency.dart';

class ApiService {
 static const String baseUrl = 'https://api.nimesha.slhosted.lk/api';

  // Search agencies by name or license number
  static Future<List<Agency>> searchAgencies(String query) async {
    final uri = Uri.parse('$baseUrl/agencies')
        .replace(queryParameters: {'q': query});

    // Call the API (stop waiting after 15 seconds)
    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    }).timeout(const Duration(seconds: 15));

    // Check if the server replied OK
    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    // Laravel pagination puts the list inside "data"
    final body = jsonDecode(response.body);
    final List items = body['data'];

    // Convert each JSON item to an Agency object
    return items.map((e) => Agency.fromJson(e)).toList();
  }
}