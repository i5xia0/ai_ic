// 全局配置
const CONFIG = {
    // API服务器基础URL - 根据不同环境设置不同的URL
    baseURL: 'http://localhost:8000',  
    
    // 默认提示词前缀
    defaultPromptPrefix: '图片中不要出现文字。',
    
    // 图片配置
    image: {
        maxWidth: 1024,
        maxHeight: 768,
        format: 'jpeg'
    }
}; 