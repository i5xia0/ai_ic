<template>
  <div class="feature-showcase">
    <h2 class="section-title">智能图片创作助手</h2>
    <p class="section-description">通过先进的 AI 技术，让图片编辑和创作变得简单有趣</p>
    
    <div class="feature-grid">
      <div class="feature-card">
        <div class="feature-icon">
          <el-icon><Picture /></el-icon>
        </div>
        <h3 class="feature-title">双模式创作</h3>
        <ul class="feature-list">
          <li>图片编辑：上传图片进行智能修改</li>
          <li>文字生成：直接用文字描述创建图片</li>
        </ul>
      </div>
      
      <div class="feature-card">
        <div class="feature-icon">
          <el-icon><Edit /></el-icon>
        </div>
        <h3 class="feature-title">多模式支持</h3>
        <ul class="feature-list">
          <li>连续编辑：基于最新生成的图片继续优化</li>
          <li>历史编辑：随时返回任意历史版本继续创作</li>
        </ul>
      </div>
      
      <div class="feature-card">
        <div class="feature-icon">
          <el-icon><MagicStick /></el-icon>
        </div>
        <h3 class="feature-title">AI 驱动创作</h3>
        <ul class="feature-list">
          <li>采用最先进的AI生图模型</li>
          <li>支持高质量图片生成</li>
          <li>智能理解自然语言描述</li>
        </ul>
      </div>
      
      <div class="feature-card">
        <div class="feature-icon">
          <el-icon><Collection /></el-icon>
        </div>
        <h3 class="feature-title">场景描述生成</h3>
        <ul class="feature-list">
          <li>支持复杂场景描述</li>
          <li>可生成富有创意的画面</li>
          <li>细节精准还原</li>
        </ul>
      </div>
    </div>
    
    <div class="feature-highlight">
      <div class="highlight-icon">
        <el-icon><Download /></el-icon>
      </div>
      <div class="highlight-content">
        <h3 class="highlight-title">便捷操作</h3>
        <ul class="feature-list">
          <li>一键下载，轻松保存每个创意成果</li>
          <li>历史记录，随时查看之前的创作</li>
          <li>简单直观的用户界面</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ElIcon } from 'element-plus';
import { Picture, Edit, MagicStick, Collection, Download } from '@element-plus/icons-vue';
</script>

<style scoped lang="scss">
.feature-showcase {
  background-color: white;
  border-radius: 12px;
  padding: 32px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  margin: 32px 0;
  
  .section-title {
    text-align: center;
    color: #4f46e5;
    font-size: 1.8rem;
    margin-bottom: 8px;
  }
  
  .section-description {
    text-align: center;
    color: #6b7280;
    margin-bottom: 32px;
  }
  
  .feature-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
    margin-bottom: 24px;
    
    @media (max-width: 768px) {
      grid-template-columns: 1fr;
    }
  }
  
  .feature-card {
    background-color: #f3f4f6;
    border-radius: 12px;
    padding: 24px;
    display: flex;
    flex-direction: column;
    
    .feature-icon {
      color: #4f46e5;
      font-size: 24px;
      margin-bottom: 16px;
    }
    
    .feature-title {
      font-size: 1.2rem;
      font-weight: 600;
      margin-bottom: 16px;
      color: #111827;
    }
  }
  
  .feature-list {
    list-style-position: inside;
    padding-left: 0;
    color: #4b5563;
    
    li {
      margin-bottom: 8px;
    }
  }
  
  .feature-highlight {
    background-color: #ecfdf5;
    border-radius: 12px;
    padding: 24px;
    display: flex;
    align-items: flex-start;
    gap: 16px;
    
    .highlight-icon {
      color: #059669;
      font-size: 24px;
      flex-shrink: 0;
    }
    
    .highlight-content {
      flex-grow: 1;
    }
    
    .highlight-title {
      font-size: 1.2rem;
      font-weight: 600;
      margin-bottom: 16px;
      color: #059669;
    }
  }
}
</style> 