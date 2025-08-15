import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/screens/home/home_controller.dart';
import 'package:streamit_laravel/screens/profile/profile_controller.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';
import 'package:streamit_laravel/video_players/video_player_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomYouTubePlayer extends StatefulWidget {
  final String videoId;
  final double aspectRatio;
  final double seekPosition; // Starting position of the video in seconds
  final Function? onVideoEnded; // Callback when the video ends
  final Function? onVideoPlaying;
  final Widget? thumbnail; // Thumbnail image for the video
  final Color progressIndicatorColor; // Color of the progress indicator
  final VideoPlayerModel videoModel;
  final VideoPlayersController controller;
  final VoidCallback? onWatchNow;
  final bool isTrailer;
  final bool isPipMode;
  final bool isLive;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onPreviousEpisode;

  const CustomYouTubePlayer({
    required this.videoId,
    this.onVideoPlaying,
    this.aspectRatio = 16 / 9,
    this.seekPosition = 0,
    this.onVideoEnded,
    this.thumbnail,
    this.progressIndicatorColor = Colors.red,
    this.onWatchNow,
    this.onNextEpisode,
    this.onPreviousEpisode,
    required this.videoModel,
    required this.controller,
    required this.isTrailer,
    required this.isLive,
    required this.isPipMode,
    super.key,
  });

  @override
  CustomYouTubePlayerState createState() => CustomYouTubePlayerState();
}

class CustomYouTubePlayerState extends State<CustomYouTubePlayer> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _isPlaying = false;
  late String currentVideoId;

  double _watchedTime = 0;
  double _totalWatchedTime = 0;

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

  Future<void> _saveToContinueWatchVideo() async {
    if (widget.videoModel.id != -1 && _watchedTime.toInt() > 0) {
      String watchedTime = '';
      String totalWatchedTime = '';

      watchedTime = formatDuration(Duration(seconds: _watchedTime.toInt()));
      totalWatchedTime = formatDuration(Duration(seconds: _totalWatchedTime.toInt()));

      await CoreServiceApis.saveContinueWatch(
        request: {
          "entertainment_id":
              getVideoType(type: widget.videoModel.type) == VideoType.episode ? widget.videoModel.entertainmentId : widget.videoModel.id.toString(),
          "watched_time": watchedTime,
          "total_watched_time": totalWatchedTime,
          "entertainment_type": getTypeForContinueWatch(type: widget.videoModel.type.toLowerCase()),
          if (profileId.value != 0) "profile_id": profileId.value,
          if (getVideoType(type: widget.videoModel.type) == VideoType.episode && widget.videoModel.episodeId > 0)
            "episode_id": widget.videoModel.id.toString(),
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
  bool _isTapped = false;

  bool _showEpisodeControls = false;
  Timer? _hideControlsTimer;

  void _onUserInteraction() {
    setState(() {
      _showEpisodeControls = true;
      _isTapped = true;
    });

    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _showEpisodeControls = false;
        _isTapped =false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    currentVideoId = widget.videoId; // Initialize with the initial videoId

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'flutter_inappwebview',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'onVideoEnded') {
            widget.onVideoEnded?.call();
          } else if (message.message == 'onVideoPlaying') {
            setState(() {
              _showEpisodeControls = _showEpisodeControls;
            });
            widget.onVideoPlaying?.call();
          } else if (message.message == 'onPlayerTapped') {
            // _onUserInteraction();
            setState(() {
              _showEpisodeControls = _showEpisodeControls;
            });
            widget.onVideoPlaying?.call();
          } else {
            try {
              Map<String, dynamic> data = jsonDecode(message.message);
              _watchedTime = double.tryParse(data['watched_time'].toString()) ?? 0.0;
              _totalWatchedTime = double.tryParse(data['total_watched_time'].toString()) ?? 0.0;
            } catch (e) {
              log("Error parsing JavaScript message: $e");
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
        ),
      );

    Future.delayed(Duration(milliseconds: 300), () {
      _webViewController.loadRequest(_buildVideoUri(currentVideoId, widget.seekPosition));
    });
  }

  Uri _buildVideoUri(String videoId, double seekPosition) {
    return Uri.dataFromString(
      '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            margin: 0;
            padding: 0;
            background: black;
            display: flex;
            justify-content: center;
            align-items: center;
          }
        </style>
      </head>
      <body>
        <div id="youtube-player"></div>
         <script>
         
          var player;
          var watchedTime = 0;

          function onYouTubeIframeAPIReady() {
            player = new YT.Player('youtube-player', {
            width: '${Get.width * 2.5}',
              height: '${Get.height * 0.8}',
              videoId: '$videoId',
              playerVars: {
                'autoplay': 1,
                'rel': 0,
                'playsinline': 1,
                'start': $seekPosition
              },
              events: {
                'onReady': onPlayerReady,
                'onStateChange': onPlayerStateChange
              }
            });
          }

          function onPlayerReady(event) {
            event.target.loadVideoById({
              'videoId': '$videoId',
              'startSeconds': $seekPosition
            });

            setInterval(() => {
              if (player && player.getCurrentTime) {
                watchedTime = player.getCurrentTime();
                window.flutter_inappwebview.postMessage(JSON.stringify({watched_time: watchedTime, total_watched_time: player.getDuration()  }));
              } 
           }, 1000); // Update watched time every second
          }
 
          function onPlayerStateChange(event) {
            if (event.data === YT.PlayerState.ENDED) {
              window.flutter_inappwebview.postMessage('onVideoEnded');
              player.loadVideoById({
                videoId: nextVideoId, 
                startSeconds: 0
              });
            }
            
   if (event.data === YT.PlayerState.PLAYING) {
    window.flutter_inappwebview.postMessage('onVideoPlaying');
  }
    if (event.data === YT.PlayerState.PAUSED) {
    window.flutter_inappwebview.postMessage('onVideoPlaying');
  }
          }
           document.addEventListener('click', function(event) {
      window.flutter_inappwebview.postMessage('onPlayerTapped');
    });
         </script>
        <script src="https://www.youtube.com/iframe_api"></script>
      </body>
      </html>
      ''',
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    );
  }

  /// Change the video by updating the WebView content
  void changeVideo(String newVideoId, {double seekPosition = 0}) {
    setState(() {
      currentVideoId = newVideoId;
      _isLoading = true;
      _isPlaying = false;
    });

    _webViewController.loadRequest(_buildVideoUri(newVideoId, seekPosition));
  }

  void _playVideo() {
    setState(() {
      _isPlaying = true;
    });
  }

  @override
  void dispose() {
    _saveToContinueWatchVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: [
          if (widget.thumbnail != null && !_isPlaying) ...[
            widget.thumbnail ?? Offstage(),
            Center(
              child: IconButton(
                icon: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white,
                ),
                onPressed: _playVideo,
              ),
            ),
          ] else
            WebViewWidget(controller: _webViewController),
          IgnorePointer(
            ignoring: _isTapped,
            child: Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _onUserInteraction();
                },
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: widget.progressIndicatorColor,
              ),
            ),
          if (_isPlaying && widget.isTrailer)
            Positioned(
              bottom: 25,
              right: 24,
              child: GestureDetector(
                onTap: () async {
                  // Optional: you can add custom logic like skipping or calling a callback
                  widget.onWatchNow?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.redAccent,
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }
}