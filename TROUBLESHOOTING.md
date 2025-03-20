# 故障排除

本文档提供AI图片生成应用的常见问题和解决方案。

## 常见问题

### 1. 服务无法启动

#### 症状
- 应用程序无法启动
- 系统日志中出现错误

#### 可能原因和解决方案
- **检查日志**：`journalctl -u aiapp -n 50`
- **检查权限**：确保目录权限正确
- **验证 API 密钥**：确保 API 密钥有效
- **检查模块导入错误**：检查是否安装了所有必要的依赖包

### 2. 模块导入错误

#### 症状
- 应用启动时出现ImportError或ModuleNotFoundError
- 日志中显示缺少模块

#### 可能原因和解决方案
- **确保安装了所有依赖**：
  ```bash
  pip install -r requirements.txt
  ```
- **检查模块路径是否正确**
- **验证Python版本兼容性**

### 3. 图片生成失败

#### 症状
- API返回500错误
- 没有生成图片或生成的图片损坏

#### 可能原因和解决方案
- **检查应用日志**
- **验证存储目录权限**：
  ```bash
  chmod -R 777 /var/www/aiapp/static/generated_images
  ```
- **确认 API 配额未超限**
- **检查utils.py中的图像处理功能是否正常**

### 4. 配置加载失败

#### 症状
- 应用启动时出现配置相关错误
- 日志中显示无法找到或解析配置文件

#### 可能原因和解决方案
- **确认config.yaml文件存在且格式正确**
- **检查config.py中的配置加载逻辑**
- **验证配置文件中的路径设置是否正确**

### 5. 前端无法访问

#### 症状
- 浏览器无法访问前端页面
- 出现404或连接被拒绝错误

#### 可能原因和解决方案
- **检查 Nginx 配置**：
  ```bash
  nginx -t
  ```
- **确认防火墙设置**
- **验证域名解析**

### 6. 502 Bad Gateway

#### 症状
- 访问API时出现502 Bad Gateway错误
- Nginx正常但后端服务无响应

#### 可能原因和解决方案
- **检查 FastAPI 服务是否正在运行**：
  ```bash
  systemctl status aiapp
  ```
- **检查端口是否正确监听**：
  ```bash
  netstat -tulpn | grep 8000
  ```
- **检查日志文件中的错误**：
  ```bash
  tail -f /var/www/aiapp/logs/app.log
  tail -f /var/log/nginx/error.log
  ```

#### 常见原因和解决方案
- **FastAPI 服务未启动**：
  ```bash
  systemctl start aiapp
  ```
- **端口冲突**：检查 8000 端口是否被其他程序占用
- **内存不足**：
  ```bash
  free -m  # 检查内存使用情况
  ```
- **权限问题**：
  ```bash
  # 确保目录权限正确
  chown -R root:root /var/www/aiapp
  chmod -R 755 /var/www/aiapp
  chmod -R 777 /var/www/aiapp/static/generated_images
  ```
- **Nginx 配置问题**：
  ```bash
  # 测试 Nginx 配置
  nginx -t
  # 如果配置正确，重启 Nginx
  systemctl restart nginx
  ```
- **防火墙设置**：
  ```bash
  # 检查防火墙规则
  iptables -L
  # 确保 8000 端口开放
  ufw allow 8000
  ```

#### 临时解决方案
```bash
# 重启所有相关服务
systemctl restart aiapp
systemctl restart nginx
```

## 性能优化建议

### 1. 图片处理优化

- **限制上传图片大小**：在前端增加大小限制
- **配置适当的超时时间**：避免长时间处理导致超时
- **定期清理临时文件**：
  ```bash
  find /var/www/aiapp/static/generated_images -type f -mtime +7 -delete
  ```
- **使用缓存**：对于相同的请求可以使用缓存减少处理时间

### 2. 服务器资源优化

- **监控服务器负载**：
  ```bash
  htop
  ```
- **配置适当的 worker 数量**：在uvicorn配置中调整workers数
- **根据需求调整资源限制**：考虑使用cgroups限制资源使用
- **使用CDN加速静态资源**：将生成的图片放在CDN上加速访问

### 3. 安全建议

1. **API 密钥保护**
   - 不要在代码中硬编码 API 密钥
   - 使用环境变量或配置文件管理密钥
   - 定期轮换 API 密钥

2. **文件权限**
   - 确保配置文件权限为 600
   - 日志文件权限为 644
   - 可执行文件权限为 755

3. **访问控制**
   - 配置适当的防火墙规则
   - 使用 HTTPS 加密传输
   - 考虑添加访问认证

## 日志分析

应用程序日志位于 `/var/www/aiapp/logs/app.log`，包含以下级别信息：

- **DEBUG**: 详细的调试信息
- **INFO**: 正常操作信息
- **WARNING**: 警告信息（不影响操作）
- **ERROR**: 错误信息（影响功能但不致命）
- **CRITICAL**: 严重错误（导致程序崩溃）

### 常见错误和解释

1. `API key is not set`：环境变量中未设置API密钥
2. `No candidates in response`：Gemini API没有返回候选结果
3. `No image data found in response parts`：响应中没有找到图片数据
4. `API request failed with status`：API请求失败，通常包含状态码
5. `Error generating image`：生成图片时出现一般性错误

### 使用日志调试技巧

```bash
# 查看最近100行日志
tail -n 100 /var/www/aiapp/logs/app.log

# 过滤错误日志
grep ERROR /var/www/aiapp/logs/app.log

# 监控实时日志
tail -f /var/www/aiapp/logs/app.log

# 查找特定问题
grep "No image data" /var/www/aiapp/logs/app.log
``` 