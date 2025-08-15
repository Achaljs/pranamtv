import 'dart:convert';
import 'package:http/http.dart' as http;

import '../screens/home/model/dashboard_res_model.dart';
import '../video_players/model/video_model.dart';

Future<CategoryListModel> fetchLatestMoviesSection() async {
  try {
    final response = await http.get(Uri.parse('https://pranamtv.in/api/section/recent'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // Adjust this based on your actual API response structure
      final List items = jsonData['data'] ?? [];

      List<VideoPlayerModel> videos = items.map((e) => convertToVideoModel(e)).toList();

      return CategoryListModel(
        name: 'Latest Movies', // or jsonData['name'] if available
        showViewAll: true,
        data: videos,
      );
    } else {
      throw Exception("Failed to load latest movies: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching latest movies: $e");
    rethrow;
  }


}

VideoPlayerModel convertToVideoModel(dynamic item) {
  return VideoPlayerModel(
    id: item['id'],
    name: item['title'] ?? '',
    description: item['description'] ?? '',
    shortDesc: item['short_desc'] ?? '',
    type: item['type'] ?? 'movie',
    language: item['language'] ?? 'Unknown',
    imdbRating: double.tryParse(item['imdb_rating']?.toString() ?? '0') ?? 0.0,
    contentRating: item['content_rating'] ?? '',
    watchedTime: '00:00:00',
    totalWatchedTime: '00:00:00',
    duration: item['duration'] ?? '',
    releaseDate: item['release_date'] ?? '',
    releaseYear: int.tryParse(item['release_year']?.toString() ?? '2024') ?? 2024,
    isRestricted: false,
    status: 1,
    thumbnailImage: item['landscape_img'] ?? '',
    posterImage: item['portrait_img'] ?? '',
    videoUrlInput: '',
    videoUploadType: '',
    genres: [],
    payPerView: [],
    availableSubTitle: [],
    videoLinks: [],
  );
}

