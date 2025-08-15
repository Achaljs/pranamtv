import '../models/PopularMoviesResponse.dart';
import '../video_players/model/video_model.dart';

class PopularMoviesConverter {
  static const String baseUrl = "https://pranamtv.in/";

  static List<VideoPlayerModel> convertToVideoPlayerModel(PopularMoviesResponse response) {
    return response.data.featured.map((item) {
      final portraitUrl = item.image.portrait.isNotEmpty
          ? '${baseUrl}${response.data.portraitPath}${item.image.portrait}'
          : '';
      final landscapeUrl = item.image.landscape.isNotEmpty
          ? '${baseUrl}${response.data.landscapePath}${item.image.landscape}'
          : '';

      return VideoPlayerModel(
        id: item.id,
        name: item.title,
        description: '',
        thumbnailImage: portraitUrl,
        posterImage: landscapeUrl,
        type: _mapItemTypeToString(item.itemType),
        status: 1,
        access: 'free',
        movieAccess: 'free',
        isWatchList: false,
        imdbRating: double.tryParse(item.ratings) ?? 0.0,
        releaseDate: '',
        duration: '',
        language: '',
        contentRating: '',
        trailerUrl: '',
        entertainmentId: item.id,
        genres: [],
        videoLinks: [],
        downloadQuality: [],
        payPerView: [],
        availableSubTitle: [],
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
}
