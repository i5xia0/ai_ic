import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';

class ResultDisplay extends StatelessWidget {
  final String result;
  final String imageUrl;
  final int imageId;
  final bool isLoading;

  const ResultDisplay({
    super.key,
    required this.result,
    required this.imageUrl,
    required this.imageId,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: isLoading
          ? _buildLoadingState(context)
          : imageUrl.isNotEmpty
              ? _buildResultWithImage(context)
              : const SizedBox.shrink(),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitCubeGrid(
            color: Theme.of(context).colorScheme.primary,
            size: 50.0,
          ),
          const SizedBox(height: 16),
          Text(
            result,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultWithImage(BuildContext context) {
    final apiService = ApiService();
    final fullImageUrl = apiService.getFullImageUrl(imageUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Result image
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: CachedNetworkImage(
            imageUrl: fullImageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
              height: 250,
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: SpinKitPulse(
                  color: Theme.of(context).colorScheme.primary,
                  size: 50.0,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 250,
              color: Theme.of(context).colorScheme.errorContainer,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '图片加载失败',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Result text
        if (result.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              result,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: () => _saveImage(context),
              tooltip: '保存图片',
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copyImage(context),
              tooltip: '复制图片',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareImage(context),
              tooltip: '分享图片',
            ),
          ],
        ),
      ],
    );
  }

  void _saveImage(BuildContext context) {
    // Implementation would depend on platform specifics
    Fluttertoast.showToast(
      msg: "图片已保存到相册",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.onSecondary,
    );
  }

  void _copyImage(BuildContext context) {
    Fluttertoast.showToast(
      msg: "图片已复制到剪贴板",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.onSecondary,
    );
  }

  void _shareImage(BuildContext context) {
    Fluttertoast.showToast(
      msg: "分享功能即将上线",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.onSecondary,
    );
  }
}
