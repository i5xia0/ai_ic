#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查依赖
check_dependencies() {
    print_info "检查依赖..."
    
    # 检查Python
    if ! command -v python &> /dev/null; then
        print_error "未找到Python。请安装Python 3.6+"
        exit 1
    fi
    
    # 检查pip
    if ! command -v pip &> /dev/null; then
        print_error "未找到pip。请安装pip"
        exit 1
    fi
    
    # 检查Node.js
    if ! command -v node &> /dev/null; then
        print_error "未找到Node.js。请安装Node.js 14+"
        exit 1
    fi
    
    # 检查npm
    if ! command -v npm &> /dev/null; then
        print_error "未找到npm。请安装npm"
        exit 1
    fi
    
    # 安装Python依赖
    print_info "安装Python依赖..."
    pip install fastapi uvicorn python-multipart pillow aiohttp google-generativeai pyyaml
    
    # 安装前端依赖
    print_info "安装前端依赖..."
    cd frontend-vue && npm install && cd ..
    
    print_success "依赖检查完成"
}

# 创建必要的目录
create_directories() {
    print_info "创建必要的目录..."
    
    mkdir -p static/generated_images
    mkdir -p logs
    
    print_success "目录创建完成"
}

# 获取API密钥
get_api_key() {
    # 检查是否通过命令行参数提供了API密钥
    if [ -n "$1" ]; then
        GOOGLE_API_KEY=$1
    else
        # 检查环境变量中是否已有API密钥
        if [ -z "$GOOGLE_API_KEY" ]; then
            # 提示用户输入API密钥
            read -p "请输入Google API密钥: " GOOGLE_API_KEY
            
            if [ -z "$GOOGLE_API_KEY" ]; then
                print_error "未提供API密钥，程序无法继续"
                exit 1
            fi
        else
            print_info "使用环境变量中的API密钥"
        fi
    fi
    
    # 导出环境变量
    export GOOGLE_API_KEY=$GOOGLE_API_KEY
    print_success "API密钥设置完成"
}

# 启动后端
start_backend() {
    print_info "启动后端服务器..."
    
    # 使用uvicorn启动后端，并将输出重定向到日志文件
    uvicorn backend.main:app --host 0.0.0.0 --port 8000 > logs/backend.log 2>&1 &
    
    # 保存后端进程ID
    BACKEND_PID=$!
    echo $BACKEND_PID > .backend.pid
    
    print_success "后端服务器已启动，PID: $BACKEND_PID"
    print_info "后端日志: logs/backend.log"
}

# 启动前端
start_frontend() {
    print_info "启动前端服务器..."
    
    # 切换到前端Vue目录并启动开发服务器
    cd frontend-vue && npm run dev > ../logs/frontend.log 2>&1 &
    
    # 保存前端进程ID
    FRONTEND_PID=$!
    echo $FRONTEND_PID > ../.frontend.pid
    cd ..
    
    print_success "前端服务器已启动，PID: $FRONTEND_PID"
    print_info "前端日志: logs/frontend.log"
}

# 清理函数
cleanup() {
    print_info "正在关闭服务器..."
    
    # 如果存在后端PID文件，则杀死后端进程
    if [ -f .backend.pid ]; then
        BACKEND_PID=$(cat .backend.pid)
        kill $BACKEND_PID 2>/dev/null
        rm .backend.pid
        print_success "后端服务器已关闭"
    fi
    
    # 如果存在前端PID文件，则杀死前端进程
    if [ -f .frontend.pid ]; then
        FRONTEND_PID=$(cat .frontend.pid)
        kill $FRONTEND_PID 2>/dev/null
        rm .frontend.pid
        print_success "前端服务器已关闭"
    fi
    
    print_success "清理完成"
    exit 0
}

# 设置清理钩子
trap cleanup SIGINT SIGTERM

# 主函数
main() {
    print_info "启动AI图片生成应用..."
    
    check_dependencies
    create_directories
    get_api_key $1
    start_backend
    start_frontend
    
    # 等待后端和前端启动
    sleep 3
    
    print_success "应用已启动!"
    print_info "前端界面: http://localhost:8080"
    print_info "后端API: http://localhost:8000"
    print_info "按 Ctrl+C 停止应用"
    
    # 等待直到用户按下Ctrl+C
    wait
}

# 执行主函数，并传入第一个命令行参数（如果有的话）
main $1 