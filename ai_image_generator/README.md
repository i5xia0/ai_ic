# AI 图片创作助手

一个基于Flutter开发的智能图片生成与编辑应用，提供文本生成图片和图片编辑功能。

## 项目介绍

AI图片创作助手是一款直观易用的应用，让用户能够通过简单的文本描述创建图片，或者修改已有图片。应用采用聊天式界面，便于与AI进行自然的交互，实现连续的图片创作和迭代。

## 主要功能

### 图片生成
- **文本到图片**：输入文本描述，AI将根据描述生成相应图片
- **图片编辑**：上传现有图片并输入修改描述，AI将按要求修改图片

### 用户界面
- **聊天界面**：采用熟悉的聊天形式与AI交互
- **图片缩略图**：显示当前选中的图片作为编辑对象
- **历史记录**：保存所有生成的图片和对话历史
- **混合消息**：支持文本和图片混合显示的消息格式

### 图片管理
- **图片选择**：从聊天历史中选择任意图片进行进一步编辑
- **重置功能**：一键开始新的创作会话

## 技术实现

- **前端框架**：Flutter跨平台框架
- **状态管理**：Provider模式
- **图片处理**：处理本地图片和网络图片
- **API通信**：与AI图片生成服务器进行通信

## 安装指南

### 环境要求
- Flutter SDK 3.0.0+
- Dart 3.0.0+
- 支持Android 6.0+、iOS 12.0+和macOS 10.15+

### 安装步骤
1. 克隆代码库
   ```
   git clone [仓库地址]
   cd ai_image_generator
   ```

2. 安装依赖
   ```
   flutter pub get
   ```

3. 运行应用
   ```
   flutter run -d [设备ID]
   ```

### 打包命令

#### Android 打包
```
# 生成APK文件
flutter build apk --release

# 生成Android App Bundle (推荐用于Google Play发布)
flutter build appbundle --release

# 打包指定目标平台
flutter build apk --release --target-platform=android-arm64
```

生成的APK文件位于 `build/app/outputs/flutter-apk/app-release.apk`

#### iOS 打包
```
# 生成iOS Release版本
flutter build ios --release

# 生成iOS Archive文件 (需要在macOS上运行)
# 1. 首先使用Xcode打开项目
cd ios
xed .

# 2. 在Xcode中选择Product > Archive来创建归档文件
# 3. 在归档管理器中选择"Distribute App"进行发布
```

**注意事项:**
- iOS打包需要有效的Apple开发者账号
- 打包前请确保已正确配置应用签名和证书

## 使用指南

### 创建新图片
1. 在文本输入框中描述您想要创建的图片
2. 点击发送按钮，等待AI生成图片
3. 查看生成结果

### 修改现有图片
1. 点击照片图标上传本地图片，或从历史记录中选择图片
2. 在文本输入框中描述您想要如何修改图片
3. 发送请求并等待AI修改结果

### 开始新聊天
- 点击右上角的"+"图标开始一个全新的对话

## 项目结构

- **lib/models/**: 数据模型
- **lib/providers/**: 状态管理
- **lib/screens/**: 应用界面
- **lib/services/**: API服务
- **lib/widgets/**: 可复用组件

## 贡献指南

欢迎贡献代码改进此项目！请遵循以下步骤：
1. Fork项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建Pull Request

## 许可证

[待定] - 请指定适当的许可证
