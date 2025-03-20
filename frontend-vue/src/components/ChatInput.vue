<template>
  <div class="chat-input-container">
    <div class="input-area">
      <el-input
        v-model="inputValue"
        type="textarea"
        :rows="3"
        :placeholder="placeholderText"
        resize="vertical"
        :disabled="disabled"
        @keydown.enter.ctrl.prevent="submitMessage"
      />
      
      <!-- Image upload button overlaid on the input area -->
      <div class="image-button-overlay">
        <el-upload
          class="image-uploader"
          action=""
          :auto-upload="false"
          :show-file-list="false"
          :on-change="handleFileChange"
          :disabled="disabled"
        >
          <el-button 
            type="primary" 
            :disabled="disabled"
            class="upload-button"
            :class="{'has-image': previewUrl}"
          >
            <template v-if="!previewUrl">
              <el-icon><Picture /></el-icon>
              <span class="button-text">图片</span>
            </template>
            <template v-else>
              <img :src="previewUrl" alt="预览图" class="button-preview-image" />
            </template>
          </el-button>
        </el-upload>
        
        <el-button 
          v-if="previewUrl"
          type="danger" 
          circle 
          size="small"
          class="clear-image-btn"
          @click.stop="clearPreview"
        >
          <el-icon><Delete /></el-icon>
        </el-button>
      </div>
      
      <!-- 添加图文模式指示器 -->
      <div v-if="isImageTextMode" class="image-text-indicator">
        <el-icon><Picture /></el-icon> 图文模式
      </div>
    </div>
    
    <el-button 
      type="success" 
      class="send-button"
      :disabled="disabled || !canSubmit"
      @click="submitMessage"
      :class="{'with-image': previewUrl}"
    >
      <el-icon class="el-icon--left"><Position /></el-icon>
      {{ previewUrl ? '发送图文' : '发送' }}
    </el-button>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { Position, Picture, Delete } from '@element-plus/icons-vue';
import { ElMessage } from 'element-plus';
import type { UploadFile, UploadFiles } from 'element-plus';

const props = defineProps({
  disabled: {
    type: Boolean,
    default: false
  },
  hasImage: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['send-message', 'file-selected']);

const inputValue = ref('');
const selectedFile = ref(null);
const previewUrl = ref('');

const placeholderText = computed(() => {
  if (previewUrl.value) {
    return '请描述您想要对图片进行的修改，图文将一起发送...';
  }
  if (props.hasImage) {
    return '请描述您想要对图片进行的修改，例如："将颜色改为蓝色"，"添加更多装饰细节"...';
  }
  return '请输入您想要创建的图片描述，例如："一只可爱的卡通猫咪在阳光下玩耍"...';
});

const canSubmit = computed(() => {
  return inputValue.value.trim() || selectedFile.value;
});

// 显示是否为图文模式
const isImageTextMode = computed(() => {
  return !!previewUrl.value;
});

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
  
  // 通知父组件文件已选择
  emit('file-selected', file.raw);
  
  // 显示提示
  ElMessage.success('已选择图片，将与文本一起发送');
};

// 清除预览
const clearPreview = (event?: Event) => {
  if (event) {
    event.stopPropagation();
  }
  selectedFile.value = null;
  previewUrl.value = '';
  
  // 通知父组件文件已移除
  emit('file-selected', null);
};

const submitMessage = () => {
  if (props.disabled || !canSubmit.value) return;
  
  // 发送消息
  emit('send-message', inputValue.value.trim());
  inputValue.value = '';
  
  // 发送后清除图片
  if (selectedFile.value) {
    clearPreview();
  }
};
</script>

<style scoped lang="scss">
.chat-input-container {
  margin: 16px 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
  
  .input-area {
    position: relative;
    width: 100%;
  }
  
  .image-button-overlay {
    position: absolute;
    top: 10px;
    bottom: 10px;
    left: 10px;
    display: flex;
    align-items: center;
    z-index: 10;
  }
  
  .upload-button {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 4px;
    width: 50px;
    height: 50px;
    padding: 0;
    border-radius: 8px;
    transition: all 0.2s ease;
    background-color: #f3f4f6;
    border: 1px solid #dcdfe6;
    color: #606266;
    
    &.has-image {
      padding: 0;
      border: 2px solid #dcdfe6;
      overflow: hidden;
      border-radius: 8px;
    }
    
    .button-text {
      display: none;
    }
    
    .button-preview-image {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
      border-radius: 6px;
    }
    
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
    }
  }
  
  .clear-image-btn {
    position: absolute;
    top: -6px;
    right: -6px;
    padding: 4px;
    min-height: auto;
    min-width: auto;
    font-size: 12px;
    z-index: 15;
  }
  
  .send-button {
    align-self: flex-end;
    background-color: #10b981;
    transition: all 0.2s ease;
    
    &.with-image {
      background-color: #4f46e5;
      
      &:hover:not(:disabled) {
        background-color: #4338ca;
      }
    }
    
    &:hover:not(:disabled) {
      background-color: #059669;
      transform: translateY(-1px);
    }
  }
  
  .image-text-indicator {
    position: absolute;
    bottom: -20px;
    left: 10px;
    font-size: 12px;
    color: #4f46e5;
    display: flex;
    align-items: center;
    gap: 4px;
  }
}

:deep(.el-textarea__inner) {
  border-radius: 8px;
  transition: border-color 0.2s ease;
  padding-left: 75px; /* 增加左侧内边距以适应50px宽的按钮 */
  
  &:focus {
    border-color: #4f46e5;
    box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
  }
}

@media (min-width: 768px) {
  .chat-input-container {
    flex-direction: row;
    align-items: flex-start;
    
    .input-area {
      flex: 1;
    }
  }
}
</style> 