<template>
  <div class="chat-history" ref="chatHistoryRef">
    <template v-if="messages.length === 0">
      <div class="empty-state">
        <el-empty description="暂无对话历史" />
      </div>
    </template>
    
    <template v-else>
      <chat-message
        v-for="(message, index) in messages"
        :key="index"
        :type="message.type"
        :content="message.content"
        :image-url="message.imageUrl"
        :image-id="message.imageId"
        :is-selected="selectedImageId === message.imageId"
        @image-click="handleImageClick"
      />
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, nextTick } from 'vue';
import ChatMessage from './ChatMessage.vue';
import { ChatMessage as ChatMessageType } from '@/types';

interface Props {
  messages: ChatMessageType[];
  selectedImageId: string | number | null;
}

const props = defineProps({
  messages: {
    type: Array,
    default: () => []
  },
  selectedImageId: {
    type: [String, Number, null],
    default: null
  }
});

const emit = defineEmits(['select-image']);

const chatHistoryRef = ref(null);

const handleImageClick = (imageId: string | number) => {
  emit('select-image', imageId);
};

// 监听消息变化，自动滚动到底部
watch(() => props.messages.length, async () => {
  await nextTick();
  if (chatHistoryRef.value) {
    chatHistoryRef.value.scrollTop = chatHistoryRef.value.scrollHeight;
  }
});
</script>

<style scoped lang="scss">
.chat-history {
  height: 400px;
  overflow-y: auto;
  padding: 16px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: inset 0 0 5px rgba(0, 0, 0, 0.05);
  scrollbar-width: thin;
  scrollbar-color: #d1d5db #f3f4f6;
  
  &::-webkit-scrollbar {
    width: 8px;
  }
  
  &::-webkit-scrollbar-track {
    background: #f3f4f6;
  }
  
  &::-webkit-scrollbar-thumb {
    background-color: #d1d5db;
    border-radius: 20px;
  }
  
  .empty-state {
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}
</style> 