// lib/utils/data_converter.dart

import '../models/featured_model.dart';
import '../screens/home/model/dashboard_res_model.dart';
import '../video_players/model/video_model.dart';

class DataConverter {
  static const String baseUrl = "https://pranamtv.in/";

  static List<SliderModel> convertFeaturedToSlider(FeaturedResponse featuredResponse) {
    print('Converting ${featuredResponse.data.featured.length} featured items to slider');

    return featuredResponse.data.featured.map((featuredItem) {
      // Create full image URLs
      final landscapeUrl = baseUrl + featuredResponse.data.landscapePath + featuredItem.image.landscape;
      final portraitUrl = baseUrl + featuredResponse.data.portraitPath + featuredItem.image.portrait;

      print('Converting item: ${featuredItem.title}');
      print('Landscape URL: $landscapeUrl');
      print('Portrait URL: $portraitUrl');

      // Convert FeaturedItem to VideoPlayerModel using your existing structure
      final videoModel = VideoPlayerModel(
        id: featuredItem.id,
        name: featuredItem.title,
        description: featuredItem.title,
        shortDesc: featuredItem.title,
        type: _getVideoType(featuredItem.itemType),
        language: "Hindi", // Default language
        imdbRating: double.tryParse(featuredItem.ratings) ?? 5.0,
        contentRating: "U", // Default rating
        watchedTime: "00:00:00",
        totalWatchedTime: "01:30:00", // Add this field
        duration: "01:30:00", // Default duration
        releaseDate: DateTime.now().toString().split(' ')[0],
        releaseYear: DateTime.now().year,
        isRestricted: false,
        status: 1, // Active
        thumbnailImage: landscapeUrl,
        posterImage: portraitUrl,
        videoUrlInput: "", // Will be fetched when needed
        videoUploadType: "file",
        genres: [], // Empty for now
        payPerView: [], // Empty for now
        availableSubTitle: [], // Empty for now
        videoLinks: [], // Empty for now
      );

      // Convert to SliderModel using your existing structure
      return SliderModel(
        id: featuredItem.id,
        title: featuredItem.title,
        fileUrl: landscapeUrl,
        bannerURL: portraitUrl,
        type: _getVideoType(featuredItem.itemType),
        data: videoModel,
      );
    }).toList();
  }

  static String _getVideoType(int itemType) {
    switch (itemType) {
      case 1:
        return "movie";
      case 2:
        return "tvshow";
      case 3:
        return "video";
      default:
        return "movie";
    }
  }
}