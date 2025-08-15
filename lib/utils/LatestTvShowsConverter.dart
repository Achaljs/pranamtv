// utils/latest_tv_shows_converter.dart

import '../models/LatestTvShowsResponse.dart';
import '../video_players/model/video_model.dart';

class LatestTvShowsConverter {
  static const String baseUrl = "https://pranamtv.in/";

  static List<VideoPlayerModel> convertToVideoPlayerModel(
      LatestTvResponse response,
      ) {
    print('Converting ${response.data.latest.length} latest TV items to VideoPlayerModel');

    return response.data.latest.map((item) {
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
        type: 'tv_show', // Assuming it's TV Show
        status: 1, // Assuming active
        access: 'free', // Marked as free
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
}
