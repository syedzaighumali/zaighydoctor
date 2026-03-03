import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ConsultationService {
  static final String _baseUrl = kIsWeb 
      ? 'http://localhost:5000/api' 
      : (defaultTargetPlatform == TargetPlatform.android 
          ? 'http://10.0.2.2:5000/api' 
          : 'http://localhost:5000/api');

  static Future<Map<String, dynamic>> createConsultation(List<String> symptoms) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.post(
        Uri.parse('$_baseUrl/consultations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'symptoms': symptoms}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Consultation failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return {'success': false, 'message': 'Not authenticated'};

      final response = await http.get(
        Uri.parse('$_baseUrl/consultations/history'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Failed to fetch history'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static String getPdfUrl(String consultationId, String lang) {
    return '$_baseUrl/consultations/$consultationId/pdf?lang=$lang';
  }

  static Future<Map<String, dynamic>> getMedicinesByCategory(String category, String lang) async {
    try {
      final encodedCategory = Uri.encodeComponent(category);
      final response = await http.get(
        Uri.parse('$_baseUrl/consultations/category/$encodedCategory?lang=$lang'),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Fetch failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
