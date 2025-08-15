class PopularMoviesResponse {
  final String remark;
  final String status;
  final Message message;
  final PopularMoviesData data;

  PopularMoviesResponse({
    required this.remark,
    required this.status,
    required this.message,
    required this.data,
  });

  factory PopularMoviesResponse.fromJson(Map<String, dynamic> json) {
    return PopularMoviesResponse(
      remark: json['remark'] ?? '',
      status: json['status'] ?? '',
      message: Message.fromJson(json['message'] ?? {}),
      data: PopularMoviesData.fromJson(json['data'] ?? {}),
    );
  }
}

class PopularMoviesData {
  final List<PopularItem> featured;
  final String portraitPath;
  final String landscapePath;

  PopularMoviesData({
    required this.featured,
    required this.portraitPath,
    required this.landscapePath,
  });

  factory PopularMoviesData.fromJson(Map<String, dynamic> json) {
    return PopularMoviesData(
      featured: (json['featured'] as List<dynamic>?)
              ?.map((item) => PopularItem.fromJson(item))
              .toList() ??
          [],
      portraitPath: json['portrait_path'] ?? '',
      landscapePath: json['landscape_path'] ?? '',
    );
  }
}

class PopularItem {
  final String title;
  final ItemImage image;
  final int id;
  final int version;
  final int itemType;
  final String ratings;
  final int view;

  PopularItem({
    required this.title,
    required this.image,
    required this.id,
    required this.version,
    required this.itemType,
    required this.ratings,
    required this.view,
  });

  factory PopularItem.fromJson(Map<String, dynamic> json) {
    return PopularItem(
      title: json['title'] ?? '',
      image: ItemImage.fromJson(json['image'] ?? {}),
      id: json['id'] ?? 0,
      version: json['version'] ?? 0,
      itemType: json['item_type'] ?? 1,
      ratings: json['ratings']?.toString() ?? '0.0',
      view: json['view'] ?? 0,
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

class Message {
  final List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      success: List<String>.from(json['success'] ?? []),
    );
  }
}
