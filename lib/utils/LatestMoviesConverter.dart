// utils/latest_movies_converter.dart
 // ✅ This is correct
import '../models/latest_movies_model.dart';
import '../video_players/model/video_model.dart';

class LatestMoviesConverter {

  static const String baseUrl = "https://pranamtv.in/";

  static List<VideoPlayerModel> convertToVideoPlayerModel(
    LatestMoviesResponse response,
  ) {
    print('Converting ${response.data.recent.length} recent items to VideoPlayerModel');

    return response.data.recent.map((item) {
      final portraitUrl = item.image.portrait.isNotEmpty
          ? '${baseUrl}${response.data.portraitPath}${item.image.portrait}'
          : '';
      final landscapeUrl = item.image.landscape.isNotEmpty
          ? '${baseUrl}${response.data.landscapePath}${item.image.landscape}'
          : '';

      return VideoPlayerModel(
        id: item.id,
        name: item.title, // VideoPlayerModel uses 'name' not 'title'
        description: '', // API doesn't provide description
        thumbnailImage: portraitUrl,
        posterImage: landscapeUrl,
        type: _mapItemTypeToString(item.itemType),
        status: 1, // Assuming active status
        access: 'free', // You can modify this based on your business logic
        movieAccess: 'free', // You can modify this based on your business logic
        isWatchList: false, // This will be updated elsewhere
        imdbRating: double.tryParse(item.ratings) ?? 0.0,
        releaseDate: '', // API doesn't provide release date
        duration: '', // API doesn't provide duration
        language: '', // API doesn't provide language
        contentRating: '', // API doesn't provide content rating
        trailerUrl: '', // API doesn't provide trailer
        entertainmentId: item.id, // Use the same ID
        genres: [], // API doesn't provide genres
        videoLinks: [], // API doesn't provide video links
        downloadQuality: [], // API doesn't provide download quality
        payPerView: [], // API doesn't provide pay per view
        availableSubTitle: [], // API doesn't provide subtitles
      );
    }).toList();
  }

  static String _mapItemTypeToString(int itemType) {
    switch (itemType) {
      case 1:
        return 'movie';
      case 2:
        return 'tv_show';
      case 3:
        return 'video';
      case 4:
        return 'episode';
      default:
        return 'movie';
    }
  }

  static String getFullImageUrl(String baseUrl, String imagePath) {
    if (imagePath.isEmpty) return '';
    return '$baseUrl$imagePath';
  }
}