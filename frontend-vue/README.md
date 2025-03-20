# AI 图片生成器

基于Vue 3和Element Plus构建的AI图片生成应用前端界面。

## 功能特点

- 文本生成图片
- 图片上传和编辑
- 聊天式交互界面
- 历史对话记录
- 连续编辑模式
- 一键下载生成图片

## 技术栈

- Vue 3 (Composition API + Script Setup)
- Element Plus
- Axios
- SCSS

## 开发指南

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

### 构建生产版本

```bash
npm run build
```

### 预览生产构建

```bash
npm run preview
```

## 项目结构

- `/src/components` - 组件文件
- `/src/services` - API服务和工具函数
- `/src/assets` - 样式文件和静态资源
- `/src/views` - 页面级组件

## 配置

可在`/src/services/apiService.js`中配置API端点。默认情况下，应用使用本地代理转发请求到后端服务器。

## 环境配置

项目使用Vite的环境变量系统进行配置管理，包含以下文件：

- `.env` - 基础配置，所有环境共用
- `.env.development` - 开发环境配置
- `.env.production` - 生产环境配置
- `.env.local` - 本地开发配置（不提交到git）

你可以创建`.env.local`文件来覆盖默认配置，例如：

```
# .env.local
VITE_API_BASE_URL=http://localhost:9000
```

注意：只有以`VITE_`开头的变量才会暴露给前端代码。

## 如何启动

### 使用run.sh脚本启动（推荐）

项目根目录下的`run.sh`脚本可以自动启动前后端服务：

```bash
# 给脚本添加执行权限
chmod +x run.sh

# 启动应用（可选：传入Google API密钥）
./run.sh YOUR_API_KEY

# 或者不传入API密钥（脚本会提示输入）
./run.sh
```

启动后：
- 前端界面：http://localhost:8080
- 后端API：http://localhost:8000

使用Ctrl+C可以关闭应用。

### 独立启动前端（开发模式）

如果只需要启动前端（后端已运行或使用模拟数据），可以使用：