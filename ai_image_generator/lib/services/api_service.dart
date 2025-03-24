import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../utils/config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final Dio _dio;
  final Config _config = Config();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _config.baseURL,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for logging if in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  // Get full image URL
  String getFullImageUrl(String imagePath) {
    return _config.getFullImageUrl(imagePath);
  }

  // Generate image from text
  Future<ImageGenerationResponse> generateFromText(String prompt) async {
    try {
      final response = await _dio.post('/generate_from_text', data: {
        'prompt': prompt,
      });

      return ImageGenerationResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('Error generating image from text: ${e.message}');
      return ImageGenerationResponse(
        success: false,
        message: e.message,
      );
    }
  }

  // Generate image from existing image
  Future<ImageGenerationResponse> generateFromImage(
      File image, String prompt) async {
    try {
      // 确定文件的MIME类型
      String mimeType = 'image/jpeg'; // 默认类型
      String filename = image.path.split('/').last;

      // 根据文件扩展名设置对应的MIME类型
      if (filename.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (filename.toLowerCase().endsWith('.jpg') ||
          filename.toLowerCase().endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (filename.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      // 如果文件没有扩展名或不是支持的格式，添加.jpg扩展名
      if (!filename.toLowerCase().endsWith('.jpg') &&
          !filename.toLowerCase().endsWith('.jpeg') &&
          !filename.toLowerCase().endsWith('.png') &&
          !filename.toLowerCase().endsWith('.webp')) {
        filename = "$filename.jpg";
      }

      print('上传图片: $filename, MIME类型: $mimeType');

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        ),
        'prompt': prompt,
      });

      final response = await _dio.post(
        '/generate',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          sendTimeout: const Duration(seconds: 90),
        ),
      );

      return ImageGenerationResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('Error generating image from image: ${e.message}');
      return ImageGenerationResponse(
        success: false,
        message: e.message,
      );
    }
  }

  // Upload image
  Future<ImageUploadResponse> uploadImage(File file) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return ImageUploadResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('Error uploading image: ${e.message}');
      return ImageUploadResponse(
        success: false,
        message: e.message,
      );
    }
  }
}
