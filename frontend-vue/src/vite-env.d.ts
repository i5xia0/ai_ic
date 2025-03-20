/// <reference types="vite/client" />

// 引入Element Plus的类型定义
// 解决Element Plus组件导入问题
import ElementPlus from 'element-plus'

declare module 'element-plus' {
  export const ElMessage: {
    success: (message: string) => void;
    warning: (message: string) => void;
    info: (message: string) => void;
    error: (message: string) => void;
  };
  
  export const ElMessageBox: any;
  export const ElNotification: any;
  export const ElLoading: any;
} 