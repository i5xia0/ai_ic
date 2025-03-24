import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart' show ChangeNotifier;
import '../models/chat_message.dart';
import '../models/api_response.dart';
import '../models/image_data.dart';
import '../services/api_service.dart';

class ImageGeneratorProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  bool _isProcessing = false;
  final List<ChatMessage> _chatMessages = [];
  File? _currentImage;
  File? _originalImage;
  File? _selectedImage;
  String? _selectedImageId;
  int _generatedImageCount = 0;
  final Map<String, dynamic> _currentResult = {
    'text': '',
    'imageUrl': '',
    'imageId': 0,
  };

  // Getters
  bool get isProcessing => _isProcessing;
  List<ChatMessage> get chatMessages => _chatMessages;
  File? get currentImage => _currentImage;
  String? get selectedImageId => _selectedImageId;
  int get generatedImageCount => _generatedImageCount;
  bool get hasGeneratedImages => _generatedImageCount > 0;
  bool get currentImageIsOriginal =>
      _currentImage == _originalImage && _originalImage != null;

  String get resultText => _currentResult['text'] as String;
  String get resultImageUrl => _currentResult['imageUrl'] as String;
  int get resultImageId => _currentResult['imageId'] as int;

  // Clear current image
  void clearCurrentImage() {
    _currentImage = null;
    _originalImage = null;
    _selectedImage = null;
    _selectedImageId = null;
    notifyListeners();
  }

  // Handle file selection
  void handleFileSelected(File? file) {
    if (file == null) {
      clearCurrentImage();
      return;
    }

    _currentImage = file;
    _originalImage = file;
    _selectedImage = null;
    _selectedImageId = null;
    notifyListeners();
  }

  // Handle selecting a history image
  Future<void> handleSelectHistoryImage(ImageData imageData) async {
    _selectedImageId = imageData.id;
    print('=== 开始选择历史图片 ===');
    print('Image ID: ${imageData.id}');
    print('Image URL: ${imageData.url}');
    print('Image Full URL: ${imageData.fullUrl}');

    try {
      // 确保URL是有效的
      final String imageUrl = imageData.fullUrl;
      print('准备下载图片: $imageUrl');

      // 确保图像URL不为空
      if (imageUrl.isEmpty) {
        throw Exception('图片URL为空');
      }

      // 检查URL格式是否有效
      if (!Uri.parse(imageUrl).isAbsolute) {
        throw Exception('无效的URL格式: $imageUrl');
      }

      // 确定适当的文件扩展名
      String fileExtension = '.jpg'; // 默认为jpg
      if (imageUrl.toLowerCase().endsWith('.png')) {
        fileExtension = '.png';
      } else if (imageUrl.toLowerCase().endsWith('.webp')) {
        fileExtension = '.webp';
      } else if (imageUrl.toLowerCase().endsWith('.jpeg')) {
        fileExtension = '.jpeg';
      }

      print('使用文件扩展名: $fileExtension');

      // 下载图片内容
      final response = await http.get(Uri.parse(imageUrl));

      // 检查响应状态
      if (response.statusCode != 200) {
        print('图片下载失败: HTTP ${response.statusCode}');
        print('响应头: ${response.headers}');
        throw Exception('下载图片失败: HTTP状态码 ${response.statusCode}');
      }

      // 获取图片字节
      final bytes = response.bodyBytes;
      print('图片下载成功: ${bytes.length} 字节');

      // 创建临时文件 - 使用正确的扩展名
      final tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/selected_${imageData.id}$fileExtension';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      print('图片保存到临时文件: ${file.path}');

      // 检查文件是否存在和有效
      if (!(await file.exists())) {
        throw Exception('创建临时文件失败');
      }

      _selectedImage = file;
      _currentImage = file;
      print('图片选择完成: ID=$_selectedImageId, 文件路径=${file.path}');
      print('=== 选择历史图片完成 ===');

      notifyListeners();
    } catch (e) {
      print('选择历史图片出错: $e');
      // 在UI上显示错误信息
      _chatMessages.add(ChatMessage.system(
        content: '选择图片失败: ${e.toString()}',
      ));
      notifyListeners();
    }
  }

  // Send message for image generation
  Future<void> sendMessage(String message) async {
    if (_isProcessing) return;

    final currentImageForRequest = _currentImage;

    // Add user message to chat
    _chatMessages.add(ChatMessage.user(
      content: message,
      imageUrl: currentImageForRequest?.path,
      imageId:
          _selectedImageId ?? 'temp-${DateTime.now().millisecondsSinceEpoch}',
    ));

    // Add loading message
    _chatMessages.add(ChatMessage.system(
      content: '正在处理您的请求...',
      isLoading: true,
    ));

    _isProcessing = true;
    _currentResult['text'] = '正在生成图片，请稍候...';
    _currentResult['imageUrl'] = '';
    _currentResult['imageId'] = 0;
    notifyListeners();

    try {
      ImageGenerationResponse response;

      if (currentImageForRequest != null) {
        // Image-based generation
        final imageToUse = _selectedImage ?? currentImageForRequest;
        response = await _apiService.generateFromImage(imageToUse, message);
      } else {
        // Text-based generation
        response = await _apiService.generateFromText(message);
      }

      if (!response.success || response.imageUrl == null) {
        throw Exception('生成图片失败：未获取到图片数据');
      }

      // 从图片URL中提取实际的图片ID
      String extractedImageId = extractImageIdFromUrl(response.imageUrl!);
      print('从URL提取的图片ID: $extractedImageId');

      // Update generated image count (仍然保留，用于生成本地文件名)
      _generatedImageCount++;

      // Update current result
      _currentResult['text'] = response.result ?? '';
      _currentResult['imageUrl'] = response.imageUrl!;
      _currentResult['imageId'] = extractedImageId;

      // Remove loading message
      _chatMessages.removeLast();

      // Add system response to chat
      _chatMessages.add(ChatMessage.system(
        content: response.result ?? '',
        imageUrl: response.imageUrl,
        imageId: extractedImageId,
      ));

      // 始终将新生成的图片设为当前编辑图片
      await _downloadAndSetCurrentImage(response.imageUrl!);
      _selectedImageId = extractedImageId;
    } catch (e) {
      // Remove loading message
      _chatMessages.removeLast();

      // Add error message
      _chatMessages.add(ChatMessage.system(
        content: '生成失败: ${e.toString()}',
      ));

      _currentResult['text'] = '生成失败: ${e.toString()}';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // 从图片URL中提取图片ID
  String extractImageIdFromUrl(String imageUrl) {
    try {
      // 尝试从URL中提取文件名部分
      String fileName = imageUrl.split('/').last;

      // 如果包含"generated_"前缀，移除它
      if (fileName.contains('generated_')) {
        String idWithExtension = fileName.split('generated_').last;
        // 移除文件扩展名
        String id = idWithExtension.split('.').first;
        return id;
      }

      // 如果无法按预期格式解析，使用整个文件名作为ID
      return fileName;
    } catch (e) {
      print('从URL提取ID时出错: $e, URL: $imageUrl');
      // 回退到使用时间戳作为ID
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // Helper to download an image and set it as current
  Future<void> _downloadAndSetCurrentImage(String imageUrl) async {
    try {
      print('开始下载图片: $imageUrl');
      final fullUrl = _apiService.getFullImageUrl(imageUrl);
      print('完整下载URL: $fullUrl');

      // 获取真实的图片ID
      final imageId = extractImageIdFromUrl(imageUrl);
      print('图片ID: $imageId');

      // 确定适当的文件扩展名
      String fileExtension = '.jpg'; // 默认为jpg
      if (fullUrl.toLowerCase().endsWith('.png')) {
        fileExtension = '.png';
      } else if (fullUrl.toLowerCase().endsWith('.webp')) {
        fileExtension = '.webp';
      } else if (fullUrl.toLowerCase().endsWith('.jpeg')) {
        fileExtension = '.jpeg';
      }

      // 使用http包下载图片
      final response = await http.get(Uri.parse(fullUrl));

      // 检查响应状态
      if (response.statusCode != 200) {
        print('图片下载失败: HTTP ${response.statusCode}');
        throw Exception('下载图片失败: HTTP状态码 ${response.statusCode}');
      }

      // 获取图片字节
      final bytes = response.bodyBytes;
      print('图片下载成功: ${bytes.length} 字节');

      // 创建临时文件 - 使用真实的图片ID
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/generated_$imageId$fileExtension');
      await file.writeAsBytes(bytes);
      print('图片保存到: ${file.path}');

      // 检查文件是否存在
      if (!(await file.exists())) {
        throw Exception('创建临时文件失败');
      }

      // 更新当前图片和选择的图片
      _currentImage = file;
      _selectedImage = file; // 将最新生成的图片也设置为选中的图片
      print('已设置新生成的图片: path=${file.path}, imageId=$imageId');
    } catch (e) {
      print('下载和设置当前图片时出错: $e');
      // 仅记录错误，不添加到聊天消息中，因为这是在后台进行的操作
    }
  }

  // Reset state
  void reset() {
    print('=== Chat reset started ===');
    print('  Before reset:');
    print('  _selectedImageId: $_selectedImageId');
    print('  _currentImage path: ${_currentImage?.path}');
    print('  _currentImage exists: ${_currentImage?.existsSync()}');
    print('  _selectedImage path: ${_selectedImage?.path}');

    // 立即清除图片引用，不使用microtask
    _isProcessing = false;
    _chatMessages.clear();

    // 释放文件资源
    try {
      if (_currentImage != null && _currentImage!.existsSync()) {
        // 仅记录路径，不实际删除文件，避免可能的权限问题
        print('  清除当前图片: ${_currentImage!.path}');
      }

      if (_selectedImage != null && _selectedImage!.existsSync()) {
        print('  清除选择图片: ${_selectedImage!.path}');
      }
    } catch (e) {
      print('  清除图片文件错误: $e');
    }

    // 清除所有图片相关状态
    _currentImage = null;
    _originalImage = null;
    _selectedImage = null;
    _selectedImageId = null;
    _generatedImageCount = 0;
    _currentResult['text'] = '';
    _currentResult['imageUrl'] = '';
    _currentResult['imageId'] = 0;

    // 输出调试信息
    print('=== After reset ===');
    print('  _selectedImageId: $_selectedImageId');
    print('  _currentImage: $_currentImage');
    print('  _selectedImage: $_selectedImage');
    print('=== Chat reset completed ===');

    // 刷新UI
    notifyListeners();
  }
}
