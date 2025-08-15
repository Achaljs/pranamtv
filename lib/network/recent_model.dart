class RecentResponse {
  final String remark;
  final String status;
  final Message message;
  final RecentData data;

  RecentResponse({
    required this.remark,
    required this.status,
    required this.message,
    required this.data,
  });

  factory RecentResponse.fromJson(Map<String, dynamic> json) => RecentResponse(
    remark: json['remark'],
    status: json['status'],
    message: Message.fromJson(json['message']),
    data: RecentData.fromJson(json['data']),
  );
}

class Message {
  final List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: List<String>.from(json['success']),
  );
}

class RecentData {
  final List<RecentItem> recent;
  final String portraitPath;
  final String landscapePath;

  RecentData({
    required this.recent,
    required this.portraitPath,
    required this.landscapePath,
  });

  factory RecentData.fromJson(Map<String, dynamic> json) => RecentData(
    recent: List<RecentItem>.from(
        json['recent'].map((x) => RecentItem.fromJson(x))),
    portraitPath: json['portrait_path'],
    landscapePath: json['landscape_path'],
  );
}

class RecentItem {
  final String title;
  final int id;
  final int version;
  final int itemType;
  final String ratings;
  final int view;
  final ImageData image;

  RecentItem({
    required this.title,
    required this.id,
    required this.version,
    required this.itemType,
    required this.ratings,
    required this.view,
    required this.image,
  });

  factory RecentItem.fromJson(Map<String, dynamic> json) => RecentItem(
    title: json['title'],
    id: json['id'],
    version: json['version'],
    itemType: json['item_type'],
    ratings: json['ratings'],
    view: json['view'],
    image: ImageData.fromJson(json['image']),
  );
}

class ImageData {
  final String landscape;
  final String portrait;

  ImageData({required this.landscape, required this.portrait});

  factory ImageData.fromJson(Map<String, dynamic> json) => ImageData(
    landscape: json['landscape'],
    portrait: json['portrait'],
  );
}
