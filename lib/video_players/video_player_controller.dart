import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_laravel/screens/subscription/model/subscription_plan_model.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:subtitle/subtitle.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:y_player/y_player.dart';

import '../configs.dart';
import '../network/core_api.dart';
import '../screens/home/home_controller.dart';
import '../screens/live_tv/live_tv_details/model/live_tv_details_response.dart';
import '../screens/profile/profile_controller.dart';
import '../utils/app_common.dart';
import '../utils/constants.dart';
import 'model/video_model.dart';

class VideoPlayersController extends GetxController {
  Rx<VideoPlayerModel> videoModel = VideoPlayerModel().obs;
  final LiveShowModel liveShowModel;

  Rx<PodPlayerController> podPlayerController = PodPlayerController(playVideoFrom: PlayVideoFrom.youtube("")).obs;
  Rx<YPlayerController> youtubePlayerController = YPlayerController().obs;

  RxBool isAutoPlay = true.obs;
  RxBool isTrailer = true.obs;
  RxBool isRented = true.obs;
  RxBool isBuffering = false.obs;
  RxBool isSubtitleBuffering = false.obs;
  RxBool canChangeVideo = true.obs;
  RxBool playNextVideo = false.obs;
  RxBool isVideoCompleted = false.obs;
  RxBool isVideoPlaying = false.obs;

  RxBool isPipEnable = false.obs;
  RxString currentQuality = QualityConstants.defaultQuality.toLowerCase().obs;
  RxString errorMessage = ''.obs;
  RxList<int> availableQualities = <int>[].obs;
  RxList<VideoLinks> videoQualities = <VideoLinks>[].obs;

  bool hasNextVideo;

  RxString videoUrlInput = "".obs;
  RxString videoUploadType = "".obs;

  RxInt selectedSettingTab = 0.obs;

  RxBool isVideoControlsVisible = false.obs;

  // Video Settings Dialog State

  RxString currentSubtitle = ''.obs;
  RxList<Subtitle> availableSubtitleList = <Subtitle>[].obs;

  RxList<SubtitleModel> subtitleList = <SubtitleModel>[].obs;
  Rx<SubtitleModel> selectedSubtitleModel = SubtitleModel().obs;

  Rx<WebViewController> webViewController = WebViewController().obs;

  VideoPlayersController({
    required this.videoModel,
    required this.liveShowModel,
    this.hasNextVideo = false,
    required this.isTrailer,
  });

  @override
  void onInit() {
    super.onInit();
    initializePlayer(videoModel.value.videoUrlInput, videoModel.value.videoUrlInput);
    WakelockPlus.enable();
    onChangePodVideo();
    onUpdateSubtitle();
    onUpdateQualities();
  }

  Future<void> initializePlayer(String videURL, String videoType) async {
    log("Video Model in Controller ==> ${videoModel.value.toJson()}");
    log("Watched Duration ==> ${videoModel.value.watchedTime}");
    log('Live Show data =>> ${liveShowModel.toJson()}');

    if ((videoModel.value.type == VideoType.video || videoModel.value.type == VideoType.liveTv) ||
        isAlreadyStartedWatching(videoModel.value.watchedTime)) {
      isTrailer(false);
    }

    (String, String) videoLinkType = getVideoLinkAndType();
    log('Platform: ${videoLinkType.$1}');
    log("URL: ${videoLinkType.$2}");
    videoUploadType(videoLinkType.$1);
    videoUrlInput(videoLinkType.$2);

    if (videoLinkType.$1.toLowerCase() == PlayerTypes.youtube) {
    } else if (videoLinkType.$1.toLowerCase() == PlayerTypes.embedded.toLowerCase() || videoLinkType.$1.toLowerCase() == PlayerTypes.vimeo) {
      String url = videoLinkType.$2;
      if (videoLinkType.$1.toLowerCase() == PlayerTypes.vimeo) {
        url = "https://player.vimeo.com/video/${url.split("/").last}";
      } else if (videoLinkType.$1.toLowerCase() == PlayerTypes.embedded.toLowerCase()) {
        _initializeWebViewPlayer(movieEmbedCode(videoLinkType.$2));
      }
    } else if (videoLinkType.$1.toLowerCase() == PlayerTypes.url || videoLinkType.$1.toLowerCase() == PlayerTypes.hls || videoLinkType.$1.toLowerCase() == PlayerTypes.local) {
      _initializePodPlayer(videoLinkType.$2);
    }

    _setVideoQualities();
  }

  void _initializeWebViewPlayer(String url) {
    final embedHtml = movieEmbedCode(url);

    webViewController.value = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            isBuffering(false);
          },
          onWebResourceError: (WebResourceError error) {
            isBuffering(false);
            handleError(error.description);
          },
        ),
      )
      ..loadHtmlString(embedHtml, baseUrl: DOMAIN_URL);
  }

  String movieEmbedCode(String url) => '''<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      html, body {
        margin: 0;
        padding: 0;
        height: 100%;
        background-color: #000;
      }
      iframe {
        border: none;
        width: 100%;
        height: 100%;
      }
    </style>
  </head>
  <body>
   $url
  </body>
</html>''';

  void initializeYoutubePlayer(YPlayerController youtubeController) async {
    youtubePlayerController(youtubeController);
    isBuffering(false);
  }

  void _initializePodPlayer(String url) async {
    try {
      isBuffering(true);
      final controller = PodPlayerController(
        podPlayerConfig: PodPlayerConfig(
          autoPlay: isAutoPlay.value,
          isLooping: false,
          wakelockEnabled: false,
          videoQualityPriority: availableQualities,
        ),
        playVideoFrom: getVideoPlatform(type: videoUploadType.value, videoURL: url),
      );

      await controller.initialise().then((_) {
        isBuffering(false);
        if (videoModel.value.watchedTime.isNotEmpty) {
          try {
            final seekPosition = _parseWatchedTime(videoModel.value.watchedTime);
            controller.videoSeekForward(seekPosition);
          } catch (e) {
            log("Error parsing continueWatchDuration: ${e.toString()}");
          }
        }
      }).catchError((error, stackTrace) {
        isBuffering(false);
        log("Error during initialization: ${error.toString()}");
        log("Stack trace: ${stackTrace.toString()}");
      });

      podPlayerController(controller);
      listenVideoEvent();
    } catch (e) {
      isBuffering(false);
      log("Exception during initialization: ${e.toString()}");
    }
  }

  bool isValidSubtitleFormat(String url) {
    return url.endsWith('.srt') || url.endsWith('.vtt');
  }

  Future<SubtitleController> initializeSubtitleInIsolate(String data, SubtitleType type) async {
    return await Isolate.run(() async {
      final provider = StringSubtitle(data: data, type: type);
      final controller = SubtitleController(provider: provider);
      await controller.initial();
      return controller;
    });
  }

  Future<void> loadSubtitles(SubtitleModel subtitle) async {
    try {
      pause();
      isSubtitleBuffering(true);
      final rawUrl = subtitle.subtitleFileURL;
      final encodedUrl = Uri.encodeFull(rawUrl);

      if (rawUrl.validateURL() && isValidSubtitleFormat(rawUrl)) {
        final response = await http.get(Uri.parse(encodedUrl));

        if (response.statusCode == 200) {
          String content;

          try {
            content = utf8.decode(response.bodyBytes);
          } catch (e) {
            final filtered = response.bodyBytes.where((b) => b != 0x00).toList();

            try {
              content = utf8.decode(filtered);
            } catch (e2) {
              content = latin1.decode(filtered);
            }
          }

          // Run subtitle parsing in a background isolate
          final controller = await compute(
            (Map<String, dynamic> params) async {
              final provider = StringSubtitle(
                data: params['content'] as String,
                type: params['type'] as SubtitleType,
              );
              final controller = SubtitleController(provider: provider);
              await controller.initial();
              return controller;
            },
            {
              'content': content,
              'type': getSubtitleFormat(rawUrl),
            },
          );

          availableSubtitleList.clear();
          availableSubtitleList(controller.subtitles);
          selectedSubtitleModel(subtitle);

          if (youtubePlayerController.value.isInitialized) {
            await updateCurrentSubtitle(youtubePlayerController.value.position + Duration(seconds: 1));
            youtubePlayerController.value.play();
          } else if (podPlayerController.value.isInitialised) {
            await updateCurrentSubtitle(podPlayerController.value.currentVideoPosition + Duration(seconds: 1));
            podPlayerController.value.play();
          }
        } else {
          throw Exception('Subtitle file not found: HTTP ${response.statusCode}');
        }
      } else {
        throw Exception('Invalid subtitle URL or unsupported format');
      }
    } catch (e) {
      availableSubtitleList.clear();
      selectedSubtitleModel(SubtitleModel());
      currentSubtitle('');
      if (youtubePlayerController.value.isInitialized) {
        youtubePlayerController.value.play();
      } else if (podPlayerController.value.isInitialised) {
        podPlayerController.value.play();
      }
    } finally {
      isSubtitleBuffering(false);
    }
  }

  Future<void> updateCurrentSubtitle(Duration position) async {
    if (availableSubtitleList.isNotEmpty) {
      final subtitle = availableSubtitleList.firstWhereOrNull((s) => s.start <= position && s.end >= position);
      if (subtitle != null && subtitle.data != currentSubtitle.value) {
        currentSubtitle(subtitle.data);
      } else if (subtitle == null && currentSubtitle.value.isNotEmpty) {
        currentSubtitle('');
      }
    }
  }

  SubtitleType getSubtitleFormat(String url) {
    if (url.endsWith('.srt')) return SubtitleType.srt;
    if (url.endsWith('.vtt')) return SubtitleType.vtt;
    return SubtitleType.custom;
  }

  Future<void> pause() async {
    if (podPlayerController.value.isInitialised) {
      podPlayerController.value.pause();
    } else if (youtubePlayerController.value.status == YPlayerStatus.playing) {
      youtubePlayerController.value.pause();
    }
  }

  Duration _parseWatchedTime(String watchedTime) {
    final parts = watchedTime.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  void _setVideoQualities() {
    if (videoModel.value.videoLinks.isNotEmpty) {
      availableQualities(videoModel.value.videoLinks.map((link) => link.quality.replaceAll(RegExp(r'[pPkK]'), '').toInt()).toList());
      videoQualities(videoModel.value.videoLinks);
    }
  }

  (String, String) getVideoLinkAndType() {
    if (isTrailer.isTrue) {
      return (videoModel.value.trailerUrlType, videoModel.value.trailerUrl);
    } else if (videoModel.value.type == VideoType.liveTv) {
      if (liveShowModel.streamType == PlayerTypes.embedded) {
        return (liveShowModel.streamType, liveShowModel.embedUrl);
      }
      return (liveShowModel.streamType, liveShowModel.serverUrl);
    } else if (videoModel.value.videoUploadType.toLowerCase() == PlayerTypes.embedded.toLowerCase()) {
      return (videoModel.value.videoUploadType, videoModel.value.embedded);
    } else {
      return (videoModel.value.videoUploadType.trim().isEmpty && videoModel.value.videoUrlInput.trim().isEmpty
          ? (videoUploadType.value, videoUrlInput.value)
          : (videoModel.value.videoUploadType, videoModel.value.videoUrlInput));
    }
  }

  void checkIfVideoEnded() {
    if (podPlayerController.value.videoPlayerValue != null) {
      final position = podPlayerController.value.videoPlayerValue!.position;
      final duration = podPlayerController.value.videoPlayerValue!.duration;
      if (podPlayerController.value.isInitialised) {
        final subtitle = availableSubtitleList.firstWhereOrNull((s) => s.start <= position && s.end >= position);
        if (subtitle != null && subtitle.data != currentSubtitle.value) {
          currentSubtitle(subtitle.data);
        } else if (subtitle == null && currentSubtitle.isNotEmpty) {
          currentSubtitle('');
        }
      }

      final remaining = duration - position;
      final threshold = duration.inSeconds * 0.20;
      playNextVideo(remaining.inSeconds <= threshold);

      if (podPlayerController.value.videoPlayerValue?.isCompleted ?? false) {
        storeViewCompleted();
        podPlayerController.value.pause();
      }
    }
  }

  Future<void> storeViewCompleted() async {
    Map<String, dynamic> request = {
      "entertainment_id": videoModel.value.id,
      "user_id": loginUserData.value.id,
      "entertainment_type": getVideoType(type: videoModel.value.type),
      if (profileId.value != 0) "profile_id": profileId.value,
    };

    await CoreServiceApis.saveViewCompleted(request: request);
  }

  void listenVideoEvent() {
    if (youtubePlayerController.value.isInitialized) {
      isVideoPlaying(youtubePlayerController.value.status == YPlayerStatus.playing);
    } else {
      if (podPlayerController.value.isInitialised) {
        isVideoPlaying(podPlayerController.value.videoPlayerValue?.isPlaying ?? false);
      }
      podPlayerController.value.addListener(() {
        isBuffering(podPlayerController.value.isVideoBuffering);
        checkIfVideoEnded();
      });
    }
  }

  void handleError(String? errorDescription) {
    log("Video Player Error: $errorDescription");
    errorMessage.value = errorDescription ?? 'An unknown error occurred';
  }

  void changeVideo({required String quality, required bool isQuality, required String type, VideoPlayerModel? newVideoData}) async {
    final currentPlaybackPosition = podPlayerController.value.videoPlayerValue?.position ?? Duration.zero;
    currentQuality.value = quality;

    try {
      VideoLinks? selectedLink =
          isQuality ? videoModel.value.videoLinks.firstWhereOrNull((link) => link.quality == quality) : VideoLinks(url: quality);

      if (newVideoData != null) {
        videoModel = newVideoData.obs;
      }

      if(subtitleList.any((element) => element.isDefaultLanguage.getBoolInt())) {
        selectedSubtitleModel(subtitleList.firstWhere((element) => element.isDefaultLanguage.getBoolInt()));
        await loadSubtitles(selectedSubtitleModel.value);
      } else {
        currentSubtitle('');
      }
      videoUploadType(type);
      videoUrlInput(quality);

      if (selectedLink != null) {
        if (type.toLowerCase() == PlayerTypes.youtube) {
          if (youtubePlayerController.value.isInitialized) {
            youtubePlayerController.value.initialize(selectedLink.url.validate());
          } else {
            initializePlayer(selectedLink.url, type.toLowerCase());
          }
        } else {
          if (podPlayerController.value.isInitialised) {
            await podPlayerController.value.changeVideo(playVideoFrom: getVideoPlatform(type: type, videoURL: selectedLink.url));
            podPlayerController.value.videoSeekForward(currentPlaybackPosition);
            listenVideoEvent();
          } else {
            initializePlayer(selectedLink.url, type.toLowerCase());
          }
        }
      }
    } catch (e) {
      log("Error changing video: ${e.toString()}");
    }
  }

  /// Returns the correct video platform configuration for playback
  PlayVideoFrom getVideoPlatform({
    required String type,
    required String videoURL,
  }) {
    switch (type) {
      case URLType.youtube:
        return PlayVideoFrom.youtube(videoURL); // Handling YouTube playback
      case URLType.vimeo:
        return PlayVideoFrom.vimeo(videoURL); // Handling Vimeo playback (if required)
      case URLType.hsl:
      case URLType.local:
      case URLType.url:
        return PlayVideoFrom.network(videoURL); // Handling direct MP4/MKV URLs// Handling live stream videos
      default:
        throw ArgumentError('Unknown video platform type: $type');
    }
  }

  bool checkQualitySupported({required String quality, required int requirePlanLevel}) {
    if (requirePlanLevel == 0) return true;

    final currentPlanLimit = currentSubscription.value.planType
        .firstWhere((element) => element.slug == SubscriptionTitle.downloadStatus || element.limitationSlug == SubscriptionTitle.downloadStatus)
        .limit;

    return _isQualitySupportedForPlan(currentPlanLimit, quality);
  }

  bool _isQualitySupportedForPlan(PlanLimit planLimit, String quality) {
    switch (quality) {
      case "480p":
        return planLimit.four80Pixel.getBoolInt();
      case "720p":
        return planLimit.seven20p.getBoolInt();
      case "1080p":
        return planLimit.one080p.getBoolInt();
      case "1440p":
        return planLimit.oneFourFour0Pixel.getBoolInt();
      case "2K":
        return planLimit.twoKPixel.getBoolInt();
      case "4K":
        return planLimit.fourKPixel.getBoolInt();
      case "8K":
        return planLimit.eightKPixel.getBoolInt();
      default:
        return false;
    }
  }

  void onChangePodVideo() {
    LiveStream().on(changeVideoInPodPlayer, (val) {
      _handleVideoChange(val);
    });

    LiveStream().on(mOnWatchVideo, (val) {
      _handleVideoChange(val);
    });
  }

  void onUpdateSubtitle() {
    LiveStream().on(REFRESH_SUBTITLE, (val) async {
      if (val is List<SubtitleModel>) {
        if (val.isNotEmpty) {
          (val).map((e) => log(e.toJson()));
          subtitleList.clear();
          subtitleList.assignAll(val);
        }
      }
    });
  }

  void onUpdateQualities() {
    LiveStream().on(onAddVideoQuality, (val) {
      if (val is List<VideoLinks>) {
        if (val.isNotEmpty) {
          (val).map((e) => log(e.toJson()));
          availableQualities(val.map((link) => link.quality.replaceAll(RegExp(r'[pPkK]'), '').toInt()).toList());
          videoQualities(val);
          log("Quality List: ${subtitleList.length}");
        }
      }
    });
  }

  @override
  Future<void> onClose() async {
    if (!isTrailer.value && videoModel.value.type != VideoType.liveTv) await saveToContinueWatchVideo();
    if (podPlayerController.value.isInitialised) {
      podPlayerController.value.removeListener(() => podPlayerController.value);
      podPlayerController.value.dispose();
    }

    LiveStream().dispose(podPlayerPauseKey);
    LiveStream().dispose(changeVideoInPodPlayer);
    LiveStream().dispose(mOnWatchVideo);
    LiveStream().dispose(onAddVideoQuality);
    LiveStream().dispose(REFRESH_SUBTITLE);
    canChangeVideo(true);

    WakelockPlus.disable();
    super.onClose();
  }

  void _handleVideoChange(dynamic val) {
    isAutoPlay(false);
    isTrailer(false);

    if ((val as List)[0] != null) {
      changeVideo(
        quality: (val)[0],
        isQuality: (val)[1],
        type: (val)[2],
        newVideoData: (val)[4],
      );
    }
  }

  Future<void> saveToContinueWatchVideo() async {
    if (videoModel.value.id != -1) {
      String watchedTime = '';
      String totalWatchedTime = '';
      if (videoModel.value.videoUploadType.toLowerCase() == PlayerTypes.youtube) {
        if (youtubePlayerController.value.status == YPlayerStatus.playing || youtubePlayerController.value.status == YPlayerStatus.paused) {
          watchedTime = formatDuration(youtubePlayerController.value.position);
          totalWatchedTime = formatDuration(youtubePlayerController.value.duration);
        }
      } else {
        if (podPlayerController.value.videoPlayerValue != null) {
          watchedTime = formatDuration(podPlayerController.value.videoPlayerValue!.position);
          totalWatchedTime = formatDuration(podPlayerController.value.videoPlayerValue!.duration);
        }
      }

      await CoreServiceApis.saveContinueWatch(
        request: {
          "entertainment_id": videoModel.value.id.toString(),
          "watched_time": watchedTime,

          ///store actual value of video player there is chance duration might be set different then actual duration of video
          "total_watched_time": totalWatchedTime,
          "entertainment_type": getTypeForContinueWatch(type: videoModel.value.type.toLowerCase()),
          if (profileId.value != 0) "profile_id": profileId.value,
          if (getVideoType(type: videoModel.value.type) == VideoType.episode) "episode_id": videoModel.value.episodeId,
        },
      ).then((value) {
        HomeController homeScreenController = Get.find<HomeController>();
        homeScreenController.getDashboardDetail(showLoader: false);
        ProfileController profileController = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());

        profileController.getProfileDetail(showLoader: false);
        log("Success ==> $value");
      }).catchError((e) {
        log("Error LOG ==> $e");
      });
    }
  }

  String getTypeForContinueWatch({required String type}) {
    String videoType = "";
    dynamic videoTypeMap = {
      "movie": VideoType.movie,
      "video": VideoType.video,
      "livetv": VideoType.liveTv,
      'tvshow': VideoType.tvshow,
      'episode': VideoType.tvshow,
    };
    videoType = videoTypeMap[type] ?? VideoType.episode;
    return videoType;
  }

  Future<void> startDate() async {
    await CoreServiceApis.startDate(request: {
      "entertainment_id": videoModel.value.id,
      "entertainment_type": getVideoType(type: videoModel.value.type),
      "user_id": loginUserData.value.id,
      if (profileId.value != 0) "profile_id": profileId.value,
    });
  }
}