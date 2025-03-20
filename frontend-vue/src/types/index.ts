// 应用设置类型
export interface AppConfig {
  baseURL: string;
  imageBaseURL: string;
  defaultPromptPrefix: string;
  image: {
    maxWidth: number;
    maxHeight: number;
    format: string;
  };
}

// 消息类型
export type MessageType = 'user' | 'system';

// 图片数据类型
export interface ImageData {
  url: string;
  fullUrl: string;
  id: string | number;
}

// 聊天消息类型
export interface ChatMessage {
  type: MessageType;
  content: string;
  imageUrl?: string;
  imageId?: string | number;
}

// 生成结果类型
export interface GenerationResult {
  text: string;
  imageUrl: string;
  imageId: number | string;
}

// API响应类型
export interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  data?: T;
}

// 图片生成响应类型
export interface ImageGenerationResponse {
  success: boolean;
  result?: string;
  image_url?: string;
  message?: string;
}

// 上传图片响应类型
export interface ImageUploadResponse {
  success: boolean;
  imageUrl?: string;
  imageId?: string | number;
  message?: string;
} 