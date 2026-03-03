import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class EmergencyService {
  static final String _baseUrl = kIsWeb 
      ? 'http://localhost:5000/api' 
      : (defaultTargetPlatform == TargetPlatform.android 
          ? 'http://10.0.2.2:5000/api' 
          : 'http://localhost:5000/api');

  static Future<Map<String, dynamic>> fetchHospitals(String city, String lang) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/emergency/hospitals?city=$city&lang=$lang'),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Search failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
