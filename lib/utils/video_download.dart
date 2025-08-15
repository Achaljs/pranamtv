import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';

import '../network/core_api.dart';
import '../main.dart';
import 'app_common.dart';

class DownloadManagerController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
}

class FileStorage {
  final DownloadManagerController downloadCont = Get.put(DownloadManagerController());

  Future<String> getExternalDocumentPath() async {
    await _requestStoragePermission(); // Request permission at the start

    Directory directory = await getApplicationDocumentsDirectory();

    final exPath = directory.path;
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<String> get _localPath async {
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  Future<void> storeVideoInLocalStore({
    bool isFromVideo = false,
    required String fileUrl,
    required VideoPlayerModel videoModel,
    required Function(int) onProgress,
    VoidCallback? refreshCall,
    Function(bool)? loaderOnOff,
  }) async {
    try {
      await _requestStoragePermission(); // Ensure permission is granted before downloading

      //Download the thumbnail first
      File thumbnailDownload = await FileStorage().downloadFile(
        videoModel.thumbnailImage,
        videoModel.thumbnailImage.split("/").last,
        (progress) {
          log('Thumbnail Download progress: $progress');
        },
        true,
      );

      if (thumbnailDownload.path.isNotEmpty) {
        await storeVideoMetadata(videoModel, thumbnailDownload.path);
      }

      // Download the video file after the thumbnail
      File videoDownload = await FileStorage().downloadFile(
        fileUrl,
        fileUrl.split("/").last,
        (progress) async {
          onProgress.call((progress * 100).toInt());
          setValue('${SharedPreferenceConst.DOWNLOAD_KEY}_${videoModel.id}', (progress * 100).toInt());
        },
        false,
      );

      // If no errors, store the video metadata
      if (downloadCont.isError.isFalse && fileUrl.isNotEmpty) {
        /* await downloadAPICall(
          videoModel: videoModel,
          isDownloaded: 1,
          isFromVideo: isFromVideo,
          refreshCall: () {
            refreshCall?.call();
          },
        );*/

        await updateVideoMetadata(
          videoModel,
          videoDownload.path,
        ).then(
          (value) {
            refreshCall?.call();
          },
        );
      } else {
        downloadCont.isLoading(false);
        toast("Invalid Video URL!!", print: true);
        removeVideoById(
          [videoModel.id],
          refreshCall,
          loaderOnOff: (bool isLoading) {
            downloadCont.isLoading(isLoading);
          },
        );
      }
    } catch (e) {
      downloadCont.isLoading(false);
      toast("Invalid Video URL Path!!");
      log(e.toString());
    }
  }

  Future<bool> removeFromLocalStore({
    required String fileUrl,
    required String fileName,
    required bool isDownload,
    required List<int> idList,
    VoidCallback? refreshCall,
  }) async {
    downloadCont.isLoading(true);
    final path = await _localPath;
    File file;
    bool isDeleteDone = false;

    if (isDownload) {
      file = File(fileUrl);
    } else {
      file = File('$path/$fileName');
    }
    if (file.existsSync()) {
      try {
        // Delete the file
        file.deleteSync();
        isDeleteDone = true;
        removeVideoById(
          idList,
          refreshCall,
          loaderOnOff: (p0) {
            downloadCont.isLoading(p0);
          },
        );
        downloadCont.isLoading(false);
      } catch (e) {
        isDeleteDone = false;
        Get.back();
        errorSnackBar(error: e);
        downloadCont.isLoading(false);
        downloadCont.isError(true);
      }
    } else {
      isDeleteDone = false;
      removeVideoById(
        idList,
        refreshCall,
        loaderOnOff: (p0) {
          downloadCont.isLoading(p0);
        },
      );
      Get.back();
      errorSnackBar(error: 'File not found.');
      downloadCont.isLoading(false);
    }

    return isDeleteDone;
  }

  Future<File> downloadFile(String fileUrl, String fileName, Function(double) onProgress, bool isThumbnail) async {
    final path = await _localPath;
    File file = File('$path/$fileName');
    if (fileUrl.validateURL()) {
      try {
        final response = await http.get(Uri.parse(fileUrl));
        if (response.statusCode == 200) {
          if (!isThumbnail) successSnackBar(locale.value.downloadHasBeenStarted);
          int totalBytes = response.bodyBytes.length;
          int bytesWritten = 0;
          const chunkSize = 1024 * 10; // 10KB chunk size for efficiency
          List<int> bytes = response.bodyBytes;

          while (bytesWritten < totalBytes) {
            int chunkEnd = bytesWritten + chunkSize;
            if (chunkEnd > totalBytes) {
              chunkEnd = totalBytes;
            }
            List<int> chunk = bytes.sublist(bytesWritten, chunkEnd);
            await file.writeAsBytes(chunk, mode: FileMode.append);
            bytesWritten += chunk.length;
            double progress = bytesWritten / totalBytes;
            onProgress(progress);
          }
          downloadCont.isError(false);
        } else {
          downloadCont.isLoading(false);
          downloadCont.isError(true);
          _handleError('Failed to download file: ${response.statusCode}', response.body.toString());
        }
      } catch (e) {
        downloadCont.isError(true);
        downloadCont.isLoading(false);
      }
    } else {
      downloadCont.isError(true);
      downloadCont.isLoading(false);
    }

    return file;
  }

  void _handleError(String logMessage, String errorMessage) {
    downloadCont.isLoading(false);
    // errorSnackBar(errorMessage);
    log(logMessage);
  }

  Future<bool> checkIfAlreadyDownloaded({
    required int videoId,
  }) async {
    File file;
    bool isExist = false;

    // Retrieve the current list of downloaded videos from shared preferences
    downloadCont.isLoading(true);
    List<String>? videoListJson = getStringListAsync('${SharedPreferenceConst.DOWNLOAD_VIDEOS}_${loginUserData.value.id}');

    if (videoListJson.validate().isEmpty) {
      log('No videos found in shared preferences');
      return false;
    }

    // Convert the JSON list to a list of VideoPlayerModel objects
    List<VideoPlayerModel> downloadVideos = videoListJson.validate().map((item) => VideoPlayerModel.fromJson(json.decode(item))).toList();

    if (downloadVideos.any((element) => element.id == videoId)) {
      VideoPlayerModel playerModel = downloadVideos.where((element) => element.id == videoId).first;
      file = File(playerModel.videoUrlInput);
      isExist = file.existsSync();
    }

    return isExist;
  }
}

Future<void> storeVideoMetadata(VideoPlayerModel metadata, String thumbnail) async {
  List<String>? videoListJson = getStringListAsync('${SharedPreferenceConst.DOWNLOAD_VIDEOS}_${loginUserData.value.id}');
  List<VideoPlayerModel> downloadVideos = videoListJson != null ? videoListJson.map((item) => VideoPlayerModel.fromJson(json.decode(item))).toList() : [];
  metadata.updateThumbnail(thumbnail.replaceAll("File:", "").trim());
  downloadVideos.add(metadata);

  List<String> updatedVideoListJson = downloadVideos.map((video) => jsonEncode(video.toJson())).toList();
  await setValue('${SharedPreferenceConst.DOWNLOAD_VIDEOS}_${loginUserData.value.id}', updatedVideoListJson);
}

Future<void> updateVideoMetadata(VideoPlayerModel metadata, String videoFilePath) async {
  List<String>? videoListJson = getStringListAsync('${SharedPreferenceConst.DOWNLOAD_VIDEOS}_${loginUserData.value.id}');
  List<VideoPlayerModel> downloadVideos = videoListJson != null ? videoListJson.map((item) => VideoPlayerModel.fromJson(json.decode(item))).toList() : [];
  metadata.updateDownloadUrl(videoFilePath.replaceAll("File:", "").trim());
  if (downloadVideos.isNotEmpty && downloadVideos.any((element) => element.id == metadata.id)) {
    int index = downloadVideos.indexWhere((element) => element.id == metadata.id);
    if (index > -1) {
      downloadVideos[index] = metadata;
    }
  } else {
    metadata.updateThumbnail(videoFilePath.replaceAll("File:", "").trim());
    downloadVideos.add(metadata);
  }

  List<String> updatedVideoListJson = downloadVideos.map((video) => jsonEncode(video.toJson())).toList();
  await setValue('${SharedPreferenceConst.DOWNLOAD_VIDEOS}_${loginUserData.value.id}', updatedVideoListJson);
}

Future<void> removeVideoById(List<int> videoIdToRemove, VoidCallback? refreshCall, {required Function(bool) loaderOnOff}) async {
  loaderOnOff.call(true);
  // Retrieve the current list of downloaded videos from shared preferences
  List<String>? videoListJson = getStringListAsync('${SharedPreferenceConst.DOWNLOAD_VIDEOS}_${loginUserData.value.id}');

  if (videoListJson == null) {
    log('No videos found in shared preferences');
    return;
  }

  // Convert the JSON list to a list of VideoPlayerModel objects
  List<VideoPlayerModel> downloadVideos = videoListJson.map((item) => VideoPlayerModel.fromJson(json.decode(item))).toList();

  // Remove the video with the specified ID
  videoIdToRemove.forEachIndexed(
    (element, index) {
      downloadVideos.removeWhere((video) => video.id == element);
    },
  );

  log('Removed video with ID: $videoIdToRemove');

  // Convert the updated list of videos back to JSON
  List<String> updatedVideoListJson = downloadVideos.map((video) => jsonEncode(video.toJson())).toList();

  // Save the updated list back to shared preferences
  await setValue('${SharedPreferenceConst.DOWNLOAD_VIDEOS}_${loginUserData.value.id}', updatedVideoListJson);
  refreshCall?.call();
  loaderOnOff.call(false);
}

Future<void> downloadAPICall({
  required VideoPlayerModel videoModel,
  required int isDownloaded,
  bool isFromVideo = false,
  VoidCallback? refreshCall,
  required Function(bool) loaderOnOff,
}) async {
  loaderOnOff.call(true);
  Map<dynamic, dynamic> req = {
    "entertainment_id": videoModel.entertainmentId,
    "is_download": isDownloaded,
    'device_id': yourDevice.value.deviceId,
  };

  if (isDownloaded.getBoolInt()) {
    req.putIfAbsent('entertainment_type', () => getVideoType(type: videoModel.type));
    req.putIfAbsent("type", () => videoModel.trailerUrlType);
    req.putIfAbsent("quality", () => videoModel.enableDownloadQuality);
    req.putIfAbsent('url', () => videoModel.videoUrlInput);
  }
  if (isFromVideo) req.putIfAbsent("type", () => "video");
  CoreServiceApis.saveDownload(request: req).then((value) {
    refreshCall?.call();
    successSnackBar(isDownloaded.getBoolInt() ? locale.value.downloadSuccessfully : "Video removed from your downloads");
  }).catchError((e) {
    errorSnackBar(error: e);
  }).whenComplete(() {
    loaderOnOff.call(false);
  });
}