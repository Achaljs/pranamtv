import '../utils/constants.dart';
import '../video_players/model/video_model.dart';

class SearchItemModel {
  final int id;
  final String title;
  final String portraitImage;
  final String landscapeImage;
  final int version;
  final int itemType;
  final String ratings;
  final int view;

  SearchItemModel({
    required this.id,
    required this.title,
    required this.portraitImage,
    required this.landscapeImage,
    required this.version,
    required this.itemType,
    required this.ratings,
    required this.view,
  });

  factory SearchItemModel.fromJson(Map<String, dynamic> json) {
    return SearchItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      portraitImage: json['image']?['portrait'] ?? '',
      landscapeImage: json['image']?['landscape'] ?? '',
      version: json['version'] ?? 0,
      itemType: json['item_type'] ?? 0,
      ratings: json['ratings']?.toString() ?? '0.0',
      view: json['view'] ?? 0,
    );
  }

  get year => null;

  String get image => portraitImage;
}




