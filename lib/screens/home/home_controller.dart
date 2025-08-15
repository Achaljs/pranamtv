import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/ads/ads_helper.dart';
import 'package:streamit_laravel/screens/home/model/dashboard_res_model.dart';
import 'package:streamit_laravel/screens/watch_list/watch_list_controller.dart';
import 'package:streamit_laravel/services/FreeMoviesApiService.dart';
import 'package:streamit_laravel/services/popular_movies_api_service.dart';
import 'package:streamit_laravel/utils/FreeMoviesConverter.dart';
import 'package:streamit_laravel/utils/constants.dart';

// Add these imports to the top of your home_controller.dart file:

import '../../models/recent_movie_model.dart';
import '../../services/LatestTvShowsApiService.dart';
import '../../services/PopularMoviesApiService.dart';
import '../../services/featured_api_service.dart';
import '../../utils/LatestMoviesConverter.dart';
import '../../utils/LatestTvShowsConverter.dart';
import '../../utils/PopularMoviesConverter.dart';
import '../../utils/data_converter.dart';


import '../../services/latest_movie_service.dart';



import '../../configs.dart';
import '../../main.dart';
import '../../mock/mock_dashboard.dart';
import '../../network/auth_apis.dart';
import '../../network/core_api.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../video_players/model/video_model.dart';
import '../profile/profile_controller.dart';

class HomeController extends GetxController {
  bool forceSyncDashboardAPI;
  RxBool isLoading = true.obs;

  RxBool showCategoryShimmer = false.obs;
  RxBool isWatchListLoading = false.obs;
  RxBool isRefresh = false.obs;

  Rx<Future<DashboardDetailResponse>> getDashboardDetailFuture = Future(() => DashboardDetailResponse(data: DashboardModel())).obs;

  Rx<DashboardModel> dashboardDetail = DashboardModel().obs;
  Rx<PageController> sliderPageController = PageController(initialPage: 0).obs;

  final RxInt _currentPage = 0.obs;

  Rx<Timer> timer = Timer(const Duration(), () {}).obs;

  RxList<CategoryListModel> sectionList = RxList();

  //Ad Slider
  Rx<PageController> adPageController = PageController(initialPage: 0).obs;
  RxInt adCurrentPage = 0.obs;




  //BannerAd
  BannerAd? bannerAd;
  RxBool isAdShow = false.obs;

  HomeController({this.forceSyncDashboardAPI = false});

  @override
  void onInit() {
    print('HomeController onInit called');
    if (cachedDashboardDetailResponse != null) {
      print('Using cached dashboard response');
      dashboardDetail(cachedDashboardDetailResponse!.data);
      createCategorySections(cachedDashboardDetailResponse!.data, true);
    }
    super.onInit();

    init(forceSync: forceSyncDashboardAPI);
  }

  void clearCache() {
    cachedDashboardDetailResponse = null;
  }

  Future<void> init({bool forceSync = false, bool showLoader = false, bool forceConfigSync = false}) async {
    print('HomeController init called - forceSync: $forceSync, showLoader: $showLoader');

    getAppConfigurations(forceConfigSync);
    if (appConfigs.value.enableAds.getBoolInt()) bannerLoad();

    // For debugging with mock data, directly call getDashboardDetail
    print('Directly calling getDashboardDetail for debugging');
    getDashboardDetail(startTimer: true, showLoader: showLoader);

    // Original code with timing check (uncomment when real API is ready):
    /*
    checkApiCallIsWithinTimeSpan(
      forceSync: forceSync,
      callback: () {
        print('Calling getDashboardDetail from checkApiCallIsWithinTimeSpan');
        getDashboardDetail(startTimer: true, showLoader: showLoader);
      },
      sharePreferencesKey: SharedPreferenceConst.DASHBOARD_DETAIL_LAST_CALL_TIME,
    );
    */
  }

  Future<void> bannerLoad() async {
    bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          log('$BannerAd loaded.');
          isAdShow(true);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          log('$BannerAd failedToLoad: $error');
        },
        onAdOpened: (Ad ad) {
          log('$BannerAd onAdOpened.');
        },
        onAdClosed: (Ad ad) {
          log('$BannerAd onAdClosed.');
        },
      ),
    );
    await bannerAd?.load();
  }

  ///Get Dashboard List
  ///Get Dashboard List with Real Featured API
  // Updated getDashboardDetail method for home_controller.dart
  Future<void> getDashboardDetail({bool showLoader = false, bool startTimer = false}) async {
    print('getDashboardDetail called - showLoader: $showLoader, startTimer: $startTimer');

    isLoading(showLoader);
    isWatchListLoading(showLoader);

    try {
      // Step 1: Get slider data from real API
      List<SliderModel> sliderData = [];
      try {
        print('Fetching slider data from real API...');
        final featuredResponse = await FeaturedApiService.getFeaturedContent();
        sliderData = DataConverter.convertFeaturedToSlider(featuredResponse);
        print('Successfully fetched ${sliderData.length} slider items from API');
      } catch (e) {
        print('Failed to fetch slider from API, using mock data: $e');
        // Fallback to mock data for slider
        // final mockResponse = await getMockDashboardResponse();
        // sliderData = mockResponse.data.slider;
      }

      // Step 2: Get latest movies from real API with improved error handling
      List<VideoPlayerModel> latestMoviesData = [];
      try {
        print('Fetching latest movies data from real API...');

        // Use the API service with proper error handling
        final latestMoviesResponse = await LatestMoviesApiService.getLatestMovies();

        // Validate the response before conversion

          // Use the safe conversion method with fallback
          latestMoviesData = LatestMoviesConverter.convertToVideoPlayerModel(latestMoviesResponse);
          print('Successfully fetched ${latestMoviesData.length} latest movies from API');


      } catch (e, stackTrace) {
        print('Failed to fetch latest movies from API, using mock data: $e');
        print('Stack trace: $stackTrace');

        // Check if it's a stack overflow and log accordingly
        if (stackTrace.toString().contains('Stack Overflow') ||
            e.toString().contains('Stack Overflow')) {
          print('💥 STACK OVERFLOW DETECTED in latest movies conversion!');
          print(
              '🔍 This suggests a recursive call in LatestMoviesConverter or VideoPlayerModel');
        }
      }
        // // Fallback to mock data for latest movies
        // try {
        //   final mockResponse = await getMockDashboardResponse();
        //   latestMoviesData = mockResponse.data.latestList;
        //   print('Successfully loaded ${latestMoviesData.length} latest movies from mock data');
        // } catch (mockError) {
        //   print('Even mock data failed for latest movies: $mockError');
        //   latestMoviesData = []; // Use empty list as final fallback
        // }


      List<VideoPlayerModel> popularMoviesData = [];

        try {
          print('Fetching popular movies data from real API...');

          // Fetch from real API
          final popularMoviesResponse = await PopularMoviesApiService.getPopularMovies();

          // Convert and assign
          popularMoviesData = PopularMoviesConverter.convertToVideoPlayerModel(popularMoviesResponse);
          print('Successfully fetched ${popularMoviesData.length} popular movies from API');

        } catch (e, stackTrace) {
          print('Failed to fetch popular movies from API, using mock data: $e');
          print('Stack trace: $stackTrace');

          if (stackTrace.toString().contains('Stack Overflow') || e.toString().contains('Stack Overflow')) {
            print('💥 STACK OVERFLOW DETECTED in popular movies conversion!');
          }
        }

      List<VideoPlayerModel> freeMoviesData = [];

      try {
        print('Fetching popular movies data from real API...');

        // Fetch from real API
        final freeMoviesResponse = await FreeMoviesApiService.getFreeMovies();

        // Convert and assign
        freeMoviesData = FreeMoviesConverter.convertToVideoPlayerModel(freeMoviesResponse);
        print('Successfully fetched ${popularMoviesData.length} popular movies from API');

      } catch (e, stackTrace) {
        print('Failed to fetch popular movies from API, using mock data: $e');
        print('Stack trace: $stackTrace');

        if (stackTrace.toString().contains('Stack Overflow') || e.toString().contains('Stack Overflow')) {
          print('💥 STACK OVERFLOW DETECTED in popular movies conversion!');
        }
      }



      List<VideoPlayerModel> latestTvShowsData = [];
      try {
        print('Fetching latest TV shows data from API...');

        final response = await LatestTvShowsApiService.getLatestTvShows();

        latestTvShowsData = LatestTvShowsConverter.convertToVideoPlayerModel(response);

        print('Successfully fetched ${latestTvShowsData.length} latest TV shows');
      } catch (e, stackTrace) {
        print('Failed to fetch latest TV shows: $e');
        print('Stack trace: $stackTrace');

        if (stackTrace.toString().contains('Stack Overflow') || e.toString().contains('Stack Overflow')) {
          print('💥 STACK OVERFLOW DETECTED in LatestTvShowsConverter!');
        }
      }



      // Step 3: Get other sections from mock data (for now)
      print('Getting other sections from mock data...');
      final mockResponse = await getMockDashboardResponse();

      final combinedDashboard = DashboardModel(
      // Step 4: Create combined dashboard with real slider +
        isEnableBanner: true,
        isContinueWatch: mockResponse.data.isContinueWatch,
        slider: sliderData, // Use real API data
        continueWatch: mockResponse.data.continueWatch,
        latestList: latestMoviesData, // Use real API data or fallback
        popularMovieList: popularMoviesData,
        popularTvShowList:latestTvShowsData,
        popularVideoList: mockResponse.data.popularVideoList,
        trendingMovieList: mockResponse.data.trendingMovieList,
        freeMovieList: freeMoviesData,
        top10List: mockResponse.data.top10List,
        topChannelList: mockResponse.data.topChannelList,
        genreList: mockResponse.data.genreList,
        popularLanguageList: mockResponse.data.popularLanguageList,
        actorList: mockResponse.data.actorList,
        trendingInCountryMovieList: mockResponse.data.trendingInCountryMovieList,
        basedOnLastWatchMovieList: mockResponse.data.basedOnLastWatchMovieList,
        favGenreList: mockResponse.data.favGenreList,
        favActorList: mockResponse.data.favActorList,
        viewedMovieList: mockResponse.data.viewedMovieList,
        likeMovieList: mockResponse.data.likeMovieList,
        payPerView: mockResponse.data.payPerView,
      );

      // Step 5: Apply existing filters
      _applyDataFilters(combinedDashboard);

      // Step 6: Set dashboard data and create sections
      print('Setting dashboard data and creating sections');
      setValue(SharedPreferenceConst.DASHBOARD_DETAIL_LAST_CALL_TIME, DateTime.timestamp().millisecondsSinceEpoch);

      await createCategorySections(combinedDashboard, true);
      dashboardDetail(combinedDashboard);

      // Step 7: Cache the response
      final dashboardResponse = DashboardDetailResponse(
        status: true,
        message: "Data fetched successfully",
        data: combinedDashboard,
      );
      cachedDashboardDetailResponse = dashboardResponse;
      setValue(SharedPreferenceConst.CACHE_DASHBOARD, dashboardResponse.toJson());

      print('Dashboard data set successfully with ${sliderData.length} slider items and ${latestMoviesData.length} latest movies');
      isLoading(false);
      isWatchListLoading(false);

      if (startTimer && combinedDashboard.slider.isNotEmpty) {
        print('Starting auto slider');
        startAutoSlider();
      }

    } catch (e, stackTrace) {
      print('Error in getDashboardDetail: $e');
      print('Full stack trace: $stackTrace');

      // Check for stack overflow in the main method
      if (stackTrace.toString().contains('Stack Overflow')) {
        print('💥 STACK OVERFLOW DETECTED in getDashboardDetail main method!');
      }

      // Final fallback to mock data
      try {
        print('Final fallback to mock data');
        final mockResponse = await getMockDashboardResponse();
        await createCategorySections(mockResponse.data, true);
        dashboardDetail(mockResponse.data);
        print('Successfully loaded mock dashboard data');
      } catch (mockError) {
        print('Even mock data failed: $mockError');
      }

      isWatchListLoading(false);
      isLoading(false);
    }
  }

  // Helper method to apply data filters
  void _applyDataFilters(DashboardModel dashboard) {
    print('Applying data filters...');

    // Filter continueWatch list based on calculatePendingPercentage
    if (dashboard.continueWatch.isNotEmpty) {
      dashboard.continueWatch.removeWhere((continueWatchData) {
        try {
          return calculatePendingPercentage(
            continueWatchData.totalWatchedTime.isEmpty || continueWatchData.totalWatchedTime == "00:00:00" ? "00:00:01" : continueWatchData.totalWatchedTime,
            continueWatchData.watchedTime.isEmpty || continueWatchData.watchedTime == "00:00:00" ? "00:00:01" : continueWatchData.watchedTime,
          ).$1 == 1;
        } catch (e) {
          print('Error in calculatePendingPercentage: $e');
          return false;
        }
      });
    }

    // Filter out inactive items from slider
    if (dashboard.slider.isNotEmpty) {
      dashboard.slider.removeWhere((element) => element.data.status == 0);
      dashboard.slider.removeWhere((element) => element.data.id == -1);
    }

    print('Data filters applied successfully');
  }

  Future<void> getOtherDashboardDetails({bool showLoader = false}) async {
    showCategoryShimmer(showLoader);
    await CoreServiceApis.getDashboardDetailOtherData().then((value) async {
      await createCategorySections(value.data, false);
      showCategoryShimmer(false);
      DashboardModel res = dashboardDetail.value;
      dashboardDetail(value.data);
      dashboardDetail.value.slider = res.slider;
      dashboardDetail.value.continueWatch = res.continueWatch;
      dashboardDetail.value.top10List = res.top10List;
      //dashboardDetail.value.latestList = res.latestList;
      cachedDashboardDetailResponse = value;
      setValue(SharedPreferenceConst.CACHE_DASHBOARD, value.toJson());
    }).catchError((e) {
      showCategoryShimmer(false);
    });
  }

  Future<void> createCategorySections(DashboardModel dashboard, bool isFirstPage) async {
    print('createCategorySections called - isFirstPage: $isFirstPage');
    isLoading(true);

    if (isFirstPage) sectionList.clear();


      dashboard.basedOnLastWatchMovieList?.removeWhere((element) => element.type == VideoType.movie);
      dashboard.trendingInCountryMovieList?.removeWhere((element) => element.type == VideoType.movie);
      dashboard.trendingMovieList?.removeWhere((element) => element.type == VideoType.movie);
      dashboard.likeMovieList?.removeWhere((element) => element.type == VideoType.movie);
      dashboard.viewedMovieList?.removeWhere((element) => element.type == VideoType.movie);
      dashboard.payPerView?.removeWhere((element) => element.type == VideoType.movie);



      dashboard.basedOnLastWatchMovieList?.removeWhere((element) => element.type == VideoType.tvshow);
      dashboard.trendingInCountryMovieList?.removeWhere((element) => element.type == VideoType.tvshow);
      dashboard.trendingMovieList?.removeWhere((element) => element.type == VideoType.tvshow);
      dashboard.likeMovieList?.removeWhere((element) => element.type == VideoType.tvshow);
      dashboard.viewedMovieList?.removeWhere((element) => element.type == VideoType.tvshow);
      dashboard.payPerView?.removeWhere((element) => element.type == VideoType.tvshow || element.type == VideoType.episode);


      dashboard.basedOnLastWatchMovieList?.removeWhere((element) => element.type == VideoType.video);
      dashboard.trendingInCountryMovieList?.removeWhere((element) => element.type == VideoType.video);
      dashboard.trendingMovieList?.removeWhere((element) => element.type == VideoType.video);
      dashboard.likeMovieList?.removeWhere((element) => element.type == VideoType.video);
      dashboard.viewedMovieList?.removeWhere((element) => element.type == VideoType.video);
      dashboard.payPerView?.removeWhere((element) => element.type == VideoType.video);


    if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.top10).isNegative &&
        dashboard.top10List != null && dashboard.top10List!.isNotEmpty) {
      sectionList.add(
        CategoryListModel(
          name: locale.value.top10,
          sectionType: DashboardCategoryType.top10,
          data: dashboard.top10List!,
        ),
      );
    }

    if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.advertisement).isNegative) {
      sectionList.add(
        CategoryListModel(
          name: "",
          sectionType: DashboardCategoryType.advertisement,
          data: [],
        ),
      );
    }

    if (
        sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.latestMovies).isNegative &&
        dashboard.latestList != null && dashboard.latestList!.isNotEmpty) {
      sectionList.add(
        CategoryListModel(
          name: locale.value.latestMovies,
          sectionType: DashboardCategoryType.latestMovies,
          data: dashboard.latestList!,
        ),
      );
    }

    if (
        sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.channels).isNegative &&
        dashboard.topChannelList != null && dashboard.topChannelList!.isNotEmpty) {
      sectionList.add(
        CategoryListModel(
          name: locale.value.topChannels,
          sectionType: DashboardCategoryType.channels,
          data: dashboard.topChannelList!,
          showViewAll: dashboard.topChannelList!.isNotEmpty,
        ),
      );
    }

    if (
        sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.movie).isNegative &&
        dashboard.popularMovieList != null && dashboard.popularMovieList!.isNotEmpty &&
        sectionList.indexWhere((element) => element.name == locale.value.popularMovies).isNegative) {
      setValue(SharedPreferenceConst.POPULAR_MOVIE, jsonEncode(dashboard.popularMovieList));
      sectionList.add(
        CategoryListModel(
          name: locale.value.popularMovies,
          sectionType: DashboardCategoryType.movie,
          data: dashboard.popularMovieList!,
          showViewAll: dashboard.popularMovieList!.isNotEmpty,
        ),
      );
    }

    if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.payPerView).isNegative &&
        dashboard.payPerView != null && dashboard.payPerView!.isNotEmpty &&
        sectionList.indexWhere((element) => element.name == 'Pay Per View').isNegative) {
      sectionList.add(
        CategoryListModel(
          name: 'Pay Per View',
          sectionType: DashboardCategoryType.payPerView,
          data: dashboard.payPerView!,
          showViewAll: dashboard.payPerView!.isNotEmpty,
        ),
      );
    }

    if (

        dashboard.popularTvShowList != null && dashboard.popularTvShowList!.isNotEmpty) {
      sectionList.add(
        CategoryListModel(
          name: locale.value.popularTvShows,
          sectionType: DashboardCategoryType.tvShow,
          data: dashboard.popularTvShowList!,
          showViewAll: dashboard.popularTvShowList!.isNotEmpty,
        ),
      );
    }

    if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.video).isNegative &&
        dashboard.popularVideoList != null && dashboard.popularVideoList!.isNotEmpty) {
      sectionList.add(
        CategoryListModel(
          name: locale.value.popularVideos,
          sectionType: DashboardCategoryType.video,
          data: dashboard.popularVideoList!,
          showViewAll: dashboard.popularVideoList!.isNotEmpty,
        ),
      );
    }

    if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.free).isNegative &&
        dashboard.freeMovieList != null && dashboard.freeMovieList!.isNotEmpty &&
        sectionList.indexWhere((element) => element.name == locale.value.freeMovies).isNegative) {
      sectionList.add(
        CategoryListModel(
          name: locale.value.freeMovies,
          sectionType: DashboardCategoryType.movie,
          data: dashboard.freeMovieList!,
          showViewAll: dashboard.freeMovieList!.isNotEmpty,
        ),
      );
    }

    if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.genres).isNegative &&
        dashboard.genreList != null && dashboard.genreList!.isNotEmpty &&
        sectionList.indexWhere((element) => element.name == locale.value.genres).isNegative) {
      sectionList.add(
        CategoryListModel(
          name: locale.value.genres,
          sectionType: DashboardCategoryType.genres,
          data: dashboard.genreList!,
          showViewAll: dashboard.genreList!.isNotEmpty,
        ),
      );
    }

    if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.language).isNegative &&
        dashboard.popularLanguageList != null && dashboard.popularLanguageList!.isNotEmpty) {
      sectionList.add(CategoryListModel(
        name: locale.value.popularLanguages,
        sectionType: DashboardCategoryType.language,
        data: dashboard.popularLanguageList!,
        showViewAll: dashboard.popularLanguageList!.isNotEmpty,
      ));
    }

    if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.personality).isNegative &&
        dashboard.actorList != null && dashboard.actorList!.isNotEmpty &&
        sectionList.indexWhere((element) => element.name == locale.value.actors).isNegative) {
      sectionList.add(CategoryListModel(
        name: locale.value.actors,
        sectionType: DashboardCategoryType.personality,
        data: dashboard.actorList!,
        showViewAll: dashboard.actorList!.isNotEmpty,
      ));
    }

    if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.trending).isNegative &&
        dashboard.trendingMovieList != null && dashboard.trendingMovieList!.isNotEmpty) {
      sectionList.add(CategoryListModel(
        name: locale.value.trending,
        sectionType: DashboardCategoryType.trending,
        data: dashboard.trendingMovieList!,
        showViewAll: true,
      ));
    }

    if (isLoggedIn.value) {
      if (dashboard.trendingInCountryMovieList != null && dashboard.trendingInCountryMovieList!.isNotEmpty &&
          sectionList.indexWhere((element) => element.name == locale.value.trendingInYourCountry).isNegative) {
        sectionList.add(CategoryListModel(
          name: locale.value.trendingInYourCountry,
          sectionType: DashboardCategoryType.personalised,
          data: dashboard.trendingInCountryMovieList!,
          showViewAll: false,
        ));
      }

      if (dashboard.favGenreList != null && dashboard.favGenreList!.isNotEmpty &&
          sectionList.indexWhere((element) => element.name == locale.value.favoriteGenres).isNegative) {
        sectionList.add(CategoryListModel(
          name: locale.value.favoriteGenres,
          sectionType: DashboardCategoryType.genres,
          data: dashboard.favGenreList!,
          showViewAll: false,
        ));
      }

      if (dashboard.basedOnLastWatchMovieList != null && dashboard.basedOnLastWatchMovieList!.isNotEmpty &&
          sectionList.indexWhere((element) => element.name == locale.value.basedOnYourPreviousWatch).isNegative) {
        sectionList.add(
          CategoryListModel(
            name: locale.value.basedOnYourPreviousWatch,
            sectionType: DashboardCategoryType.personalised,
            data: dashboard.basedOnLastWatchMovieList!,
            showViewAll: false,
          ),
        );
      }

      if (sectionList.indexWhere((element) => element.sectionType == DashboardCategoryType.personality).isNegative &&
          dashboard.favActorList != null && dashboard.favActorList!.isNotEmpty &&
          sectionList.indexWhere((element) => element.name == locale.value.yourFavoritePersonalities).isNegative) {
        sectionList.add(CategoryListModel(
          name: locale.value.yourFavoritePersonalities,
          sectionType: DashboardCategoryType.personality,
          data: dashboard.favActorList!,
          showViewAll: false,
        ));
      }

      if (dashboard.viewedMovieList != null && dashboard.viewedMovieList!.isNotEmpty &&
          sectionList.indexWhere((element) => element.name == locale.value.mostViewed).isNegative) {
        sectionList.add(
          CategoryListModel(
            name: locale.value.mostViewed,
            sectionType: DashboardCategoryType.personalised,
            data: dashboard.viewedMovieList!,
            showViewAll: false,
          ),
        );
      }

      if (dashboard.likeMovieList != null && dashboard.likeMovieList!.isNotEmpty &&
          sectionList.indexWhere((element) => element.name == locale.value.mostLiked).isNegative) {
        sectionList.add(
          CategoryListModel(
            name: locale.value.mostLiked,
            sectionType: DashboardCategoryType.personalised,
            data: dashboard.likeMovieList!,
            showViewAll: false,
          ),
        );
      }
    }

    if (appConfigs.value.enableRateUs && sectionList.indexWhere((element) => element.sectionType != "rate-our-app").isNegative) {
      sectionList.add(
        CategoryListModel(
          name: "",
          sectionType: "rate-our-app",
          data: [],
        ),
      );
    }

    print('Sections created: ${sectionList.length}');
    isLoading(false);
    // Add more categories if needed in the future
  }

  Future<void> getAppConfigurations(bool forceSync) async {
    if (forceSync) AuthServiceApis.getAppConfigurations(forceSync: forceSync);
  }

  Future<void> saveWatchLists(int index, {bool addToWatchList = true}) async {
    if (isWatchListLoading.isTrue) return;
    isWatchListLoading(true);

    dashboardDetail.refresh();
    if (addToWatchList) {
      CoreServiceApis.saveWatchList(
        request: {
          "entertainment_id": dashboardDetail.value.slider[index].data.id,
          if (profileId.value != 0) "profile_id": profileId.value,
        },
      ).then((value) async {
        await getDashboardDetail();
        successSnackBar(locale.value.addedToWatchList);
        updateWatchList();
      }).catchError((e) {
        errorSnackBar(error: e);
      }).whenComplete(() {
        isWatchListLoading(false);
      });
    } else {
      CoreServiceApis.deleteFromWatchlist(idList: [dashboardDetail.value.slider[index].data.id]).then((value) async {
        await getDashboardDetail();
        successSnackBar(locale.value.removedFromWatchList);
        updateWatchList();
      }).catchError((e) {
        errorSnackBar(error: e);
      }).whenComplete(() {
        isWatchListLoading(false);
      });
    }
  }

  void updateWatchList() {
    Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());

    WatchListController controller = Get.isRegistered<WatchListController>() ? Get.find<WatchListController>() : Get.put(WatchListController());
    controller.getWatchList(showLoader: false);
  }

  Future<void> startAutoSlider() async {
    if (dashboardDetail.value.slider.length >= 2 && !isWatchListLoading.value) {
      timer.value = Timer.periodic(const Duration(milliseconds: DASHBOARD_AUTO_SLIDER_SECOND), (Timer timer) {
        if (_currentPage < dashboardDetail.value.slider.length - 1) {
          _currentPage.value++;
        } else {
          _currentPage.value = 0;
        }
        if (sliderPageController.value.hasClients) sliderPageController.value.animateToPage(_currentPage.value, duration: const Duration(milliseconds: 950), curve: Curves.easeOutQuart);
      });
      sliderPageController.value.addListener(() {
        _currentPage.value = sliderPageController.value.page!.toInt();
      });
    }
  }

  @override
  void onClose() {
    timer.value.cancel();
    bannerAd?.dispose();
    super.onClose();
  }
}