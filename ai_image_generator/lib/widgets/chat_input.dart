import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatefulWidget {
  final bool disabled;
  final bool hasImage;
  final File? currentImage;
  final Function(String) onSendMessage;
  final Function(File?) onFileSelected;

  const ChatInput({
    super.key,
    this.disabled = false,
    this.hasImage = false,
    this.currentImage,
    required this.onSendMessage,
    required this.onFileSelected,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Add a unique key for each image to force UI updates
  Key _imageContainerKey = UniqueKey();

  @override
  void didUpdateWidget(ChatInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Generate a new key when the image changes to force widget rebuild
    if (oldWidget.currentImage?.path != widget.currentImage?.path ||
        oldWidget.hasImage != widget.hasImage) {
      _imageContainerKey = UniqueKey();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        widget.onFileSelected(file);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _controller.clear();
    }
  }

  void _clearImage() {
    widget.onFileSelected(null);
  }

  // Check if the image file exists and is valid
  bool _isImageValid() {
    if (widget.currentImage == null) return false;

    try {
      return widget.currentImage!.existsSync() &&
          widget.currentImage!.lengthSync() > 0;
    } catch (e) {
      print('验证图片有效性错误: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        'ChatInput重建: hasImage=${widget.hasImage}, imageValid=${_isImageValid()}, path=${widget.currentImage?.path}');

    // 使用本地变量存储验证结果
    final bool isImageValid = _isImageValid();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image selection indicator - only show if image is valid
          if (widget.hasImage && isImageValid)
            Container(
              key: _imageContainerKey,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                children: [
                  // 图片缩略图
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      widget.currentImage!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Handle image loading errors
                        print('Error loading thumbnail: $error');
                        return Container(
                          width: 40,
                          height: 40,
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: const Icon(Icons.broken_image, size: 20),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '图片已选择',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    onPressed: widget.disabled ? null : _clearImage,
                    tooltip: '清除图片',
                  ),
                ],
              ),
            ),

          // Input field and buttons
          Row(
            children: [
              // Image picker button
              IconButton(
                icon: Icon(
                  Icons.add_photo_alternate,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: widget.disabled
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _buildImagePickerMenu(),
                        );
                      },
                tooltip: '添加图片',
              ),

              // Text field
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.disabled,
                  decoration: InputDecoration(
                    hintText:
                        widget.hasImage ? '描述您想要如何修改图片...' : '描述您想要创建的图片...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 3,
                  onSubmitted: (value) {
                    if (!widget.disabled) {
                      _sendMessage();
                    }
                  },
                ),
              ),

              // Send button
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: widget.disabled ? null : _sendMessage,
                tooltip: '发送',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.photo_camera,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('拍照'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.photo_library,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('从相册选择'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
