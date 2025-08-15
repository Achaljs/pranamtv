// Create this as a new file: lib/screens/live_tv/model/new_tv_detail_model.dart

class NewTvDetailResponse {
  String? remark;
  String? status;
  Message? message;
  TvData? data;

  NewTvDetailResponse({this.remark, this.status, this.message, this.data});

  NewTvDetailResponse.fromJson(Map<String, dynamic> json) {
    remark = json['remark'];
    status = json['status'];
    message = json['message'] != null ? Message.fromJson(json['message']) : null;
    data = json['data'] != null ? TvData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['remark'] = remark;
    data['status'] = status;
    if (message != null) {
      data['message'] = message!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Message {
  List<String>? success;

  Message({this.success});

  Message.fromJson(Map<String, dynamic> json) {
    success = json['success'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    return data;
  }
}

class TvData {
  TvDetails? tv;
  List<dynamic>? relatedTv;
  String? imagePath;
  List<dynamic>? showstimeline;

  TvData({this.tv, this.relatedTv, this.imagePath, this.showstimeline});

  TvData.fromJson(Map<String, dynamic> json) {
    tv = json['tv'] != null ? TvDetails.fromJson(json['tv']) : null;
    relatedTv = json['related_tv'] ?? [];
    imagePath = json['image_path'];
    showstimeline = json['showstimeline'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (tv != null) {
      data['tv'] = tv!.toJson();
    }
    data['related_tv'] = relatedTv;
    data['image_path'] = imagePath;
    data['showstimeline'] = showstimeline;
    return data;
  }
}

class TvDetails {
  int? id;
  String? title;
  String? description;
  String? image;
  String? url;
  int? status;
  String? createdAt;
  String? updatedAt;

  TvDetails({
    this.id,
    this.title,
    this.description,
    this.image,
    this.url,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  TvDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    url = json['url'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['url'] = url;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  // Helper methods for compatibility with existing UI
  String get fullImageUrl => "https://pranamtv.in/assets/images/television/$image";
  String get streamUrl => url ?? "";
  bool get isActive => status == 1;
}