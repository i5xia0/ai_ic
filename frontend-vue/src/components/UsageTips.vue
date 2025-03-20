<template>
  <div class="usage-tips">
    <h3 class="section-title">创作提示与技巧</h3>
    
    <div class="tips-card">
      <div class="card-header">
        <span class="emoji">🎨</span>
        <h4 class="card-title">场景描述示例</h4>
      </div>
      
      <div class="example-box">
        <div class="example-item">
          "一只戴着太空头盔的猫咪在月球表面漫步，背景是璀璨的星空"
        </div>
        <div class="example-item">
          "一座未来风格的城市，充满霓虹灯和飞行汽车，天空中有多个月亮"
        </div>
      </div>
    </div>
    
    <div class="tips-card">
      <div class="card-header">
        <span class="emoji">✨</span>
        <h4 class="card-title">提升效果的技巧</h4>
      </div>
      
      <div class="tips-grid">
        <div class="tip-category">
          <h5 class="category-title">场景细节</h5>
          <ul class="tip-list">
            <li>光线效果（柔和、强烈、逆光）</li>
            <li>颜色主题（鲜艳、柔和、对比）</li>
            <li>材质描述（金属、木质、玻璃）</li>
            <li>环境氛围（室内、户外、水下）</li>
          </ul>
        </div>
        
        <div class="tip-category">
          <h5 class="category-title">艺术风格</h5>
          <ul class="tip-list">
            <li>绘画风格（水彩、油画、素描）</li>
            <li>数字艺术（像素艺术、3D渲染）</li>
            <li>摄影风格（人像、风景、微距）</li>
            <li>时代风格（复古、现代、未来）</li>
          </ul>
        </div>
        
        <div class="tip-category">
          <h5 class="category-title">画面氛围</h5>
          <ul class="tip-list">
            <li>情绪（欢快、忧郁、神秘）</li>
            <li>风格（梦幻、科技感、复古）</li>
            <li>时间（黎明、黄昏、夜晚）</li>
            <li>季节（春、夏、秋、冬）</li>
          </ul>
        </div>
      </div>
    </div>
    
    <div class="advanced-tips">
      <div class="card-header">
        <span class="emoji">🚀</span>
        <h4 class="card-title">进阶创作技巧</h4>
      </div>
      
      <div class="advanced-grid">
        <div class="advanced-tip">
          <h5 class="tip-title">艺术家风格</h5>
          <p class="tip-description">使用具体的艺术家风格增强图片特色</p>
          <div class="tip-example">"梵高风格的星空下的城市"</div>
        </div>
        
        <div class="advanced-tip">
          <h5 class="tip-title">风格融合</h5>
          <p class="tip-description">结合多种元素创造独特画面</p>
          <div class="tip-example">"蒸汽朋克风格的古代中国街道"</div>
        </div>
        
        <div class="advanced-tip">
          <h5 class="tip-title">视角与构图</h5>
          <p class="tip-description">指定特定视角增强画面表现力</p>
          <div class="tip-example">"鸟瞰视角的森林迷宫"</div>
        </div>
        
        <div class="advanced-tip">
          <h5 class="tip-title">光影效果</h5>
          <p class="tip-description">描述光影效果增强画面氛围</p>
          <div class="tip-example">"在金色夕阳照射下的沙漠绿洲"</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// 无需额外依赖
</script>

<style scoped lang="scss">
.usage-tips {
  background-color: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  margin-bottom: 32px;
  
  .section-title {
    color: #4f46e5;
    font-size: 1.5rem;
    text-align: center;
    margin-bottom: 24px;
  }
  
  .tips-card {
    background-color: white;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    margin-bottom: 24px;
    
    .card-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 16px;
      
      .emoji {
        font-size: 24px;
      }
      
      .card-title {
        font-size: 1.25rem;
        font-weight: 600;
        color: #111827;
        margin: 0;
      }
    }
    
    .example-box {
      background-color: #f3f4f6;
      border-radius: 8px;
      padding: 16px;
      
      .example-item {
        background-color: white;
        border-left: 4px solid #4f46e5;
        padding: 12px;
        margin-bottom: 12px;
        border-radius: 0 8px 8px 0;
        
        &:last-child {
          margin-bottom: 0;
        }
      }
    }
    
    .tips-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 16px;
      
      @media (max-width: 768px) {
        grid-template-columns: 1fr;
      }
      
      .tip-category {
        background-color: #f3f4f6;
        padding: 16px;
        border-radius: 8px;
        
        .category-title {
          color: #4f46e5;
          margin-top: 0;
          margin-bottom: 12px;
          font-weight: 600;
        }
        
        .tip-list {
          list-style-type: none;
          padding-left: 0;
          margin: 0;
          
          li {
            position: relative;
            padding-left: 16px;
            margin-bottom: 8px;
            font-size: 0.875rem;
            
            &:before {
              content: '•';
              color: #4f46e5;
              position: absolute;
              left: 0;
            }
            
            &:last-child {
              margin-bottom: 0;
            }
          }
        }
      }
    }
  }
  
  .advanced-tips {
    background-color: #fffbeb;
    border-radius: 8px;
    padding: 20px;
    border-left: 4px solid #f59e0b;
    
    .advanced-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 16px;
      margin-top: 16px;
      
      @media (max-width: 768px) {
        grid-template-columns: 1fr;
      }
      
      .advanced-tip {
        background-color: white;
        padding: 16px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        
        .tip-title {
          color: #f59e0b;
          margin-top: 0;
          margin-bottom: 8px;
          font-weight: 600;
        }
        
        .tip-description {
          font-size: 0.875rem;
          margin-bottom: 12px;
        }
        
        .tip-example {
          background-color: #fffbeb;
          padding: 12px;
          border-radius: 6px;
          font-size: 0.875rem;
        }
      }
    }
  }
}
</style> 