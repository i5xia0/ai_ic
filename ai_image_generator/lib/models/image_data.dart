class ImageData {
  final String url;
  final String fullUrl;
  final String id;

  ImageData({
    required this.url,
    required this.fullUrl,
    required this.id,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      url: json['url'] ?? '',
      fullUrl: json['fullUrl'] ?? '',
      id: json['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'fullUrl': fullUrl,
      'id': id,
    };
  }
}
