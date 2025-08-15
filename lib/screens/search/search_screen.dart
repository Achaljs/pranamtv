import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/loader_widget.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/screens/search/components/search_text_field.dart';
import 'package:streamit_laravel/screens/search/shimmer_search.dart';

import '../../components/app_scaffold.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/empty_error_state_widget.dart';
import 'components/horizontal_card_list_component.dart';
import 'components/search_component.dart';
import 'components/show_list/search_list_component.dart';
import 'search_controller.dart';

class SearchScreen extends StatelessWidget {
  final SearchScreenController searchCont;

  const SearchScreen({super.key, required this.searchCont});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      hasLeadingWidget: false,
      isLoading: searchCont.isLoading,
      hideAppBar: true,
      scaffoldBackgroundColor: appScreenBackgroundDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchTextFieldComponent().paddingSymmetric(horizontal: 16, vertical: 16),
          Obx(() => const VoiceSearchLoadingWidget().visible(searchCont.isListening.isTrue).center()),
          Obx(() {
            final results = searchCont.searchResults;

            if (searchCont.isLoading.value) return const LoaderWidget();

            if (searchCont.searchCont.text.length < 3) {
              return HorizontalCardListComponent().expand(); // show recent/popular
            }

            if (results.isEmpty) {
              return const Center(
                child: Text('No results found', style: TextStyle(color: white)),
              ).expand();
            }

            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: results.length,
              separatorBuilder: (_, __) => 12.height,
              itemBuilder: (context, index) {
                final item = results[index];
                final imageUrl = searchCont.portraitPath.value + item.image;

                return ListTile(
                  tileColor: Colors.white12,
                  contentPadding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  leading: Image.network(
                    imageUrl,
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: white),
                  ),
                  title: Text(item.title, style: boldTextStyle(color: white)),
                  subtitle: Text(
                    item.year != null ? 'Year: ${item.year}' : '',
                    style: secondaryTextStyle(color: grey),
                  ),
                  onTap: () {
                    toast("Tapped: ${item.title}");
                    // navigateToDetails(item); // optional
                  },
                );
              },
            ).expand();
          })


        ],
      ),
    );
  }
}
