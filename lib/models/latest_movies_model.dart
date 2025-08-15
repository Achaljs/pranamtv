// models/latest_movies_model.dart
class LatestMoviesResponse {
  final String remark;
  final String status;
  final Message message;
  final LatestMoviesData data;

  LatestMoviesResponse({
    required this.remark,
    required this.status,
    required this.message,
    required this.data,
  });

  factory LatestMoviesResponse.fromJson(Map<String, dynamic> json) {
    return LatestMoviesResponse(
      remark: json['remark'] ?? '',
      status: json['status'] ?? '',
      message: Message.fromJson(json['message'] ?? {}),
      data: LatestMoviesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remark': remark,
      'status': status,
      'message': message.toJson(),
      'data': data.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return {
      'success': success,
    };
  }
}

class LatestMoviesData {
  final List<RecentItem> recent;
  final String portraitPath;
  final String landscapePath;

  LatestMoviesData({
    required this.recent,
    required this.portraitPath,
    required this.landscapePath,
  });

  factory LatestMoviesData.fromJson(Map<String, dynamic> json) {
    return LatestMoviesData(
      recent: (json['recent'] as List<dynamic>?)
          ?.map((item) => RecentItem.fromJson(item))
          .toList() ?? [],
      portraitPath: json['portrait_path'] ?? '',
      landscapePath: json['landscape_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recent': recent.map((item) => item.toJson()).toList(),
      'portrait_path': portraitPath,
      'landscape_path': landscapePath,
    };
  }
}

class RecentItem {
  final String title;
  final ItemImage image;
  final int id;
  final int version;
  final int itemType;
  final String ratings;
  final int view;

  RecentItem({
    required this.title,
    required this.image,
    required this.id,
    required this.version,
    required this.itemType,
    required this.ratings,
    required this.view,
  });

  factory RecentItem.fromJson(Map<String, dynamic> json) {
    return RecentItem(
      title: json['title'] ?? '',
      image: ItemImage.fromJson(json['image'] ?? {}),
      id: json['id'] ?? 0,
      version: json['version'] ?? 0,
      itemType: json['item_type'] ?? 1,
      ratings: json['ratings']?.toString() ?? '0.0',
      view: json['view'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image.toJson(),
      'id': id,
      'version': version,
      'item_type': itemType,
      'ratings': ratings,
      'view': view,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'landscape': landscape,
      'portrait': portrait,
    };
  }
}