# 安装和部署说明

本文档提供AI图片生成应用的详细安装和部署指南。

## 1. 环境配置

```bash
# 创建并激活虚拟环境
python3 -m venv /var/www/aiapp/venv
source /var/www/aiapp/venv/bin/activate

# 安装依赖
pip install fastapi uvicorn python-multipart pillow aiohttp pyyaml
```

## 2. 部署应用

以下是完整的部署步骤：

```bash
# 创建应用目录
mkdir -p /var/www/aiapp/{backend,frontend,static,static/generated_images,logs,config}

# 复制文件
cp backend/main.py backend/api.py backend/config.py backend/utils.py /var/www/aiapp/backend/
cp frontend/index.html /var/www/aiapp/frontend/
cp config.yaml /var/www/aiapp/

# 设置权限
chown -R www-data:www-data /var/www/aiapp
chmod -R 755 /var/www/aiapp
chmod -R 777 /var/www/aiapp/static/generated_images
chmod -R 777 /var/www/aiapp/logs
```

## 3. 服务配置文件

### Systemd 服务配置
位置：`/etc/systemd/system/aiapp.service`

```ini
[Unit]
Description=AI Image Generation Application
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/var/www/aiapp/backend
Environment="GOOGLE_API_KEY=your_api_key_here"
ExecStart=/var/www/aiapp/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

### Nginx 配置
位置：`/etc/nginx/conf.d/aiapp.conf`

```nginx
server {
    listen 80;
    server_name your_domain.com;

    location / {
        root /var/www/aiapp/frontend;
        index index.html;
    }

    location /api {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /static {
        alias /var/www/aiapp/static;
    }
}
```

## 4. 常用维护命令

```bash
# 服务管理
systemctl start aiapp    # 启动服务
systemctl stop aiapp     # 停止服务
systemctl restart aiapp  # 重启服务
systemctl status aiapp   # 查看服务状态

# 日志查看
tail -f /var/www/aiapp/logs/app.log  # 查看应用日志
tail -f /var/nginx/error.log         # 查看 Nginx 错误日志

# 文件权限设置
chown -R root:root /var/www/aiapp
chmod -R 755 /var/www/aiapp
chmod -R 777 /var/www/aiapp/static/generated_images

# 清理生成的图片
find /var/www/aiapp/static/generated_images -type f -mtime +7 -delete  # 删除7天前的图片
```

## 5. API 密钥配置

1. 通过环境变量设置（推荐）：
   - 编辑 systemd 服务文件：`sudo nano /etc/systemd/system/aiapp.service`
   - 修改 `Environment` 行：`Environment="GOOGLE_API_KEY=your_new_key_here"`
   - 重新加载配置：`sudo systemctl daemon-reload`
   - 重启服务：`sudo systemctl restart aiapp`

2. 通过配置文件设置：
   - 配置密钥变量名：在 `config.yaml` 中设置 `api.key_env_var` 的值
   - 应用程序将自动从对应的环境变量中读取API密钥

3. 密钥管理最佳实践：
   - 避免在代码或配置文件中直接存储密钥
   - 使用环境变量或安全的密钥管理服务
   - 定期轮换API密钥
   - 限制API密钥的权限和访问范围 