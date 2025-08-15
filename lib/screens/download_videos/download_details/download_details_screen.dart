import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/download_videos/download_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';

import '../../../components/app_scaffold.dart';
class DownloadDetailsScreen extends StatelessWidget {
  final VideoPlayerModel movieDetails;

  final DownloadController downloadVideoCont;

  const DownloadDetailsScreen({super.key, required this.movieDetails, required this.downloadVideoCont});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      hasLeadingWidget: false,
      isLoading: false.obs,
      hideAppBar: true,
      scaffoldBackgroundColor: appScreenBackgroundDark,
      body:Container()/* VideoPlayersComponent(
        videoModel: movieDetails,
        isTrailer: false,
        isFromDownloads: true,
      )*/,
    );
  }
}