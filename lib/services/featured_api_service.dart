// lib/services/featured_api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/featured_model.dart';

class FeaturedApiService {
  static const String baseUrl = 'https://pranamtv.in/api';

  static Future<FeaturedResponse> getFeaturedContent() async {
    try {
      print('Calling Featured API: $baseUrl/section/featured');

      final response = await http.get(
        Uri.parse('$baseUrl/section/featured'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('Featured API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Featured API Response: ${jsonData.toString()}');
        return FeaturedResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load featured content: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getFeaturedContent: $e');
      throw Exception('Network error: $e');
    }
  }
}