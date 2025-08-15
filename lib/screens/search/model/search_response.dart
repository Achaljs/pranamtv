import '../../../models/search_item_model.dart';

class SearchResponse {
  final String portraitPath;
  final String landscapePath;
  final List<SearchItemModel> data;

  SearchResponse({
    required this.portraitPath,
    required this.landscapePath,
    required this.data,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      portraitPath: json['portrait_path'] ?? '',
      landscapePath: json['landscape_path'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((item) => SearchItemModel.fromJson(item))
          .toList(),
    );
  }
}
