import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/image_data.dart';
import '../services/api_service.dart';

class ChatHistory extends StatefulWidget {
  final List<ChatMessage> messages;
  final String? selectedImageId;
  final Function(ImageData) onSelectImage;

  const ChatHistory({
    super.key,
    required this.messages,
    this.selectedImageId,
    required this.onSelectImage,
  });

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    // 初始化后延迟一帧添加滚动监听，避免构建过程中滚动
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // 添加滚动监听，显示/隐藏回到底部按钮
    _scrollController.addListener(_scrollListener);
  }

  // 监听滚动位置变化
  void _scrollListener() {
    // 如果滚动位置距离底部超过500像素，显示按钮
    final bool shouldShowButton = _scrollController.hasClients &&
        (_scrollController.position.maxScrollExtent -
                _scrollController.position.pixels >
            500);

    if (shouldShowButton != _showScrollButton) {
      setState(() {
        _showScrollButton = shouldShowButton;
      });
    }
  }

  @override
  void didUpdateWidget(ChatHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当消息列表变化时自动滚动到底部
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the selectedImageId refers to an image that exists in the current messages
    bool isSelectedImageValid = false;
    if (widget.selectedImageId != null) {
      isSelectedImageValid = widget.messages.any((message) =>
          message.imageId == widget.selectedImageId &&
          message.imageUrl != null);
    }

    // Use the validated selectedImageId
    final effectiveSelectedImageId =
        isSelectedImageValid ? widget.selectedImageId : null;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: widget.messages.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12.0),
                  itemCount: widget.messages.length,
                  itemBuilder: (context, index) {
                    final message = widget.messages[index];
                    return _buildMessageItem(
                        context, message, effectiveSelectedImageId);
                  },
                ),
        ),

        // 滚动到底部按钮
        if (_showScrollButton)
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: FloatingActionButton.small(
              onPressed: _scrollToBottom,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.arrow_downward,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标标题
            Icon(
              Icons.tips_and_updates,
              size: 40,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'AI 图片创作助手',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(
              '通过简单的文字描述，创建精美图片',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),

            const SizedBox(height: 16),

            // 功能介绍部分
            _buildFeatureSection(context),

            const SizedBox(height: 16),

            // 使用技巧部分
            _buildTipsSection(context),

            const SizedBox(height: 12),

            // 底部提示
            Text(
              '输入提示词或上传图片开始创作',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),

            // 额外空间确保底部内容可见
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // 功能介绍部分
  Widget _buildFeatureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text(
            '主要功能',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildFeatureItem(
                context,
                Icons.text_fields,
                '文本生成',
                '输入提示词，AI创建图片',
              ),
              Divider(
                  height: 1,
                  indent: 48,
                  color: Theme.of(context).colorScheme.outlineVariant),
              _buildFeatureItem(
                context,
                Icons.image_search,
                '图片编辑',
                '上传图片并添加描述，AI根据指令修改',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 使用技巧部分
  Widget _buildTipsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Text(
            '使用技巧',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildTipItem(
                context,
                '提供场景描述、风格、颜色等细节，获得更精准结果',
              ),
              Divider(
                  height: 1,
                  indent: 48,
                  color: Theme.of(context).colorScheme.outlineVariant),
              _buildTipItem(
                context,
                '上传图片后，描述修改需求，如"把背景改成海滩"',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 功能项目
  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 技巧项目
  Widget _buildTipItem(BuildContext context, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ChatMessage message,
      String? effectiveSelectedImageId) {
    final bool isUser = message.type == MessageType.user;
    final bool hasImage =
        message.imageUrl != null && message.imageUrl!.isNotEmpty;

    // 用户消息特殊处理：如果既有文本又有图片，则作为图文混合消息显示
    if (isUser && hasImage && message.content.isNotEmpty) {
      final apiService = ApiService();
      final isLocalAsset = message.imageUrl!.startsWith('assets/');
      final String imageUrl = isLocalAsset
          ? message.imageUrl!
          : apiService.getFullImageUrl(message.imageUrl!);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 消息内容（图文混合）
            Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 图片内容
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: _buildImageContent(
                        context, message, isLocalAsset, imageUrl),
                  ),

                  // 文本说明
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),

            // 用户头像
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    // 其他消息类型保持原有布局
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // For system messages, avatar on the left
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                Icons.assistant,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Message Content
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message text
                if (message.content.isNotEmpty)
                  message.isLoading
                      ? _buildLoadingIndicator()
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.content,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),

                // Message image
                if (hasImage) ...[
                  const SizedBox(height: 8),
                  _buildMessageImage(
                      context, message, effectiveSelectedImageId),
                ],
              ],
            ),
          ),

          // For user messages, avatar on the right
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 20,
      width: 100,
      child: LinearProgressIndicator(),
    );
  }

  Widget _buildMessageImage(BuildContext context, ChatMessage message,
      String? effectiveSelectedImageId) {
    final apiService = ApiService();
    final isUser = message.type == MessageType.user;
    final isLocalAsset = message.imageUrl!.startsWith('assets/');
    final String imageUrl = isLocalAsset
        ? message.imageUrl!
        : apiService.getFullImageUrl(message.imageUrl!);

    // 用户消息的图片，使用简洁样式
    if (isUser) {
      return Container(
        width: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图片显示
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  _buildImageContent(context, message, isLocalAsset, imageUrl),
            ),
          ],
        ),
      );
    }

    // 系统/AI消息的图片，保留选择功能
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: effectiveSelectedImageId == message.imageId
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: effectiveSelectedImageId == message.imageId
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              )
            : Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1.0,
              ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图片显示
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildImageContent(
                    context, message, isLocalAsset, imageUrl),
              ),

              // 操作按钮区域
              Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 选择按钮
                    _buildActionButton(
                      onPressed: () {
                        if (message.imageId != null) {
                          final apiService = ApiService();
                          print('选择图片开始:');
                          print('  ID: ${message.imageId}');
                          print('  原始URL: ${message.imageUrl}');

                          // 确保URL是绝对路径
                          String imageFullUrl = imageUrl;
                          if (!imageFullUrl.startsWith('http') &&
                              !isLocalAsset) {
                            imageFullUrl =
                                apiService.getFullImageUrl(message.imageUrl!);
                            print('  已转换为完整URL: $imageFullUrl');
                          }

                          final imageData = ImageData(
                            url: message.imageUrl!,
                            fullUrl: imageFullUrl,
                            id: message.imageId!.toString(),
                          );

                          print(
                              '  传递的ImageData: url=${imageData.url}, fullUrl=${imageData.fullUrl}, id=${imageData.id}');
                          widget.onSelectImage(imageData);
                        } else {
                          print('无法选择图片: imageId为空');
                        }
                      },
                      icon: Icons.edit,
                      tooltip: '选择编辑',
                    ),

                    // 下载按钮
                    _buildActionButton(
                      onPressed: () async {
                        // 获取当前上下文
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final currentTheme = Theme.of(context);

                        // 显示下载中提示
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('正在下载图片...'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        try {
                          // 下载图片
                          var response = await http.get(Uri.parse(imageUrl));

                          // 创建临时目录
                          final directory = await getTemporaryDirectory();
                          final imagePath =
                              '${directory.path}/ai_image_${DateTime.now().millisecondsSinceEpoch}.png';

                          // 保存图片到临时目录
                          final file = File(imagePath);
                          await file.writeAsBytes(response.bodyBytes);

                          // 保存成功提示
                          if (context.mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('图片已保存到: $imagePath'),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          // 错误提示
                          if (context.mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('下载失败: $e'),
                                backgroundColor: currentTheme.colorScheme.error,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      icon: Icons.download,
                      tooltip: '下载',
                    ),

                    // 分享按钮
                    _buildActionButton(
                      onPressed: () async {
                        // 获取当前上下文
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final currentTheme = Theme.of(context);

                        // 显示分享中提示
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('准备分享图片...'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        try {
                          // 下载图片
                          var response = await http.get(Uri.parse(imageUrl));

                          // 创建临时目录
                          final directory = await getTemporaryDirectory();
                          final imagePath =
                              '${directory.path}/ai_image_${DateTime.now().millisecondsSinceEpoch}.png';

                          // 保存图片到临时目录
                          final file = File(imagePath);
                          await file.writeAsBytes(response.bodyBytes);

                          // 分享图片
                          await Share.shareXFiles(
                            [XFile(imagePath)],
                            text: 'AI生成的图片',
                          );
                        } catch (e) {
                          // 错误提示
                          if (context.mounted) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('分享失败: $e'),
                                backgroundColor: currentTheme.colorScheme.error,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      icon: Icons.share,
                      tooltip: '分享',
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 当图片被选中时，显示选中标记
          if (effectiveSelectedImageId == message.imageId)
            Positioned(
              right: 10,
              bottom: 40,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String tooltip,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 14,
        color: Colors.white,
      ),
      tooltip: tooltip,
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
      ),
      padding: EdgeInsets.zero,
      iconSize: 14,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // 构建图片内容，适用于所有图片类型
  Widget _buildImageContent(BuildContext context, ChatMessage message,
      bool isLocalAsset, String imageUrl) {
    // 本地资源图片
    if (isLocalAsset) {
      return Image.asset(
        message.imageUrl!,
        height: 140,
        fit: BoxFit.cover,
      );
    }

    // 本地文件图片
    if (message.imageUrl!.startsWith('/')) {
      try {
        final file = File(message.imageUrl!);
        if (file.existsSync()) {
          return Image.file(
            file,
            height: 140,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('本地文件加载失败: $error');
              return _buildErrorWidget(context);
            },
          );
        }
      } catch (e) {
        print('本地文件访问错误: $e');
      }
    }

    // 远程网络图片
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 140,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 140,
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) {
        print('远程图片加载失败: $url - $error');
        return _buildErrorWidget(context);
      },
    );
  }

  // 构建错误提示Widget
  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      height: 140,
      color: Theme.of(context).colorScheme.errorContainer,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error),
            const SizedBox(height: 4),
            Text(
              '图片加载失败',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
