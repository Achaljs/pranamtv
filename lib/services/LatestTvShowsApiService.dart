// services/api/latest_tv_shows_api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/LatestTvShowsResponse.dart';

class LatestTvShowsApiService {
  static Future<LatestTvResponse> getLatestTvShows() async {
    final uri = Uri.parse('https://pranamtv.in/api/section/latest');
    final response = await http.get(uri);


    if (response.statusCode == 200) {
      return LatestTvResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch latest TV shows');
    }


  }
}
