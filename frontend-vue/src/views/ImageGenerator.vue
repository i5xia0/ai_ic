<template>
  <div class="image-generator">
    <header class="app-header">
      <h1 class="app-title">AI 图片创作助手</h1>
      <p class="app-subtitle">通过人工智能，让您的创意变为现实</p>
      <el-button 
        type="info" 
        class="refresh-btn" 
        @click="refreshPage"
      >
        <el-icon class="refresh-icon"><Refresh /></el-icon>
        新的对话
      </el-button>
    </header>

    <div class="main-container">
      <!-- 移除了单独的ImageUploader组件 -->
      
      
      
      <div class="chat-container">
        <chat-history
          :messages="chatMessages"
          :selected-image-id="selectedImageId"
          @select-image="handleSelectHistoryImage"
        />
      </div>
      
      <edit-mode-switch
        v-model="continuousEditMode"
        :disabled="!hasGeneratedImages || isProcessing"
        @change="handleEditModeChange"
      />
      
      <chat-input
        :disabled="isProcessing"
        :has-image="!!currentImage"
        class="chat-input"
        :class="{'image-edit-mode': !!currentImage}"
        @send-message="handleSendMessage"
        @file-selected="handleFileSelected"
      />
    </div>
    
    <result-display
      :result="currentResult.text"
      :image-url="currentResult.imageUrl"
      :image-id="currentResult.imageId"
      :is-loading="isProcessing"
    />

    <feature-showcase />
    <usage-tips />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { ElButton, ElIcon, ElMessage } from 'element-plus';
import { Refresh } from '@element-plus/icons-vue';
// 移除 ImageUploader 引用
import ChatHistory from '../components/ChatHistory.vue';
import EditModeSwitch from '../components/EditModeSwitch.vue';
import ChatInput from '../components/ChatInput.vue';
import ResultDisplay from '../components/ResultDisplay.vue';
import FeatureShowcase from '../components/FeatureShowcase.vue';
import UsageTips from '../components/UsageTips.vue';
import apiService from '@/services/apiService';

// 状态管理
const isProcessing = ref(false);
const chatMessages = ref([]);
const currentImage = ref(null);
const originalImage = ref(null);
const selectedImage = ref(null);
const selectedImageId = ref(null);
const generatedImageCount = ref(0);
const continuousEditMode = ref(true);
const currentResult = ref({
  text: '',
  imageUrl: '',
  imageId: 0
});

// 计算属性
const hasGeneratedImages = computed(() => generatedImageCount.value > 0);
const currentImageIsOriginal = computed(() => 
  currentImage.value === originalImage.value && !!originalImage.value
);

// 刷新页面
const refreshPage = () => {
  window.location.reload();
};

// 处理文件选择 - 直接从ChatInput组件接收
const handleFileSelected = (file) => {
  if (!file) {
    // 如果file为null，表示清除了图片
    currentImage.value = null;
    originalImage.value = null;
    selectedImage.value = null;
    selectedImageId.value = null;
    return;
  }
  
  console.log('文件已选择:', file);
  currentImage.value = file;
  originalImage.value = file;
  selectedImage.value = null;
  selectedImageId.value = null;
  
  // 在控制台输出文件信息，辅助调试
  console.log('图片已准备好进行编辑:', {
    fileName: file.name,
    size: file.size,
    type: file.type
  });
  
  // 添加提示消息
  ElMessage({
    message: '已选择图片，请输入编辑指令',
    type: 'success'
  });
};

// 移除选择原始图片的方法，因为现在直接在ChatInput选择图片

// 处理选择历史图片
const handleSelectHistoryImage = (imageData) => {
  selectedImageId.value = imageData.id;
  
  // 从URL加载图片并转换为File对象
  fetch(imageData.fullUrl)
    .then(response => response.blob())
    .then(blob => {
      const file = new File([blob], `selected_${imageData.id}.jpg`, { type: 'image/jpeg' });
      selectedImage.value = file;
      currentImage.value = file;
      continuousEditMode.value = false;
      
      ElMessage.success('已选择此图片作为编辑基础');
    })
    .catch(error => {
      console.error('Error selecting image:', error);
      ElMessage.error('选择图片失败');
    });
};

// 处理编辑模式变更
const handleEditModeChange = (value) => {
  if (value && selectedImage.value) {
    selectedImage.value = null;
    selectedImageId.value = null;
  }
};

// 发送消息
const handleSendMessage = async (message) => {
  if (isProcessing.value) return;
  
  // 保存当前图片（如果有）用于API调用
  const currentImageForRequest = currentImage.value;
  
  // 添加用户消息
  chatMessages.value.push({
    type: 'user',
    content: message,
    imageUrl: currentImageForRequest instanceof File ? URL.createObjectURL(currentImageForRequest) : '',
    imageId: selectedImageId.value || ('temp-' + Date.now())
  });
  
  isProcessing.value = true;
  currentResult.value = { text: '正在生成图片，请稍候...', imageUrl: '', imageId: 0 };
  
  try {
    let response;
    
    if (currentImageForRequest instanceof File) {
      // 使用图片生成
      const imageToUse = selectedImage.value || currentImageForRequest;
      response = await apiService.generateFromImage(imageToUse, message);
    } else {
      // 纯文本生成
      response = await apiService.generateFromText(message);
    }
    
    const data = response.data;
    
    if (!data.success || !data.image_url) {
      throw new Error('生成图片失败：未获取到图片数据');
    }
    
    // 更新生成的图片计数
    generatedImageCount.value++;
    
    // 更新当前结果
    currentResult.value = {
      text: data.result || '',
      imageUrl: data.image_url,
      imageId: generatedImageCount.value
    };
    
    // 添加AI消息到聊天记录
    chatMessages.value.push({
      type: 'ai',
      content: data.result || '',
      imageUrl: data.image_url,
      imageId: generatedImageCount.value
    });
    
    // 如果在连续编辑模式下，将当前生成的图片作为下一次编辑的基础
    if (continuousEditMode.value) {
      const imageUrl = apiService.getFullImageUrl(data.image_url);
      
      try {
        const response = await fetch(imageUrl);
        const blob = await response.blob();
        currentImage.value = new File([blob], `generated_${generatedImageCount.value}.jpg`, { type: 'image/jpeg' });
      } catch (error) {
        console.error('Error creating File from image:', error);
      }
    } else {
      // 如果不是连续编辑模式，清除当前图片
      currentImage.value = null;
    }
  } catch (error) {
    console.error('Error generating image:', error);
    
    // 添加错误消息
    chatMessages.value.push({
      type: 'ai',
      content: `错误：${error.message || '生成失败'}`,
    });
    
    currentResult.value = { text: `错误：${error.message || '生成失败'}`, imageUrl: '', imageId: 0 };
    ElMessage.error('生成图片失败');
    
    // 发生错误时清除当前图片
    currentImage.value = null;
  } finally {
    isProcessing.value = false;
    
    // 清除选择的图片，但保留当前图片（如果是连续编辑模式）
    if (!continuousEditMode.value) {
      selectedImage.value = null;
      selectedImageId.value = null;
    }
  }
};
</script>

<style scoped lang="scss">
.image-generator {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
  
  .app-header {
    margin-bottom: 32px;
    position: relative;
    
    .app-title {
      text-align: center;
      color: #4f46e5;
      font-size: 2.5rem;
      font-weight: 700;
      margin-bottom: 8px;
    }
    
    .app-subtitle {
      text-align: center;
      color: #6b7280;
      font-size: 1.2rem;
      margin-top: 0;
    }
    
    .refresh-btn {
      position: absolute;
      top: 0;
      right: 0;
      display: flex;
      align-items: center;
      gap: 6px;
      
      .refresh-icon {
        transition: transform 0.5s ease;
      }
      
      &:hover .refresh-icon {
        transform: rotate(180deg);
      }
    }
  }
  
  .main-container {
    background-color: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    margin-bottom: 24px;
  }
  
  .chat-container {
    margin: 20px 0;
    background-color: #f3f4f6;
    border-radius: 8px;
    padding: 16px;
  }
  
  // 添加创作模式指示器样式
  .creation-mode-indicator {
    margin: 16px 0;
    animation: fadeIn 0.3s ease;
  }
  
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(-10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  
  // 添加图片编辑模式的样式
  .chat-input.image-edit-mode {
    :deep(.el-textarea__inner) {
      border: 2px solid #10b981;
      background-color: #f0fdf4;
      
      &::placeholder {
        color: #065f46;
        font-weight: 500;
      }
    }
  }
}

@media (max-width: 768px) {
  .image-generator {
    padding: 12px;
    
    .main-container {
      padding: 16px;
    }
  }
}
</style> 