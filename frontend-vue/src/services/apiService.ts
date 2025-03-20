import axios, { AxiosResponse, AxiosError } from 'axios';
import { 
  ApiResponse, 
  ImageUploadResponse,
  ImageGenerationResponse
} from '@/types';

import { CONFIG } from '@/utils/config';

const API_BASE_URL = CONFIG.baseURL || '/api';
const IMAGE_BASE_URL = CONFIG.imageBaseURL || '/static/images';

// 创建axios实例
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  timeout: 60000, // 60秒超时
});

// 请求拦截器
apiClient.interceptors.request.use(
  config => {
    // 可以在这里添加认证token等
    return config;
  },
  (error: AxiosError) => {
    return Promise.reject(error);
  }
);

// 响应拦截器
apiClient.interceptors.response.use(
  (response: AxiosResponse) => {
    return response;
  },
  (error: AxiosError) => {
    const { response } = error;
    let message = '未知错误';
    
    if (response) {
      const { status, data } = response;
      message = (data as any).message || `请求错误: ${status}`;
    } else if (error.request) {
      message = '服务器无响应';
    } else {
      message = error.message || '请求出错';
    }
    
    // 输出错误到控制台，而不是使用ElMessage
    console.error(`API错误: ${message}`);
    return Promise.reject(error);
  }
);

const apiService = {
  /**
   * 获取完整的图片URL
   * @param {string} imagePath - 图片路径
   * @returns {string} 完整的图片URL
   */
  getFullImageUrl(imagePath: string): string {
    if (!imagePath) return '';
    if (imagePath.startsWith('http') || imagePath.startsWith('data:')) {
      return imagePath;
    }
    return `${IMAGE_BASE_URL}${imagePath}`;
  },

  /**
   * 上传图片
   * @param {File} file - 要上传的文件
   * @returns {Promise} 包含上传结果的Promise
   */
  async uploadImage(file: File): Promise<ImageUploadResponse> {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await apiClient.post<ImageUploadResponse>(`/upload`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    
    return response.data;
  },

  /**
   * 发送文本生成图片
   * @param {string} text - 用户输入的文本
   * @param {string|null} imageId - 原始图片ID，用于编辑模式
   * @param {boolean} continuousEdit - 是否启用连续编辑模式
   * @returns {Promise} 包含生成结果的Promise
   */
  async generateImage(
    text: string, 
    imageId: string | number | null = null, 
    continuousEdit: boolean = false
  ): Promise<ApiResponse<ImageGenerationResponse>> {
    const payload = {
      text,
      imageId,
      continuousEdit,
    };
    
    const response = await apiClient.post<ApiResponse<ImageGenerationResponse>>('/generate', payload);
    return response.data;
  },

  /**
   * 文本生成图片
   * @param prompt 提示词
   * @returns 生成结果
   */
  async generateFromText(prompt: string): Promise<AxiosResponse<ImageGenerationResponse>> {
    return apiClient.post<ImageGenerationResponse>('/generate_from_text', {
      prompt: prompt
    });
  },

  /**
   * 基于图片生成图片
   * @param file 图片文件
   * @param prompt 提示词
   * @returns 生成结果
   */
  async generateFromImage(file: File, prompt: string): Promise<AxiosResponse<ImageGenerationResponse>> {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('prompt', prompt);
    
    return apiClient.post<ImageGenerationResponse>('/generate', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
  },

  /**
   * 下载图片
   * @param {string} imageUrl - 图片URL
   * @param {string} filename - 下载的文件名
   */
  downloadImage(imageUrl: string, filename?: string): void {
    const fullUrl = this.getFullImageUrl(imageUrl);
    const link = document.createElement('a');
    link.href = fullUrl;
    link.download = filename || 'generated-image.png';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  },
};

export default apiService; 