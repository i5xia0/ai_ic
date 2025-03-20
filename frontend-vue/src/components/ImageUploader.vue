<template>
  <div class="image-uploader">
    <div class="image-uploader__title">上传图片</div>
    <div class="image-uploader__description">
      上传图片，使用AI编辑或添加描述
    </div>
    
    <el-upload
      class="image-uploader__upload"
      drag
      action=""
      :auto-upload="false"
      :show-file-list="false"
      :on-change="handleFileChange"
      :disabled="disabled"
    >
      <div 
        class="image-uploader__content"
        :class="{ 'is-disabled': disabled, 'has-preview': previewUrl }"
      >
        <template v-if="!previewUrl">
          <el-icon class="upload-icon"><Upload /></el-icon>
          <div class="upload-text">
            <p class="primary-text">点击或拖拽图片至此处</p>
            <p class="secondary-text">支持JPG、JPEG、PNG格式</p>
          </div>
        </template>
        
        <template v-else>
          <img :src="previewUrl" alt="预览图" class="preview-image" />
          <div class="preview-overlay">
            <el-button 
              type="danger" 
              circle 
              size="small"
              @click.stop="clearPreview"
            >
              <el-icon><Delete /></el-icon>
            </el-button>
          </div>
        </template>
      </div>
    </el-upload>
    
    <div v-if="uploadProgress > 0 && uploadProgress < 100" class="upload-progress">
      <el-progress :percentage="uploadProgress" :show-text="false" />
      <span class="progress-text">{{ uploadProgress }}%</span>
    </div>
    
    
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { ElMessage } from 'element-plus';
import { Upload, Delete } from '@element-plus/icons-vue';
import apiService from '@/services/apiService';
import { ImageUploadResponse } from '@/types';
import type { UploadFile, UploadFiles } from 'element-plus';

interface Props {
  disabled?: boolean;
}

const props = defineProps({
  disabled: {
    type: Boolean,
    default: false
  }
});

interface UploadImageEvent {
  success: boolean;
  imageUrl?: string;
  imageId?: string | number;
}

const emit = defineEmits(['upload-success', 'file-selected']);

const selectedFile = ref(null);
const previewUrl = ref('');
const isUploading = ref(false);
const uploadProgress = ref(0);

// 处理文件变更
const handleFileChange = (file: UploadFile, files: UploadFiles) => {
  if (!file.raw) {
    ElMessage.error('文件上传失败');
    return;
  }
  
  const isImage = file.raw.type.startsWith('image/');
  const isJpgOrPng = ['image/jpeg', 'image/png', 'image/jpg'].includes(file.raw.type);
  
  if (!isImage || !isJpgOrPng) {
    ElMessage.error('请上传JPG、JPEG或PNG格式图片');
    return;
  }
  
  const isLt5M = file.raw.size / 1024 / 1024 < 5;
  if (!isLt5M) {
    ElMessage.error('图片大小不能超过5MB');
    return;
  }
  
  selectedFile.value = file.raw;
  previewUrl.value = URL.createObjectURL(file.raw);
  
  // 直接通知父组件文件已选择，无需点击上传按钮
  emit('file-selected', file.raw);
};

// 清除预览
const clearPreview = () => {
  selectedFile.value = null;
  previewUrl.value = '';
  uploadProgress.value = 0;
};

// 上传图片
const uploadImage = async () => {
  if (!selectedFile.value) {
    ElMessage.warning('请先选择一张图片');
    return;
  }
  
  try {
    isUploading.value = true;
    uploadProgress.value = 10;
    
    // 模拟上传进度
    const progressInterval = setInterval(() => {
      if (uploadProgress.value < 90) {
        uploadProgress.value += 10;
      }
    }, 300);
    
    const result = await apiService.uploadImage(selectedFile.value);
    
    clearInterval(progressInterval);
    uploadProgress.value = 100;
    
    if (result && result.success) {
      ElMessage.success('图片上传成功');
      emit('upload-success', {
        success: true,
        imageUrl: result.imageUrl,
        imageId: result.imageId
      });
      
      // 清空上传
      setTimeout(() => {
        clearPreview();
      }, 500);
    } else {
      throw new Error(result.message || '上传失败');
    }
  } catch (error) {
    ElMessage.error((error as Error).message || '上传图片时出错');
  } finally {
    isUploading.value = false;
  }
};
</script>

<style lang="scss" scoped>
.image-uploader {
  background-color: var(--bg-light);
  border-radius: 12px;
  padding: 12px;
  max-width: 100%;
  
  &__title {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 4px;
  }
  
  &__description {
    font-size: 13px;
    color: var(--text-secondary);
    margin-bottom: 10px;
  }
  
  &__upload {
    width: 100%;
    
    :deep(.el-upload) {
      width: 100%;
      
      .el-upload-dragger {
        width: 100%;
        height: auto;
        padding: 15px 10px;
        background-color: var(--bg-lighter);
        border: 1px dashed var(--border-color);
        border-radius: 6px;
        
        &:hover {
          border-color: var(--primary-color);
        }
        
        &.is-dragover {
          background-color: rgba(var(--primary-rgb), 0.05);
          border-color: var(--primary-color);
        }
      }
    }
  }
  
  &__content {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: 120px;
    width: 100%;
    
    &.is-disabled {
      opacity: 0.7;
      cursor: not-allowed;
    }
    
    &.has-preview {
      position: relative;
      padding: 0;
      
      .preview-image {
        max-width: 100%;
        max-height: 180px;
        display: block;
        border-radius: 4px;
        object-fit: contain;
      }
      
      .preview-overlay {
        position: absolute;
        top: 5px;
        right: 5px;
        opacity: 0;
        transition: opacity 0.2s;
        z-index: 10;
      }
      
      &:hover .preview-overlay {
        opacity: 1;
      }
    }
    
    .upload-icon {
      font-size: 24px;
      color: var(--primary-color);
      margin-bottom: 6px;
    }
    
    .upload-text {
      text-align: center;
      
      .primary-text {
        font-size: 14px;
        margin-bottom: 4px;
      }
      
      .secondary-text {
        font-size: 12px;
        color: var(--text-secondary);
      }
    }
  }
  
  &__actions {
    margin-top: 12px;
    display: flex;
    justify-content: flex-start;
    
    .el-button {
      padding: 6px 12px;
      font-size: 13px;
    }
  }
  
  .upload-progress {
    margin-top: 10px;
    display: flex;
    align-items: center;
    
    :deep(.el-progress-bar) {
      flex: 1;
      margin-right: 8px;
    }
    
    .progress-text {
      font-size: 12px;
      color: var(--text-secondary);
    }
  }
}

@keyframes progress {
  0% { width: 0%; }
  100% { width: 100%; }
}
</style> 