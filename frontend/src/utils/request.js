import axios from 'axios'
import { ElMessage } from 'element-plus'

// --- 修改点：根据当前环境动态获取基础路径 ---
// import.meta.env.VITE_API_BASE_URL 对应你 .env 文件中定义的值
const dynamicBaseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8082'

const request = axios.create({
    // 如果你生产环境 .env.production 里的 VITE_API_BASE_URL 写的是 /api
    // 那么这里直接传 dynamicBaseURL 即可，不需要再拼接 '/api'
    // 建议：统一在 .env 里写完整的路径前缀
    baseURL: dynamicBaseURL, 
    timeout: 5000
})

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers['token'] = token
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(response => {
    const res = response.data
    if (res.code !== 200) {
        if (!response.config.silent) {
            ElMessage.error(res.message || 'Error')
        }
        return Promise.reject(new Error(res.message || 'Error'))
    }
    return res.data
}, error => {
    if (!error.config?.silent) {
        ElMessage.error(error.message)
    }
    return Promise.reject(error)
})

// 导出变量以便其他地方使用（注意：生产环境可能不需要导出这个原始地址）
export { dynamicBaseURL as baseURL } 
export default request