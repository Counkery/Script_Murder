<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <h2>剧本杀预约平台</h2>
      </template>
      <el-tabs v-model="activeTab">
        <el-tab-pane label="登录" name="login">
          <el-form :model="loginForm" label-width="80px">
            <el-form-item label="手机号">
              <el-input v-model="loginForm.phone" placeholder="请输入手机号"></el-input>
            </el-form-item>
            <el-form-item label="密码">
              <el-input v-model="loginForm.password" type="password" placeholder="请输入密码"></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleLogin" style="width: 100%">登录</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="注册" name="register">
          <el-form :model="registerForm" label-width="80px">
            <el-form-item label="手机号">
              <el-input v-model="registerForm.phone" placeholder="请输入手机号"></el-input>
            </el-form-item>
            <el-form-item label="密码">
              <el-input v-model="registerForm.password" type="password" placeholder="请输入密码"></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="success" @click="handleRegister" style="width: 100%">注册（玩家）</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import request from '../utils/request'
import { ElMessage } from 'element-plus'

const router = useRouter()
const activeTab = ref('login')

const loginForm = ref({
  phone: '',
  password: ''
})

const registerForm = ref({
  phone: '',
  password: '',
  role: 'PLAYER'
})

const handleLogin = async () => {
  if (!loginForm.value.phone || !loginForm.value.password) {
    ElMessage.warning('请填写完整信息')
    return
  }
  const res = await request.post('/user/login', loginForm.value)
  localStorage.setItem('user', JSON.stringify(res.user))
  localStorage.setItem('token', res.token)
  ElMessage.success('登录成功')
  router.push('/scripts')
}

const handleRegister = async () => {
  const { phone, password } = registerForm.value
  if (!phone || !password) {
    ElMessage.warning('请填写完整信息')
    return
  }
  if (!/^\d{6,11}$/.test(phone)) {
    ElMessage.warning('手机号格式不正确')
    return
  }
  await request.post('/user/register', registerForm.value)
  ElMessage.success('注册成功，请登录')
  activeTab.value = 'login'
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #f5f7fa;
}
.login-card {
  width: 400px;
}
h2 {
  text-align: center;
  margin: 0;
  color: #409eff;
}

@media (max-width: 480px) {
  .login-container {
    padding: 0 12px;
  }
  .login-card {
    width: 100%;
  }
}
</style>
