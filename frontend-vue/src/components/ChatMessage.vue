<template>
  <div
    class="chat-message"
    :class="[`chat-message--${type}`, { 'has-image': imageUrl }]"
  >
    <div class="chat-message__avatar">
      <el-icon v-if="type === 'user'"><UserFilled /></el-icon>
      <el-icon v-else><Service /></el-icon>
    </div>
    
    <div class="chat-message__content">
      <div class="chat-message__bubble">
        <!-- 图片在上面 -->
        <div 
          v-if="imageUrl" 
          class="chat-message__image"
          :class="{ 'is-selected': isSelected }"
          @click="onImageClick"
        >
          <img :src="fullImageUrl" alt="上传图片" />
        </div>
        
        <!-- 文字在下面 -->
        <div v-if="content" class="chat-message__text">{{ content }}</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { UserFilled, Service } from '@element-plus/icons-vue';
import apiService from '@/services/apiService';
import { MessageType } from '@/types';

const props = defineProps({
  type: {
    type: String,
    required: true
  },
  content: {
    type: String,
    default: ''
  },
  imageUrl: {
    type: String,
    default: ''
  },
  imageId: {
    type: [String, Number],
    default: ''
  },
  isSelected: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['image-click']);

// 完整的图片URL
const fullImageUrl = computed(() => {
  // 如果是完整URL或数据URL，直接返回
  if (props.imageUrl.startsWith('http') || props.imageUrl.startsWith('data:') || props.imageUrl.startsWith('blob:')) {
    return props.imageUrl;
  }
  // 否则通过服务获取完整URL
  return apiService.getFullImageUrl(props.imageUrl);
});

// 图片点击事件
const onImageClick = () => {
  if (props.imageUrl && props.imageId) {
    emit('image-click', props.imageId);
  }
};
</script>

<style lang="scss" scoped>
.chat-message {
  display: flex;
  margin-bottom: 12px;
  
  &--user {
    flex-direction: row-reverse;
    
    .chat-message__avatar {
      background-color: var(--primary-color);
    }
    
    .chat-message__content {
      margin-left: 0;
      margin-right: 12px;
      display: flex;
      flex-direction: column;
      align-items: flex-end;
    }
    
    .chat-message__bubble {
      background-color: var(--primary-light-color, #ecf5ff);
      border-radius: 12px 0 12px 12px;
    }
    
    .chat-message__text {
      color: var(--primary-color);
      background-color: transparent;
      padding-top: 0;
    }
  }
  
  &--ai, &--system {
    .chat-message__avatar {
      background-color: var(--success-color, #67c23a);
    }
    
    .chat-message__bubble {
      background-color: #f0f9eb;
      border-radius: 0 12px 12px 12px;
      border: 1px solid rgba(103, 194, 58, 0.2);
    }
    
    .chat-message__text {
      color: #606266;
    }
  }
  
  &__avatar {
    flex-shrink: 0;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    
    .el-icon {
      font-size: 18px;
    }
  }
  
  &__content {
    margin-left: 12px;
    max-width: calc(100% - 48px);
  }
  
  &__bubble {
    border-radius: 12px;
    overflow: hidden;
    padding: 2px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    
    &:hover {
      .chat-message__image {
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
      }
    }
  }
  
  &__image {
    cursor: pointer;
    border: 2px solid transparent;
    transition: all 0.2s;
    border-radius: 8px 8px 0 0;
    overflow: hidden;
    
    &.is-selected {
      border-color: var(--primary-color);
    }
    
    img {
      max-width: 200px;
      max-height: 200px;
      display: block;
    }
  }
  
  &__text {
    padding: 10px 14px;
    word-break: break-word;
    white-space: pre-wrap;
    line-height: 1.5;
  }
}

@media (max-width: 768px) {
  .chat-message__image img {
    max-width: 150px;
    max-height: 150px;
  }
}
</style> 