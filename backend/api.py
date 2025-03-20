import os
import time
import json
import base64
import logging
import aiohttp
import ssl
from fastapi import APIRouter, UploadFile, HTTPException, Form
from fastapi.staticfiles import StaticFiles
import google.generativeai as genai

from config import CONFIG
from utils import process_image

# 获取日志记录器
logger = logging.getLogger(__name__)

# 创建路由器
router = APIRouter()

# 创建SSL上下文，忽略证书验证
ssl_context = ssl.create_default_context()
ssl_context.check_hostname = False
ssl_context.verify_mode = ssl.CERT_NONE

# 获取 API 密钥并配置
GOOGLE_API_KEY = os.getenv(CONFIG['api']['key_env_var'])
if not GOOGLE_API_KEY:
    logger.error(f"{CONFIG['api']['key_env_var']} environment variable is not set")
    raise ValueError(f"{CONFIG['api']['key_env_var']} environment variable is not set")

# 配置 Google API
genai.configure(api_key=GOOGLE_API_KEY)
logger.info("API key loaded and configured successfully")

@router.post("/api/generate_from_text")
async def generate_from_text(request: dict):
    try:
        logger.info("Starting generate_from_text endpoint")
        prompt = request.get("prompt")
        if not prompt:
            logger.error("No prompt provided")
            raise HTTPException(status_code=400, detail="Prompt is required")

        logger.info(f"Generating image from text prompt: {prompt}")

        api_url = CONFIG['api']['url']
        
        request_data = {
            "contents": [{
                "parts":[
                    {"text": prompt}
                ]
            }],
            "generationConfig": {
                "temperature": CONFIG['generation']['temperature'],
                "topP": CONFIG['generation']['top_p'],
                "topK": CONFIG['generation']['top_k'],
                "maxOutputTokens": CONFIG['generation']['max_output_tokens'],
                "responseModalities": CONFIG['generation']['response_modalities']
            }
        }

        headers = {
            "Content-Type": "application/json"
        }
        
        # 使用HTTP会话发送请求，禁用SSL验证
        async with aiohttp.ClientSession(connector=aiohttp.TCPConnector(ssl=ssl_context)) as session:
            full_url = f"{api_url}?key={GOOGLE_API_KEY}"
            async with session.post(
                full_url,
                json=request_data,
                headers=headers,
                timeout=30
            ) as response:
                response_text = await response.text()
                logger.debug(f"API Response: {response_text}")
                
                if response.status != 200:
                    logger.error(f"API request failed with status {response.status}: {response_text}")
                    raise HTTPException(status_code=response.status, detail=f"API request failed: {response_text}")
                
                return await process_response(response_text)

    except Exception as e:
        logger.error(f"Error generating image from text: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/api/generate")
async def generate_image(file: UploadFile, prompt: str = Form(...)):
    try:
        content_type = file.content_type
        file_content = await file.read()
        file_size = len(file_content) / 1024
        
        logger.info(f"收到新的图片生成请求 - 文件名: {file.filename}, 大小: {file_size:.2f}KB")
        
        img_base64 = await process_image(file_content)
        
        api_url = CONFIG['api']['url']
        
        request_data = {
            "contents": [{
                "parts":[
                    {"text": prompt},
                    {
                        "inline_data": {
                            "mime_type": "image/jpeg",
                            "data": img_base64
                        }
                    }
                ]
            }],
            "generationConfig": {
                "temperature": CONFIG['generation']['temperature'],
                "topP": CONFIG['generation']['top_p'],
                "topK": CONFIG['generation']['top_k'],
                "maxOutputTokens": CONFIG['generation']['max_output_tokens'],
                "responseModalities": CONFIG['generation']['response_modalities']
            }
        }
        
        headers = {"Content-Type": "application/json"}
        
        # 使用HTTP会话发送请求，禁用SSL验证
        async with aiohttp.ClientSession(connector=aiohttp.TCPConnector(ssl=ssl_context)) as session:
            full_url = f"{api_url}?key={GOOGLE_API_KEY}"
            async with session.post(
                full_url,
                json=request_data,
                headers=headers,
                timeout=30
            ) as response:
                response_text = await response.text()
                logger.debug(f"API Response: {response_text}")
                
                if response.status != 200:
                    logger.error(f"API request failed with status {response.status}: {response_text}")
                    raise HTTPException(status_code=response.status, detail=f"API request failed: {response_text}")
                
                return await process_response(response_text)

    except Exception as e:
        logger.error(f"Error generating image: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

async def process_response(response_text):
    """处理API响应并提取文本和图像数据"""
    response_data = json.loads(response_text)
    
    if "candidates" not in response_data or not response_data["candidates"]:
        logger.error("No candidates in response")
        raise HTTPException(status_code=500, detail="No candidates in response")

    candidate = response_data["candidates"][0]
    if "content" not in candidate:
        logger.error("No content in candidate")
        raise HTTPException(status_code=500, detail="No content in candidate")

    content = candidate["content"]
    if "parts" not in content:
        logger.error("No parts in content")
        raise HTTPException(status_code=500, detail="No parts in content")

    parts = content["parts"]
    result_text = ""
    image_data = None

    for part in parts:
        if "text" in part:
            result_text = part["text"]
        elif "inlineData" in part:
            # 保存生成的图片
            image_bytes = base64.b64decode(part["inlineData"]["data"])
            filename = f"generated_{int(time.time())}.jpg"
            filepath = os.path.join(CONFIG['directories']['generated_images'], filename)
            
            with open(filepath, "wb") as f:
                f.write(image_bytes)
            
            image_data = f"/static/generated_images/{filename}"

    if not image_data:
        logger.error("No image data found in response parts")
        raise HTTPException(status_code=500, detail="No image data found in response parts")

    return {
        "success": True,
        "result": result_text,
        "image_url": image_data
    } 