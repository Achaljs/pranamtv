
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/latest_movies_model.dart';
import '../main.dart';
import '../utils/app_common.dart'; // For appConfigs

class popularMoviesApiService {
  static Future<LatestMoviesResponse> getpopularMovies() async {
    try {
      //print('Fetching latest movies from: ${appConfigs.value.baseURL}/api/section/recent');

      final response = await http.get(
        Uri.parse('https://pranamtv.in/api/section/featured'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer ${your_token}',
        },
      );

      print('Latest Movies API Response Status: ${response.statusCode}');
      print('Latest Movies API Response Body: ${response.body}');
      print('Latest Movies API Response Body Length: ${response.body.length}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Latest Movies API Response Body: $jsonData');
        if (jsonData['status'] == 'success') {
          return LatestMoviesResponse.fromJson(jsonData);
        } else {
          throw Exception('API returned error status: ${jsonData['status']}');
        }
      } else {
        throw Exception('Failed to load latest movies: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error in getLatestMovies: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch latest movies: $e');
    }
  }
}