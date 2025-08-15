import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/FreeMoviesResponse.dart';

class FreeMoviesApiService {
  static Future<FreeMoviesResponse> getFreeMovies() async {
    final response = await http.get(Uri.parse('https://pranamtv.in/api/section/free-zone'));

    if (response.statusCode == 200) {
      return FreeMoviesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load free movies');
    }
  }
}
