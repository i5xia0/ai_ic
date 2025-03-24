import 'package:flutter/material.dart';

class UsageTips extends StatelessWidget {
  const UsageTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '使用技巧',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          _buildTipItem(
            context,
            '提示词技巧：提供具体的描述，如场景、风格、颜色、光照等细节，获得更精准的结果',
          ),
          const SizedBox(height: 8),
          _buildTipItem(
            context,
            '图片编辑：上传图片后，描述您希望如何修改，比如"把背景改成黄色"、"增加一个帽子"等',
          ),
          const SizedBox(height: 8),
          _buildTipItem(
            context,
            '连续编辑：开启连续编辑模式，每次生成的图片会自动用于下一次编辑，方便逐步完善图片',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String tip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lightbulb_outline,
          size: 20,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tip,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
          ),
        ),
      ],
    );
  }
}
