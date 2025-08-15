import 'package:streamit_laravel/video_players/model/video_model.dart';

class DataConverter {
  static List<VideoPlayerModel> convertRecentMovies({
    required List<dynamic> recentList,
    required String portraitPath,
    required String landscapePath,
  }) {
    return recentList.map((item) {
      return VideoPlayerModel(
        id: item['id'],
        name: item['title'],
        description: '',
        shortDesc: '',
        type: 'movie',
        language: '',
        imdbRating: double.tryParse(item['ratings'] ?? '0') ?? 0,
        contentRating: '',
        watchedTime: '',
        totalWatchedTime: '',
        duration: '',
        releaseDate: '',
        releaseYear: DateTime.now().year,
        isRestricted: false,
        status: 1,
        thumbnailImage: 'https://pranamtv.in/${landscapePath}${item['image']['landscape']}',
        posterImage: 'https://pranamtv.in/${portraitPath}${item['image']['portrait']}',
        videoUrlInput: '', // You can update if API returns this
        videoUploadType: '',
        genres: [],
        payPerView: [],
        availableSubTitle: [],
        videoLinks: [],
      );
    }).toList();
  }
}
