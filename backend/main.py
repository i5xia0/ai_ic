import logging
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

from config import CONFIG, setup_logging, setup_directories
from api import router

# 设置日志
logger = setup_logging()

# 创建必要的目录
setup_directories()
logger.info("成功创建必要的目录")

# 创建FastAPI应用
app = FastAPI()

# 配置 CORS - 确保允许来自前端的请求
app.add_middleware(
    CORSMiddleware,
    allow_origins=CONFIG['server']['cors']['allow_origins'],
    allow_credentials=CONFIG['server']['cors']['allow_credentials'],
    allow_methods=CONFIG['server']['cors']['allow_methods'],
    allow_headers=CONFIG['server']['cors']['allow_headers'],
    expose_headers=["Content-Disposition"],
)

# 挂载静态文件目录
app.mount("/static", StaticFiles(directory=CONFIG['directories']['static']), name="static")

# 注册API路由
app.include_router(router)

if __name__ == "__main__":
    uvicorn.run(app, host=CONFIG['server']['host'], port=CONFIG['server']['port']) 