<template>
  <div class="edit-mode-switch" :class="{ 'disabled': disabled }">
    <el-switch
      v-model="switchValue"
      :disabled="disabled"
      @change="handleChange"
    />
    <div class="switch-text">
      <span class="switch-title">连续编辑模式</span>
      <p class="switch-description">基于上一次生成的图片继续编辑</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue';

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: true
  },
  disabled: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['update:modelValue', 'change']);

const switchValue = ref(props.modelValue);

watch(() => props.modelValue, (newValue: boolean) => {
  switchValue.value = newValue;
});

const handleChange = (val: boolean) => {
  emit('update:modelValue', val);
  emit('change', val);
};
</script>

<style scoped lang="scss">
.edit-mode-switch {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background-color: white;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  margin: 16px 0;
  transition: all 0.2s ease;
  
  &.disabled {
    opacity: 0.7;
    cursor: not-allowed;
    
    .switch-text {
      opacity: 0.6;
    }
  }
  
  .switch-text {
    .switch-title {
      font-weight: 500;
      color: #111827;
      display: block;
      margin-bottom: 4px;
    }
    
    .switch-description {
      font-size: 0.875rem;
      color: #6b7280;
      margin: 0;
    }
  }
}
</style> 