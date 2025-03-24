class Config {
  static final Config _instance = Config._internal();

  factory Config() {
    return _instance;
  }

  Config._internal();

  // API URLs
  final String baseURL = 'http://127.0.0.1:8000/api';
  final String imageBaseURL = 'http://127.0.0.1:8000/';

  // Image Settings
  final Map<String, dynamic> image = {
    'maxWidth': 1024,
    'maxHeight': 1024,
    'format': 'png',
  };

  // Default prompt prefix
  final String defaultPromptPrefix = '';

  // Get complete image URL
  String getFullImageUrl(String imagePath) {
    // 打印原始路径以便调试
    print('Config.getFullImageUrl - 原始路径: $imagePath');

    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http') || imagePath.startsWith('data:')) {
      return imagePath;
    }

    // 确保路径格式正确
    String path = imagePath;
    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    // 确保static/目录被正确处理
    if (path.startsWith('static/')) {
      // 已经包含static前缀，直接拼接baseURL
      String fullUrl = '$imageBaseURL$path';
      print('Config.getFullImageUrl - 完整URL(1): $fullUrl');
      return fullUrl;
    } else {
      // 不包含static前缀，需要添加
      String fullUrl = '$imageBaseURL/static/$path';
      print('Config.getFullImageUrl - 完整URL(2): $fullUrl');
      return fullUrl;
    }
  }
}
