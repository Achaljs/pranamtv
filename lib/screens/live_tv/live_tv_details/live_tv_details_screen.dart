import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/live_tv/components/live_card.dart';
import 'package:streamit_laravel/screens/live_tv/live_tv_details/live_tv_details_controller.dart';
import 'package:streamit_laravel/screens/live_tv/live_tv_details/live_tv_details_shimmer_screen.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/constants.dart';
import 'package:streamit_laravel/video_players/model/video_model.dart';

import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../video_players/video_player.dart';
import 'components/live_more_like_this_component.dart';

class LiveShowDetailsScreen extends StatelessWidget {
  final LiveShowDetailsController liveShowDetCont = Get.put(LiveShowDetailsController());

  LiveShowDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      hasLeadingWidget:false,
      hideAppBar: false, // Force show app bar to test
      isLoading: liveShowDetCont.isLoading,
      topBarBgColor: Colors.transparent, // Use app primary color instead of transparent
      scaffoldBackgroundColor: appScreenBackgroundDark,
      // Add app bar title using the correct parameter
      appBartitleText: "Live TV",


      body: Obx(
        () {
          return AnimatedScrollView(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            listAnimationType: commonListAnimationType,
            physics: liveShowDetCont.isPipMode.value ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
            onSwipeRefresh: () async {
              return await liveShowDetCont.getLiveShowDetail();
            },
            children: [
              Stack(
                children: [
                  // Custom VideoPlayersComponent call with bypass logic
                  Builder(
                    builder: (context) {
                      // Temporarily set login status for this widget
                      final wasLoggedIn = isLoggedIn.value;
                      // Force logged in state for live TV
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        isLoggedIn.value = true;
                      });

                      return VideoPlayersComponent(
                        videoModel: VideoPlayerModel(
                          serverUrl: liveShowDetCont.liveShowDetails.value.serverUrl,
                          streamType: liveShowDetCont.liveShowDetails.value.streamType,
                          requiredPlanLevel: 0, // Force no plan required
                          planId: -1, // No specific plan
                          access: 'free', // Force free access
                          name: liveShowDetCont.liveShowDetails.value.name,
                          type: VideoType.liveTv,
                          description: liveShowDetCont.liveShowDetails.value.description,
                          category: liveShowDetCont.liveShowDetails.value.category,
                        ),
                        liveShowModel: liveShowDetCont.liveShowDetails.value,
                        isTrailer: false,
                        isPipMode: liveShowDetCont.isPipMode.value,
                      );
                    },
                  ),
                  const Positioned(
                    top: 12,
                    left: 48,
                    child: LiveCard(),
                  ),
                ],
              ),
              Obx(
                    () => SnapHelperWidget(
                  future: liveShowDetCont.getLiveShowDetailsFuture.value,
                  loadingWidget: const LiveTvDetailsShimmerScreen(),
                  errorBuilder: (error) {
                    return NoDataWidget(
                      titleTextStyle: secondaryTextStyle(color: white),
                      subTitleTextStyle: primaryTextStyle(color: white),
                      title: error,
                      retryText: locale.value.reload,
                      imageWidget: const ErrorStateWidget(),
                      onRetry: () {
                        liveShowDetCont.getLiveShowDetail();
                      },
                    );
                  },
                  onSuccess: (res) {
                    if (!liveShowDetCont.isPipMode.value) {
                      return LiveMoreListComponent(moreList: liveShowDetCont.liveShowDetails.value.moreItems)
                          .visible(liveShowDetCont.liveShowDetails.value.moreItems.isNotEmpty)
                          .paddingSymmetric(horizontal: 12, vertical: 16);
                    } else {
                      return Offstage();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}