import io
import base64
import logging
from PIL import Image, UnidentifiedImageError
from fastapi import HTTPException
from config import CONFIG

logger = logging.getLogger(__name__)

async def process_image(image_data: bytes) -> str:
    """处理图片：调整大小并转换为 base64"""
    try:
        logger.debug(f"开始处理图片，数据大小: {len(image_data) / 1024:.2f}KB")
        
        # 创建字节流并详细日志
        image_stream = io.BytesIO(image_data)
        logger.debug(f"创建字节流: {image_stream}")
        
        # 尝试打开图片
        try:
            img = Image.open(image_stream)
            # 确保文件指针重置，以便可以再次读取
            image_stream.seek(0)
            logger.debug(f"图片已打开，格式: {img.format}, 模式: {img.mode}, 大小: {img.size}")
        except UnidentifiedImageError as e:
            logger.error(f"无法识别图片格式: {e}")
            raise HTTPException(status_code=400, detail="无法识别图片格式，请确保上传有效的图片文件")
        
        # 处理各种颜色模式
        if img.mode not in ['RGB', 'RGBA']:
            logger.debug(f"转换图片模式从 {img.mode} 到 RGB")
            img = img.convert('RGB')
        elif img.mode == 'RGBA':
            # 处理透明背景，将透明部分填充为白色
            logger.debug("处理RGBA图片，转换透明背景为白色")
            background = Image.new('RGB', img.size, (255, 255, 255))
            background.paste(img, mask=img.split()[3])  # 使用alpha通道作为mask
            img = background
            
        # 调整大小，保持比例
        max_size = (CONFIG['image_processing']['max_width'], CONFIG['image_processing']['max_height'])
        img.thumbnail(max_size, Image.Resampling.LANCZOS)
        logger.debug(f"调整图片大小为: {img.size}")
        
        # 保存为JPEG格式
        buffered = io.BytesIO()
        img.save(buffered, format=CONFIG['image_processing']['format'], quality=95)
        logger.debug(f"图片已保存为 {CONFIG['image_processing']['format']} 格式，质量: 95")
        
        # 转换为base64
        img_base64 = base64.b64encode(buffered.getvalue()).decode('utf-8')
        logger.debug(f"图片处理完成，base64长度: {len(img_base64)//1000}K")
        
        return img_base64
    except HTTPException:
        # 直接传递HTTP异常
        raise
    except Exception as e:
        logger.error(f"图片处理失败: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"图片处理失败: {str(e)}") 