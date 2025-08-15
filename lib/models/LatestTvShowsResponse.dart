class LatestTvResponse {
  final String remark;
  final String status;
  final LatestTvData data;

  LatestTvResponse({
    required this.remark,
    required this.status,
    required this.data,
  });

  factory LatestTvResponse.fromJson(Map<String, dynamic> json) {
    return LatestTvResponse(
      remark: json['remark'] ?? '',
      status: json['status'] ?? '',
      data: LatestTvData.fromJson(json['data'] ?? {}),
    );
  }
}

class LatestTvData {
  final List<LatestTvItem> latest;
  final String portraitPath;
  final String landscapePath;

  LatestTvData({
    required this.latest,
    required this.portraitPath,
    required this.landscapePath,
  });

  factory LatestTvData.fromJson(Map<String, dynamic> json) {
    return LatestTvData(
      latest: (json['latest'] as List<dynamic>?)
          ?.map((e) => LatestTvItem.fromJson(e))
          .toList() ??
          [],
      portraitPath: json['portrait_path'] ?? '',
      landscapePath: json['landscape_path'] ?? '',
    );
  }
}

class LatestTvItem {
  final String title;
  final int id;
  final int version;
  final int itemType;
  final String ratings;
  final int view;
  final TvImage image;

  LatestTvItem({
    required this.title,
    required this.id,
    required this.version,
    required this.itemType,
    required this.ratings,
    required this.view,
    required this.image,
  });

  factory LatestTvItem.fromJson(Map<String, dynamic> json) {
    return LatestTvItem(
      title: json['title'] ?? '',
      id: json['id'] ?? 0,
      version: json['version'] ?? 0,
      itemType: json['item_type'] ?? 0,
      ratings: json['ratings']?.toString() ?? '0.0',
      view: json['view'] ?? 0,
      image: TvImage.fromJson(json['image'] ?? {}),
    );
  }
}

class TvImage {
  final String portrait;
  final String landscape;

  TvImage({
    required this.portrait,
    required this.landscape,
  });

  factory TvImage.fromJson(Map<String, dynamic> json) {
    return TvImage(
      portrait: json['portrait'] ?? '',
      landscape: json['landscape'] ?? '',
    );
  }
}
