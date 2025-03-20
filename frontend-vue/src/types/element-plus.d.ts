// Element Plus相关类型声明
declare module 'element-plus' {
  export interface UploadFile {
    name: string;
    percentage?: number;
    status: string;
    size: number;
    raw: File;
    url?: string;
    type?: string;
  }
  
  export type UploadFiles = UploadFile[];
}

declare module 'element-plus/es/components/upload/src/upload' {
  import { UploadFile, UploadFiles } from 'element-plus';
  
  export type UploadRawFile = File;
  
  export interface ElUploadProgressEvent extends ProgressEvent {
    percent?: number;
  }
  
  export interface ElUploadInternalRawFile extends File {
    uid: number;
  }
  
  export interface ElUploadAjaxError extends Error {
    status: number;
    method: string;
    url: string;
  }
  
  export interface ElUploadRequestOptions {
    action: string;
    method: string;
    data: Record<string, string | Blob | [string | Blob, string]>;
    filename: string;
    file: ElUploadInternalRawFile;
    headers: Headers | Record<string, string>;
    onError: (e: Error) => void;
    onProgress: (e: ElUploadProgressEvent) => void;
    onSuccess: (response: any) => void;
    withCredentials: boolean;
  }
}

// 声明全局类型，使自动导入的Element Plus组件在TypeScript中可用
declare module 'vue' {
  export interface GlobalComponents {
    ElButton: typeof import('element-plus')['ElButton']
    ElInput: typeof import('element-plus')['ElInput'] 
    ElSwitch: typeof import('element-plus')['ElSwitch']
    ElIcon: typeof import('element-plus')['ElIcon']
    ElUpload: typeof import('element-plus')['ElUpload']
    ElMessage: typeof import('element-plus')['ElMessage']
    ElEmpty: typeof import('element-plus')['ElEmpty']
    ElSkeleton: typeof import('element-plus')['ElSkeleton']
    ElProgress: typeof import('element-plus')['ElProgress']
    // 其他需要的组件...
  }
}

// 声明全局组件，使它们在TypeScript中可用
declare global {
  const ElMessage: typeof import('element-plus')['ElMessage']
  const ElMessageBox: typeof import('element-plus')['ElMessageBox']
  const ElNotification: typeof import('element-plus')['ElNotification']
  const ElLoading: typeof import('element-plus')['ElLoading']
} 