class News {
  final String id;
  final String title;
  final String url;
  final String imageUrl;
  final String date;
  final String category;

  News({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.date,
    required this.category,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      date: json['date'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
