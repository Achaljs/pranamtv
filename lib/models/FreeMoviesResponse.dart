class FreeMoviesResponse {
  final String remark;
  final String status;
  final Message message;
  final FreeMoviesData data;

  FreeMoviesResponse({
    required this.remark,
    required this.status,
    required this.message,
    required this.data,
  });

  factory FreeMoviesResponse.fromJson(Map<String, dynamic> json) {
    return FreeMoviesResponse(
      remark: json['remark'] ?? '',
      status: json['status'] ?? '',
      message: Message.fromJson(json['message'] ?? {}),
      data: FreeMoviesData.fromJson(json['data'] ?? {}),
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

class FreeMoviesData {
  final PaginatedFreeZone freeZone;
  final String portraitPath;
  final String landscapePath;

  FreeMoviesData({
    required this.freeZone,
    required this.portraitPath,
    required this.landscapePath,
  });

  factory FreeMoviesData.fromJson(Map<String, dynamic> json) {
    return FreeMoviesData(
      freeZone: PaginatedFreeZone.fromJson(json['free_zone'] ?? {}),
      portraitPath: json['portrait_path'] ?? '',
      landscapePath: json['landscape_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'free_zone': freeZone.toJson(),
      'portrait_path': portraitPath,
      'landscape_path': landscapePath,
    };
  }
}

class PaginatedFreeZone {
  final List<FreeMovieItem> data;
  final int currentPage;
  final int lastPage;
  final int total;

  PaginatedFreeZone({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory PaginatedFreeZone.fromJson(Map<String, dynamic> json) {
    return PaginatedFreeZone(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => FreeMovieItem.fromJson(item))
          .toList() ??
          [],
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'current_page': currentPage,
      'last_page': lastPage,
      'total': total,
    };
  }
}

class FreeMovieItem {
  final String title;
  final ItemImage image;
  final int id;
  final int version;
  final int itemType;
  final String ratings;
  final int view;

  FreeMovieItem({
    required this.title,
    required this.image,
    required this.id,
    required this.version,
    required this.itemType,
    required this.ratings,
    required this.view,
  });

  factory FreeMovieItem.fromJson(Map<String, dynamic> json) {
    return FreeMovieItem(
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
