import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/movie_details/movie_details_controller.dart';
import 'package:streamit_laravel/screens/tv_show/tv_show_controller.dart';
import 'package:streamit_laravel/screens/video/video_details_controller.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';

import '../main.dart';

void showSuccessDialog(BuildContext context, String movieName, int days, VideoPlayerModel videoModel) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
              child: Icon(Icons.check, color: Colors.white, size: 40),
            ),
            SizedBox(height: 20),
            Text(
              "Successfully Rented",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              movieName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              locale.value.enjoyUntilDays(days),
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                Get.back();
                if(videoModel.type == VideoType.movie){
                  final movieDetCont = Get.find<MovieDetailsController>();
                  movieDetCont.getMovieDetail();
                }else if(videoModel.type == VideoType.tvshow){
                  final tvShowCont = Get.find<TvShowController>();
                  tvShowCont.getTvShowDetail();
                }else if(videoModel.type == VideoType.video){
                  final videoCont = Get.find<VideoDetailsController>();
                  videoCont.getMovieDetail();
                }
              },
              child: Text(
                locale.value.beginWatching,
                style: boldTextStyle(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
