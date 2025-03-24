class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T? Function(Map<String, dynamic>)? fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : null,
    );
  }
}

class ImageGenerationResponse {
  final bool success;
  final String? result;
  final String? imageUrl;
  final String? message;

  ImageGenerationResponse({
    required this.success,
    this.result,
    this.imageUrl,
    this.message,
  });

  factory ImageGenerationResponse.fromJson(Map<String, dynamic> json) {
    // 打印原始JSON以便调试
    print('ImageGenerationResponse.fromJson - 原始数据: $json');

    // 从JSON中获取image_url，可能位于不同字段
    String? imageUrl = json['image_url'];

    // 尝试从不同的字段获取URL（API可能有不同返回格式）
    if (imageUrl == null || imageUrl.isEmpty) {
      imageUrl = json['imageUrl'];
    }

    // 如果数据在detail字段内
    if (imageUrl == null && json['detail'] != null) {
      try {
        // 尝试解析detail字段
        final detailStr = json['detail'] as String;
        if (detailStr.contains('image_url')) {
          // 尝试提取image_url
          final regex = RegExp(r'"image_url"\s*:\s*"([^"]+)"');
          final match = regex.firstMatch(detailStr);
          if (match != null && match.groupCount >= 1) {
            imageUrl = match.group(1);
          }
        }
      } catch (e) {
        print('解析detail字段出错: $e');
      }
    }

    print('解析后的图片URL: $imageUrl');

    return ImageGenerationResponse(
      success: json['success'] ?? false,
      result: json['result'],
      imageUrl: imageUrl,
      message: json['message'],
    );
  }
}

class ImageUploadResponse {
  final bool success;
  final String? imageUrl;
  final String? imageId;
  final String? message;

  ImageUploadResponse({
    required this.success,
    this.imageUrl,
    this.imageId,
    this.message,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      success: json['success'] ?? false,
      imageUrl: json['imageUrl'],
      imageId: json['imageId']?.toString(),
      message: json['message'],
    );
  }
}
