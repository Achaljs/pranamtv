import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/PopularMoviesResponse.dart';


class PopularMoviesApiService {
  static Future<PopularMoviesResponse> getPopularMovies() async {
    try {
      final response = await http.get(
        Uri.parse('https://pranamtv.in/api/section/featured'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          return PopularMoviesResponse.fromJson(jsonData);
        } else {
          throw Exception('API returned error: ${jsonData['status']}');
        }
      } else {
        throw Exception('Failed to load popular movies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPopularMovies: $e');
      rethrow;
    }
  }
}
