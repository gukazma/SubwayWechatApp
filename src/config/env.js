// 环境配置文件

const ENV_CONFIG = {
  development: {
    baseURL: 'http://localhost:3000/api',
    apiTimeout: 10000,
    enableLog: true
  },
  production: {
    baseURL: 'https://your-api-domain.com/api', // 替换为您的生产环境域名
    apiTimeout: 30000,
    enableLog: false
  }
}

// 获取当前环境 (可以通过编译时注入或手动切换)
const getCurrentEnv = () => {
  // 方式1: 手动切换 (开发时使用)
  // return 'development'

  // 方式2: 根据编译命令自动切换
  // uni-app 在不同平台编译时可以通过 manifest.json 或构建配置来设置

  // 方式3: 根据域名判断 (H5可用)
  if (typeof window !== 'undefined') {
    const hostname = window.location.hostname
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return 'development'
    }
  }

  // 默认开发环境
  return process.env.NODE_ENV === 'production' ? 'production' : 'development'
}

const currentEnv = getCurrentEnv()
const config = ENV_CONFIG[currentEnv]

console.log(`[环境配置] 当前环境: ${currentEnv}`)
console.log(`[环境配置] API地址: ${config.baseURL}`)

export default config
