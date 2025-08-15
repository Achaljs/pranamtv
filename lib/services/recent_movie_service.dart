import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recent_movie_model.dart';

class RecentMovieService {
  static Future<List<RecentMovie>> fetchRecentMovies() async {
    final response = await http.get(Uri.parse("https://pranamtv.in/api/section/recent"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final recentList = data['data']['recent'] as List;
      final portraitPath = data['data']['portrait_path'];
      final landscapePath = data['data']['landscape_path'];

      return recentList.map((e) => RecentMovie.fromJson(e, portraitPath, landscapePath)).toList();
    } else {
      throw Exception("Failed to load recent movies");
    }
  }
}
