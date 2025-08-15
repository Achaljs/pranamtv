import '../models/FreeMoviesResponse.dart';
import '../video_players/model/video_model.dart';

class FreeMoviesConverter {
  static const String baseUrl = "https://pranamtv.in/";

  static List<VideoPlayerModel> convertToVideoPlayerModel(
      FreeMoviesResponse response,
      ) {
    print('Converting ${response.data.freeZone.data.length} free items to VideoPlayerModel');

    return response.data.freeZone.data.map((item) {
      final portraitUrl = item.image.portrait.isNotEmpty
          ? '${baseUrl}${response.data.portraitPath}${item.image.portrait}'
          : '';
      final landscapeUrl = item.image.landscape.isNotEmpty
          ? '${baseUrl}${response.data.landscapePath}${item.image.landscape}'
          : '';

      return VideoPlayerModel(
        id: item.id,
        name: item.title, // VideoPlayerModel uses 'name'
        description: '', // Not provided
        thumbnailImage: portraitUrl,
        posterImage: landscapeUrl,
        type: 'movie', // Default type since not provided
        status: 1, // Assuming always active
        access: 'free', // Free section
        movieAccess: 'free',
        isWatchList: false, // Will be updated later
        imdbRating: double.tryParse(item.ratings) ?? 0.0,
        releaseDate: '', // Not provided
        duration: '', // Not provided
        language: '', // Not provided
        contentRating: '', // Not provided
        trailerUrl: '', // Not provided
        entertainmentId: item.id,
        genres: [],
        videoLinks: [],
        downloadQuality: [],
        payPerView: [],
        availableSubTitle: [],
      );
    }).toList();
  }
}
