// API 请求封装
import config from '@/config/env.js'

const { baseURL, apiTimeout, enableLog } = config

/**
 * 封装的请求方法
 * @param {Object} options - 请求配置
 * @returns {Promise}
 */
export function request(options) {
  const {
    url,
    method = 'GET',
    data = {},
    header = {},
    showLoading = false,
    loadingText = '加载中...'
  } = options

  // 显示加载提示
  if (showLoading) {
    uni.showLoading({ title: loadingText })
  }

  // 完整URL
  const fullUrl = url.startsWith('http') ? url : `${baseURL}${url}`

  if (enableLog) {
    console.log(`[API请求] ${method} ${fullUrl}`, data)
  }

  return new Promise((resolve, reject) => {
    uni.request({
      url: fullUrl,
      method: method.toUpperCase(),
      data,
      header: {
        'content-type': 'application/json',
        ...header
      },
      timeout: apiTimeout,
      success: (res) => {
        if (enableLog) {
          console.log(`[API响应] ${method} ${fullUrl}`, res.data)
        }

        // 统一处理响应
        if (res.statusCode === 200) {
          if (res.data.code === 200) {
            resolve(res.data)
          } else {
            // 业务错误
            uni.showToast({
              title: res.data.message || '请求失败',
              icon: 'none'
            })
            reject(res.data)
          }
        } else {
          // HTTP错误
          uni.showToast({
            title: `服务器错误: ${res.statusCode}`,
            icon: 'none'
          })
          reject(res)
        }
      },
      fail: (err) => {
        console.error(`[API错误] ${method} ${fullUrl}`, err)
        uni.showToast({
          title: '网络请求失败',
          icon: 'none'
        })
        reject(err)
      },
      complete: () => {
        if (showLoading) {
          uni.hideLoading()
        }
      }
    })
  })
}

// 快捷方法
export const get = (url, data = {}, options = {}) => {
  return request({ url, method: 'GET', data, ...options })
}

export const post = (url, data = {}, options = {}) => {
  return request({ url, method: 'POST', data, ...options })
}

export const put = (url, data = {}, options = {}) => {
  return request({ url, method: 'PUT', data, ...options })
}

export const del = (url, data = {}, options = {}) => {
  return request({ url, method: 'DELETE', data, ...options })
}

export default request
