import 'dart:convert';
import 'package:http/http.dart' as http;
import 'recent_model.dart';

class RecentService {
  static Future<RecentResponse> fetchRecentMovies() async {
    final url = Uri.parse('https://pranamtv.in/api/section/recent');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return RecentResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recent movies');
    }
  }
}
