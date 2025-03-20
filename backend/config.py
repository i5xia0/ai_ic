import os
import yaml
import logging
import sys

def load_config():
    """加载配置文件"""
    config_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "config.yaml")
    with open(config_path, 'r') as config_file:
        return yaml.safe_load(config_file)

# 加载配置
CONFIG = load_config()

# 配置日志
def setup_logging():
    """设置日志记录"""
    logging.basicConfig(
        level=getattr(logging, CONFIG['logging']['level']),
        format=CONFIG['logging']['format'],
        handlers=[
            logging.FileHandler(CONFIG['logging']['file'], mode='a', encoding='utf-8'),
            logging.StreamHandler(sys.stdout)
        ]
    )
    logger = logging.getLogger(__name__)
    
    # 创建日志目录
    os.makedirs(CONFIG['directories']['logs'], exist_ok=True)
    
    return logger

# 创建目录
def setup_directories():
    """创建必要的目录"""
    for dir_path in [
        CONFIG['directories']['static'],
        CONFIG['directories']['generated_images']
    ]:
        os.makedirs(dir_path, exist_ok=True) 