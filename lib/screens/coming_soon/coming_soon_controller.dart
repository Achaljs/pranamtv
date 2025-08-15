import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:streamit_laravel/screens/coming_soon/model/coming_soon_response.dart';

import '../../models/ContestModel.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';

class ComingSoonController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isRefresh = false.obs;
  RxBool isLastPage = false.obs;

  RxBool isFullScreenEnable = false.obs;
  RxInt page = 1.obs;

  RxInt currentSelected = (-1).obs;
  Rx<Future<RxList<ComingSoonModel>>> getComingFuture = Future(() => RxList<ComingSoonModel>()).obs;
  RxList<ComingSoonModel> comingSoonList = RxList();

  Rx<ComingSoonModel> comingSoonData = ComingSoonModel().obs;

  bool getComingSoonList;

  ComingSoonController({this.getComingSoonList = false});

  @override
  void onInit() {
    super.onInit();
    if(getComingSoonList) {
      getComingSoonDetails(showLoader: false);
    }
  }

  //Get Coming Soon Details List (Updated to use contest API)
  Future<void> getComingSoonDetails({bool showLoader = true}) async {
    isLoading(showLoader);

    await getComingFuture(
      _fetchContestData(),
    ).then((value) {
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      log("getComingSoon List Err : $e");
    }).whenComplete(() => isLoading(false));
  }

  // Separate method to fetch and convert contest data
  Future<RxList<ComingSoonModel>> _fetchContestData() async {
    try {
      // Call the contest API directly
      final response = await http.get(
        Uri.parse('https://pranamtv.in/api/contests'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      log('API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Try to parse the response
        final String responseBody = response.body;
        log('API Response Length: ${responseBody.length} characters');

        // Log first 500 characters to see structure without overwhelming logs
        if (responseBody.length > 500) {
          log('API Response Preview: ${responseBody.substring(0, 500)}...');
        } else {
          log('API Response Body: $responseBody');
        }

        final Map<String, dynamic> jsonData = json.decode(responseBody);
        log('JSON Keys: ${jsonData.keys.toList()}');

        // Check if data structure exists
        if (jsonData['data'] != null) {
          log('Data section found');
          final dataSection = jsonData['data'] as Map<String, dynamic>;
          log('Data keys: ${dataSection.keys.toList()}');

          if (dataSection['new_contests'] != null) {
            log('new_contests found: ${(dataSection['new_contests'] as List).length} items');
          }
          if (dataSection['old_contests'] != null) {
            log('old_contests found: ${(dataSection['old_contests'] as List).length} items');
          }
        }

        ContestModel contestModel = ContestModel.fromJson(jsonData);

        // Convert contest data to ComingSoon format
        List<ComingSoonModel> convertedList = _convertContestToComingSoon(contestModel);

        // Clear and add all data
        comingSoonList.clear();
        comingSoonList.addAll(convertedList);

        // Set last page to true since we get all data in one call
        isLastPage(true);

        log('New contests count: ${contestModel.data?.newContests?.length ?? 0}');
        log('Old contests count: ${contestModel.data?.oldContests?.length ?? 0}');
        log('Total converted contests count: ${comingSoonList.length}');

        return comingSoonList;
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
        isLastPage(true);
        return comingSoonList;
      }
    } catch (e) {
      log("_fetchContestData Error: $e");
      isLastPage(true);
      rethrow;
    }
  }

  // Convert Contest data to ComingSoon format
  List<ComingSoonModel> _convertContestToComingSoon(ContestModel contestModel) {
    List<ComingSoonModel> comingSoonList = [];

    log('Starting conversion...');
    log('Contest model data: ${contestModel.data}');
    log('New contests available: ${contestModel.data?.newContests?.length ?? 0}');
    log('Old contests available: ${contestModel.data?.oldContests?.length ?? 0}');

    // Process new contests
    if (contestModel.data?.newContests != null && contestModel.data!.newContests!.isNotEmpty) {
      log('Processing ${contestModel.data!.newContests!.length} new contests');
      for (int i = 0; i < contestModel.data!.newContests!.length; i++) {
        NewContests contest = contestModel.data!.newContests![i];
        log('New Contest $i: ${contest.title} (ID: ${contest.id})');

        ComingSoonModel comingSoonModel = ComingSoonModel(
          id: contest.id ?? -1,
          name: contest.title ?? "Untitled Contest",
          description: contest.description ?? contest.miniDesc ?? "",
          thumbnailImage: contest.img ?? "",
          trailerUrl: contest.img2 ?? contest.img ?? "",
          type: "Contest",
          language: "Hindi",
          releaseDate: contest.date ?? contest.enddata ?? "",
          duration: "",
          contentRating: "All",
          imdbRating: -1,
          isRestricted: false,
          isRemind: 0,
          trailerUrlType: "image",
          seasonName: "",
          genres: [],
        );
        comingSoonList.add(comingSoonModel);
      }
    } else {
      log('No new contests found');
    }

    // Process old contests
    if (contestModel.data?.oldContests != null && contestModel.data!.oldContests!.isNotEmpty) {
      log('Processing ${contestModel.data!.oldContests!.length} old contests');
      for (int i = 0; i < contestModel.data!.oldContests!.length; i++) {
        NewContests contest = contestModel.data!.oldContests![i];
        log('Old Contest $i: ${contest.title} (ID: ${contest.id})');

        ComingSoonModel comingSoonModel = ComingSoonModel(
          id: contest.id ?? -1,
          name: contest.title ?? "Untitled Contest",
          description: contest.description ?? contest.miniDesc ?? "",
          thumbnailImage: contest.img ?? "",
          trailerUrl: contest.img2 ?? contest.img ?? "",
          type: "Past Contest",
          language: "Hindi",
          releaseDate: contest.date ?? contest.enddata ?? "",
          duration: "",
          contentRating: "All",
          imdbRating: -1,
          isRestricted: false,
          isRemind: 0,
          trailerUrlType: "image",
          seasonName: "",
          genres: [],
        );
        comingSoonList.add(comingSoonModel);
      }
    } else {
      log('No old contests found');
    }

    log('Total converted contests: ${comingSoonList.length}');
    return comingSoonList;
  }

  //Save Reminder (Updated to work with contest data)
  Future<void> saveRemind({required bool isRemind}) async {
    isLoading(true);

    try {
      final response = await http.post(
        Uri.parse('https://your-api-base-url/save-reminder'), // Update with your actual API base URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "entertainment_id": comingSoonData.value.id,
          "is_remind": isRemind ? 0 : 1,
          "release_date": comingSoonData.value.releaseDate,
          if (profileId.value != 0) "profile_id": profileId.value,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        await getComingSoonDetails();

        if (isRemind) {
          comingSoonData.value.isRemind = 0;
        } else {
          comingSoonData.value.isRemind = 1;
        }

        successSnackBar(responseData['message']?.toString() ?? 'Reminder updated successfully');
      } else {
        throw Exception('Failed to save reminder: ${response.statusCode}');
      }
    } catch (e) {
      log("Save Reminder Err: $e");
      errorSnackBar(error: e);
    } finally {
      isLoading(false);
    }
  }
}