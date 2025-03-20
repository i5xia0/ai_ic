<template>
  <div class="result-display">
    <h3 class="result-title">生成结果：</h3>
    
    <div v-if="isLoading" class="loading-container">
      <el-skeleton :rows="1" animated />
      <el-skeleton style="margin-top: 20px;" :rows="3" animated />
    </div>
    
    <template v-else>
      <div v-if="result" class="result-text">{{ result }}</div>
      
      <div v-if="imageUrl" class="image-section">
        <div class="image-with-download">
          <img :src="fullImageUrl" class="result-image" />
          
          <a 
            :href="fullImageUrl" 
            class="download-btn" 
            :download="`generated_${imageId}.jpg`"
          >
            <el-icon><Download /></el-icon>
            下载图片
          </a>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { ElSkeleton, ElIcon } from 'element-plus';
import { Download } from '@element-plus/icons-vue';
import apiService from '@/services/apiService';

interface Props {
  result?: string;
  imageUrl?: string;
  imageId?: number | string;
  isLoading?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  result: '',
  imageUrl: '',
  imageId: 0,
  isLoading: false
});

// 确保图片URL是完整的
const fullImageUrl = computed(() => {
  return apiService.getFullImageUrl(props.imageUrl);
});
</script>

<style scoped lang="scss">
.result-display {
  padding: 24px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  margin-top: 24px;
  
  .result-title {
    margin-top: 0;
    margin-bottom: 16px;
    color: #111827;
    font-weight: 600;
  }
  
  .loading-container {
    margin: 20px 0;
  }
  
  .result-text {
    white-space: pre-wrap;
    background-color: #f3f4f6;
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 16px;
  }
  
  .image-section {
    margin: 20px 0;
    padding: 20px;
    border-radius: 8px;
    background-color: #f3f4f6;
    display: flex;
    justify-content: center;
    
    .image-with-download {
      position: relative;
      display: inline-block;
      max-width: 100%;
      
      .result-image {
        max-width: 100%;
        border-radius: 8px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
      }
      
      .download-btn {
        position: absolute;
        bottom: 12px;
        right: 12px;
        background-color: rgba(16, 185, 129, 0.9);
        color: white;
        padding: 8px 16px;
        border-radius: 8px;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 6px;
        font-weight: 500;
        font-size: 14px;
        opacity: 0.8;
        transition: all 0.2s ease;
        
        &:hover {
          opacity: 1;
          transform: translateY(-1px);
        }
      }
    }
  }
}
</style> 