# 架构设计

本文档描述AI图片生成应用的架构设计和工作流程。

## 模块结构

后端采用模块化设计，主要分为以下几个模块：

1. **main.py**：应用程序入口点
   - 创建和配置FastAPI应用
   - 注册中间件和路由
   - 启动应用服务器

2. **config.py**：配置管理
   - 加载YAML配置文件
   - 设置日志系统
   - 创建必要的目录结构

3. **api.py**：API路由和处理
   - 定义API端点和路由
   - 处理用户请求
   - 调用Gemini AI API
   - 处理响应数据

4. **utils.py**：工具函数
   - 图片处理和转换
   - 辅助功能实现

这种模块化结构使代码更加清晰、可维护，并且方便进行单元测试和功能扩展。

## 配置文件

项目使用YAML格式的配置文件（config.yaml）来管理所有设置，主要包括以下几个部分：

```yaml
# 目录配置
directories:
  static: "static"
  generated_images: "static/generated_images"
  logs: "logs"

# 日志配置
logging:
  level: "DEBUG"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  file: "logs/app.log"

# API配置
api:
  url: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp-image-generation:generateContent"
  key_env_var: "GOOGLE_API_KEY"

# 图片处理配置
image_processing:
  max_width: 1024
  max_height: 768
  format: "JPEG"

# 生成配置
generation:
  temperature: 0.9
  top_p: 1
  top_k: 32
  max_output_tokens: 2048
  response_modalities: ["Text", "Image"]

# 服务器配置
server:
  host: "0.0.0.0"
  port: 8000
  cors:
    allow_origins: ["*", "http://localhost:8080"]
    allow_credentials: true
    allow_methods: ["*", "GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers: ["*", "Content-Type", "Authorization", "X-Requested-With"]
```

## 目录结构

```
/var/www/aiapp/
├── backend/
│   ├── main.py          # 应用程序入口点
│   ├── config.py        # 配置加载和环境设置
│   ├── api.py           # API路由和请求处理
│   ├── utils.py         # 工具函数和图像处理
│   └── logs/            # 后端日志目录
├── frontend/
│   └── index.html       # 前端界面
├── static/
│   └── generated_images/ # 生成的图片存储目录
├── config/              # 配置文件目录
├── venv/                # Python 虚拟环境
└── logs/                # 应用日志目录
```

## 工作流程

### 1. 纯文本生成图片流程

1. 用户发送含有文本提示的请求到`/api/generate_from_text`
2. API接收请求并验证提示内容
3. 构建请求数据并调用Gemini API
4. 处理Gemini的响应：
   - 提取生成的图片数据
   - 保存图片到指定目录
   - 生成图片URL
5. 返回成功响应与图片URL给用户

### 2. 图片编辑流程

1. 用户上传图片和编辑指令到`/api/generate`
2. API接收文件和提示文本
3. 处理上传的图片：
   - 调整大小
   - 格式转换
   - 编码为base64
4. 构建请求数据并调用Gemini API
5. 处理Gemini的响应：
   - 提取生成的图片数据
   - 保存图片到指定目录
   - 生成图片URL
6. 返回成功响应与图片URL给用户

## 关键技术实现

### 图片处理

图片处理逻辑主要在`utils.py`中实现，包括：

```python
async def process_image(image_data: bytes) -> str:
    """处理图片：调整大小并转换为 base64"""
    try:
        img = Image.open(io.BytesIO(image_data))
        if img.mode != 'RGB':
            img = img.convert('RGB')
        max_size = (CONFIG['image_processing']['max_width'], CONFIG['image_processing']['max_height'])
        img.thumbnail(max_size, Image.Resampling.LANCZOS)
        
        buffered = io.BytesIO()
        img.save(buffered, format=CONFIG['image_processing']['format'])
        img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')
        
        return img_base64
    except Exception as e:
        logger.error(f"图片处理失败: {str(e)}")
        raise HTTPException(status_code=500, detail=f"图片处理失败: {str(e)}")
```

### API请求处理

请求处理主要在`api.py`中实现，包括：

1. 接收请求
2. 验证参数
3. 构建API请求
4. 发送请求到Gemini
5. 处理响应
6. 保存生成的图片
7. 返回结果 