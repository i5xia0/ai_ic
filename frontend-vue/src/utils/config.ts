import { AppConfig } from '@/types';

/**
 * 从环境变量中读取配置
 * Vite会自动将.env文件中的变量暴露在import.meta.env中
 * 只有以VITE_开头的变量才会暴露给客户端代码
 */

// 全局配置
export const CONFIG: AppConfig = {
  // API服务器基础URL - 根据不同环境自动选择
  baseURL: import.meta.env.VITE_API_BASE_URL as string,
  imageBaseURL: import.meta.env.VITE_IMAGE_BASE_URL as string,
  
  // 默认提示词前缀
  defaultPromptPrefix: import.meta.env.VITE_DEFAULT_PROMPT_PREFIX as string || '图片中不要出现文字。',
  
  // 图片配置
  image: {
    maxWidth: parseInt(import.meta.env.VITE_IMAGE_MAX_WIDTH as string) || 1024,
    maxHeight: parseInt(import.meta.env.VITE_IMAGE_MAX_HEIGHT as string) || 768,
    format: import.meta.env.VITE_IMAGE_FORMAT as string || 'jpeg'
  }
};

// 开发环境下打印配置信息
if (import.meta.env.DEV) {
  console.log('当前应用配置:', CONFIG);
}

export default CONFIG; 