// lib/models/featured_model.dart

class FeaturedResponse {
  final String remark;
  final String status;
  final MessageData message;
  final FeaturedData data;

  FeaturedResponse({
    required this.remark,
    required this.status,
    required this.message,
    required this.data,
  });

  factory FeaturedResponse.fromJson(Map<String, dynamic> json) {
    return FeaturedResponse(
      remark: json['remark'] ?? '',
      status: json['status'] ?? '',
      message: MessageData.fromJson(json['message'] ?? {}),
      data: FeaturedData.fromJson(json['data'] ?? {}),
    );
  }
}

class MessageData {
  final List<String> success;

  MessageData({required this.success});

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      success: List<String>.from(json['success'] ?? []),
    );
  }
}

class FeaturedData {
  final List<FeaturedItem> featured;
  final String landscapePath;
  final String portraitPath;

  FeaturedData({
    required this.featured,
    required this.landscapePath,
    required this.portraitPath,
  });

  factory FeaturedData.fromJson(Map<String, dynamic> json) {
    return FeaturedData(
      featured: (json['featured'] as List<dynamic>?)
          ?.map((item) => FeaturedItem.fromJson(item))
          .toList() ?? [],
      landscapePath: json['landscape_path'] ?? '',
      portraitPath: json['portrait_path'] ?? '',
    );
  }
}

class FeaturedItem {
  final String title;
  final ItemImage image;
  final int id;
  final int version;
  final int itemType;
  final int categoryId;
  final int? subCategoryId;
  final int view;
  final String ratings;

  FeaturedItem({
    required this.title,
    required this.image,
    required this.id,
    required this.version,
    required this.itemType,
    required this.categoryId,
    this.subCategoryId,
    required this.view,
    required this.ratings,
  });

  factory FeaturedItem.fromJson(Map<String, dynamic> json) {
    return FeaturedItem(
      title: json['title'] ?? '',
      image: ItemImage.fromJson(json['image'] ?? {}),
      id: json['id'] ?? 0,
      version: json['version'] ?? 0,
      itemType: json['item_type'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      subCategoryId: json['sub_category_id'],
      view: json['view'] ?? 0,
      ratings: json['ratings'] ?? '0.0',
    );
  }
}

class ItemImage {
  final String landscape;
  final String portrait;

  ItemImage({
    required this.landscape,
    required this.portrait,
  });

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      landscape: json['landscape'] ?? '',
      portrait: json['portrait'] ?? '',
    );
  }
}