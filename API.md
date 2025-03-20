# API接口文档

本文档详细说明AI图片生成应用提供的API接口。

## 接口列表

应用程序提供以下两个主要API接口：

### 1. 纯文本生成图片

- **URL**: `/api/generate_from_text`
- **方法**: POST
- **功能**: 根据文本描述生成图片
- **请求体**:
  ```json
  {
    "prompt": "一只戴着太空头盔的猫咪在月球表面漫步，背景是璀璨的星空"
  }
  ```
- **响应**:
  ```json
  {
    "success": true,
    "result": "生成的文本描述",
    "image_url": "/static/generated_images/generated_1234567890.jpg"
  }
  ```
- **错误**: 
  - 400: 未提供提示文本
  - 500: API请求失败或图片生成错误

### 2. 上传图片并编辑

- **URL**: `/api/generate`
- **方法**: POST
- **功能**: 上传图片并根据提示进行编辑生成新图片
- **请求体**: multipart/form-data
  - `file`: 图片文件
  - `prompt`: 编辑指令文本
- **响应**:
  ```json
  {
    "success": true,
    "result": "生成的文本描述",
    "image_url": "/static/generated_images/generated_1234567890.jpg"
  }
  ```
- **错误**:
  - 400: 未提供图片或编辑指令
  - 500: 图片处理失败或API请求错误

## 使用示例

### 使用cURL发送纯文本生成请求

```bash
curl -X POST "http://localhost:8000/api/generate_from_text" \
     -H "Content-Type: application/json" \
     -d '{"prompt": "梵高风格的星空下的城市"}'
```

### 使用cURL上传图片并编辑

```bash
curl -X POST "http://localhost:8000/api/generate" \
     -F "file=@/path/to/your/image.jpg" \
     -F "prompt=将图片转换为水彩画风格"
```

### 使用JavaScript调用API

```javascript
// 纯文本生成图片
async function generateFromText(prompt) {
  const response = await fetch('/api/generate_from_text', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ prompt }),
  });
  return await response.json();
}

// 上传图片并编辑
async function generateFromImage(imageFile, prompt) {
  const formData = new FormData();
  formData.append('file', imageFile);
  formData.append('prompt', prompt);
  
  const response = await fetch('/api/generate', {
    method: 'POST',
    body: formData,
  });
  return await response.json();
}
```

## 接口使用说明

1. **对于纯文本生成**:
   - 直接发送POST请求到`/api/generate_from_text`，包含详细的场景描述
   - 建议在提示中添加风格、视角等细节以提升生成效果

2. **对于图片编辑**:
   - 通过表单上传图片文件并提供编辑指令
   - 图片会自动处理为适当的大小和格式
   - 编辑指令可以指定样式变化、内容添加/删除等

## 提示技巧

为了获得最佳的生成结果，推荐在提示中包含以下元素：

1. **明确的主体描述**：清晰描述你想要生成的主要对象或场景
2. **环境和背景**：提供环境信息可以增加生成图片的情境感
3. **艺术风格**：指定具体的艺术风格（如油画、水彩、素描等）
4. **光线和氛围**：描述光线条件和整体氛围
5. **构图建议**：可以提供关于构图的建议（如特写、全景等）

### 示例提示

```
"一只橙色的猫咪坐在窗台上，窗外是雨天的城市景观，室内有温暖的黄色灯光照射，整体呈现莫奈印象派风格的柔和画面，焦点在猫咪身上，背景略微模糊"
``` 