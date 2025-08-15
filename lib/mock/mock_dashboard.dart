import 'package:streamit_laravel/screens/home/model/dashboard_res_model.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';

Future<DashboardDetailResponse> getMockDashboardResponse() async {
  await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

  final mockVideo = VideoPlayerModel(
    id: 1,
    name: "Mock Movie",
    description: "A mock movie description for UI development.",
    shortDesc: "Short description",
    type: "movie",
    language: "English",
    imdbRating: 7.5,
    contentRating: "PG-13",
    watchedTime: "00:00:30",
    totalWatchedTime: "01:30:00", // Add this field
    duration: "01:30:00",
    releaseDate: "2024-01-01",
    releaseYear: 2024,
    isRestricted: false,
    status: 1, // Add this field - make sure it's not 0
    thumbnailImage: "https://assets.visme.co/templates/banners/thumbnails/i_Green-Poster-Board_full.jpg",
    posterImage: "https://assets.visme.co/templates/banners/thumbnails/i_Green-Poster-Board_full.jpg",
    videoUrlInput: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
    videoUploadType: "file",
    genres: [],
    payPerView: [],
    availableSubTitle: [],
    videoLinks: [],
  );

  final mockSlider = SliderModel(
    id: 101,
    title: "Mock Banner",
    fileUrl: "https://via.placeholder.com/800x300.png?text=Banner",
    bannerURL: "https://via.placeholder.com/800x300.png?text=Banner+URL",
    type: "movie",
    data: mockVideo,
  );

  final dashboardModel = DashboardModel(
    isEnableBanner: true, // Change to true
    isContinueWatch: true, // Change to true
    slider: [mockSlider],
    continueWatch: [mockVideo],
    latestList: [mockVideo],
    popularMovieList: [mockVideo],
    popularTvShowList: [], // Add empty lists for other sections
    popularVideoList: [],
    trendingMovieList: [mockVideo],
    freeMovieList: [mockVideo],
    top10List: [mockVideo],
    topChannelList: [],
    genreList: [],
    popularLanguageList: [],
    actorList: [],
    trendingInCountryMovieList: [],
    basedOnLastWatchMovieList: [],
    favGenreList: [],
    favActorList: [],
    viewedMovieList: [],
    likeMovieList: [],
    payPerView: [],
  );

  return DashboardDetailResponse(
    status: true,
    message: "Mock data fetched successfully",
    data: dashboardModel,
  );
}