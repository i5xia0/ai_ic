import io
import base64
import logging
from PIL import Image
from fastapi import HTTPException
from config import CONFIG

logger = logging.getLogger(__name__)

async def process_image(image_data: bytes) -> str:
    """处理图片：调整大小并转换为 base64"""
    try:
        img = Image.open(io.BytesIO(image_data))
        if img.mode != 'RGB':
            img = img.convert('RGB')
        max_size = (CONFIG['image_processing']['max_width'], CONFIG['image_processing']['max_height'])
        img.thumbnail(max_size, Image.Resampling.LANCZOS)
        logger.debug(f"调整图片大小为: {img.size}")
        
        buffered = io.BytesIO()
        img.save(buffered, format=CONFIG['image_processing']['format'])
        img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')
        logger.debug("图片处理完成")
        
        return img_base64
    except Exception as e:
        logger.error(f"图片处理失败: {str(e)}")
        raise HTTPException(status_code=500, detail=f"图片处理失败: {str(e)}") 