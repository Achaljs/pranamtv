import 'dart:io';
import 'package:flutter_chrome_cast/lib.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

class FCCast extends GetxController {
  RxBool isSearchingForDevice = false.obs;
  RxBool isCastingVideo = false.obs;
  String? videoURL;
  String? contentType;
  String? title;
  String? studio;
  String? subtitle;
  String? thumbnailImage;
  GoogleCastDevice? device;

  @override
  void onInit() {
    super.onInit();
    initPlatformState();
  }

  void setChromeCast({
    required String videoURL,
    String? contentType,
    String? title,
    String? subtitle,
    String? studio,
    String? thumbnailImage,
    required GoogleCastDevice device,
  }) {
    this.videoURL = videoURL;
    this.contentType = contentType;
    this.title = title.validate();
    this.subtitle = subtitle.validate();
    this.studio = studio.validate();
    this.thumbnailImage = thumbnailImage.validate();
    this.device = device;
  }

  Future<void> initPlatformState() async {
    const appId = GoogleCastDiscoveryCriteria.kDefaultApplicationId;
    GoogleCastOptions? options;
    if (Platform.isIOS) {
      options = IOSGoogleCastOptions(
        GoogleCastDiscoveryCriteriaInitialize.initWithApplicationID(appId),
      );
    } else if (Platform.isAndroid) {
      options = GoogleCastOptionsAndroid(
        appId: appId,
      );
    }
    GoogleCastContext.instance.setSharedInstanceWithOptions(options!);
  }

  Future<void> stopDiscovery() async {
    GoogleCastDiscoveryManager.instance.stopDiscovery();
    isSearchingForDevice(false);
    log("============== Stop discovery ===================");
  }

  Future<void> startDiscovery() async {
    log("============== Start discovery ===================");
    GoogleCastDiscoveryManager.instance.startDiscovery();
    isSearchingForDevice(true);
    Future.delayed(const Duration(seconds: 10), () => isSearchingForDevice(false));
  }

  Future<void> loadMedia() async {
    if (device != null) {
      await initPlatformState().then(
        (value) async {
          Future.delayed(
            const Duration(seconds: 3),
            () {
              return GoogleCastRemoteMediaClient.instance.queueLoadItems(
                [
                  GoogleCastQueueItem(
                    mediaInformation: GoogleCastMediaInformationIOS(
                      contentId: '1',
                      streamType: CastMediaStreamType.BUFFERED,
                      //contentUrl: Uri.parse(videoURL.validate()),
                      // testing URL
                      contentUrl: Uri.parse('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'),
                      contentType: 'video/mp4',
                      metadata: GoogleCastMovieMediaMetadata(
                        title: title.validate(),
                        studio: studio,
                        images: [
                          GoogleCastImage(
                            //url: Uri.parse(thumbnailImage.validate()),
                            // testing URL
                            url: Uri.parse('https://i.ytimg.com/vi_webp/gWw23EYM9VM/maxresdefault.webp'),
                            height: 480,
                            width: 854,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                options: GoogleCastQueueLoadOptions(
                  startIndex: 0,
                  playPosition: const Duration(seconds: 90),
                  repeatMode: GoogleCastMediaRepeatMode.ALL,
                ),
              );
            },
          );
        },
      );
    }
  }
}
