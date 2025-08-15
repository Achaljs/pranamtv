class RecentMovie {
  final int id;
  final String title;
  final String portraitImage;
  final String landscapeImage;
  final int version;
  final int itemType;
  final String ratings;
  final int view;

  RecentMovie({
    required this.id,
    required this.title,
    required this.portraitImage,
    required this.landscapeImage,
    required this.version,
    required this.itemType,
    required this.ratings,
    required this.view,
  });

  factory RecentMovie.fromJson(Map<String, dynamic> json, String portraitPath, String landscapePath) {
    return RecentMovie(
      id: json['id'],
      title: json['title'],
      portraitImage: "https://pranamtv.in/"+ portraitPath + json['image']['portrait'],
      landscapeImage: "https://pranamtv.in/"+ landscapePath + json['image']['landscape'],
      version: json['version'],
      itemType: json['item_type'],
      ratings: json['ratings'],
      view: json['view'],
    );
  }
}
