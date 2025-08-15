import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/live_tv/live_tv_details/model/live_tv_details_response.dart';
import 'package:streamit_laravel/screens/live_tv/model/live_tv_dashboard_response.dart';
import 'package:http/http.dart' as http;
// Import your new model
import '../../../utils/app_common.dart';
import '../../../utils/constants.dart';
import 'model/new_tv_detail_model.dart';

class LiveShowDetailsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isRefresh = false.obs;
  RxBool pipAvailable = false.obs;
  RxBool isPipMode = false.obs;
  RxBool isFullScreenEnable = false.obs;

  // Keep original for compatibility - Initialize with a proper future
  Rx<Future<LiveShowDetailResponse>> getLiveShowDetailsFuture =
      Future.value(LiveShowDetailResponse(data: LiveShowModel())).obs;
  Rx<LiveShowModel> liveShowDetails = LiveShowModel().obs;

  // New model data
  Rx<TvDetails> tvDetails = TvDetails().obs;
  Rx<NewTvDetailResponse> apiResponse = NewTvDetailResponse().obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize the future IMMEDIATELY before calling any methods
    _initializeFuture();
    getLiveShowDetail(showLoader: false);
  }

  /// Initialize the future so UI has something to listen to immediately
  void _initializeFuture() {
    getLiveShowDetailsFuture.value = _fetchLiveTvData();
  }

  /// Get TV details from new API and map to existing model structure
  Future<void> getLiveShowDetail({bool showLoader = true}) async {
    isLoading(showLoader);

    try {
      // The future is already set in onInit, just await it
      final response = await getLiveShowDetailsFuture.value;
      print('Live TV data loaded successfully: ${response.data?.name}');
    } catch (e) {
      print("getLiveShowDetail Error: $e");
      // On error, set a new future for retry
      getLiveShowDetailsFuture.value = _fetchLiveTvData();
    } finally {
      isLoading(false);
    }
  }

  /// Separate method to fetch and convert live TV data
  Future<LiveShowDetailResponse> _fetchLiveTvData() async {
    try {
      print('Fetching live TV data...');

      final response = await http.get(
        Uri.parse('https://pranamtv.in/api/live-tv/2'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Live TV API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('Live TV JSON Keys: ${jsonData.keys.toList()}');

        final newTvResponse = NewTvDetailResponse.fromJson(jsonData);
        apiResponse(newTvResponse);

        if (newTvResponse.data?.tv != null) {
          tvDetails(newTvResponse.data!.tv!);

          print('TV Details loaded: ${newTvResponse.data!.tv!.title}');

          // Map new API data to existing model structure for UI compatibility
          LiveShowModel mappedData = LiveShowModel(
            id: newTvResponse.data!.tv!.id ?? 2,
            name: newTvResponse.data!.tv!.title ?? 'PranamTV',
            description: newTvResponse.data!.tv!.description ?? '',
            posterImage: newTvResponse.data!.tv!.fullImageUrl,
            serverUrl: newTvResponse.data!.tv!.url ?? '',
            serverUrl1: '', // Not available in new API
            streamType: 'hls', // Assuming HLS based on .m3u8 extension
            category: 'Live TV',
            embedded: null,
            embedUrl: '',
            moreItems: [], // Empty since new API doesn't have related items
            status: newTvResponse.data!.tv!.status ?? 1,
            isDeviceSupported: true,
            access: 'free', // Set based on your logic
            requiredPlanLevel: 0,
            planId: -1,
          );

          // Update the observable
          liveShowDetails.value = mappedData;
          liveShowDetails.refresh();

          // Set device support
          isSupportedDevice(true);
          setValue(SharedPreferenceConst.IS_SUPPORTED_DEVICE, true);

          // Return the response in the expected format
          return LiveShowDetailResponse(
            status: true,
            data: mappedData,
            message: newTvResponse.message?.success?.isNotEmpty == true
                ? newTvResponse.message!.success![0]
                : 'Success',
          );
        } else {
          throw Exception('No TV data found in response');
        }
      } else {
        throw Exception('Failed to load TV details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _fetchLiveTvData: $e');
      // Return a default response on error
      return LiveShowDetailResponse(
        status: false,
        data: LiveShowModel(),
        message: 'Failed to load TV details',
      );
    }
  }

  @override
  Future<void> onClose() async {
    super.onClose();
  }
}