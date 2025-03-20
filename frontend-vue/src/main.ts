import { createApp } from 'vue'
import App from './App.vue'

// 导入Element Plus样式
import 'element-plus/es/components/message/style/css'
import 'element-plus/es/components/message-box/style/css'
import 'element-plus/es/components/notification/style/css'
import 'element-plus/es/components/loading/style/css'

// Element Plus 图标
import * as ElementPlusIcons from '@element-plus/icons-vue'

// 样式
import './assets/main.scss'

// 创建Vue应用
const app = createApp(App)

// 注册所有 Element Plus 图标
for (const [key, component] of Object.entries(ElementPlusIcons)) {
  app.component(key, component)
}

app.mount('#app') 