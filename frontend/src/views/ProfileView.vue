<template>
  <div class="profile">
    <el-card class="profile-card">
      <template #header>
        <span>个人中心</span>
      </template>
      <el-form :model="form" label-width="100px">
        <el-form-item label="头像">
          <div class="avatar-row">
            <el-upload
              class="avatar-uploader"
              :show-file-list="false"
              :http-request="handleAvatarUpload"
            >
              <el-avatar :size="64" :src="avatarUrl">
                {{ (form.nickname || '').charAt(0) || '用' }}
              </el-avatar>
            </el-upload>
          </div>
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="form.phone" disabled />
        </el-form-item>
        <el-form-item label="昵称">
          <el-input v-model="form.nickname" />
        </el-form-item>
        <el-form-item label="性别">
          <el-radio-group v-model="form.gender">
            <el-radio label="MALE">男</el-radio>
            <el-radio label="FEMALE">女</el-radio>
            <el-radio label="UNKNOWN">保密</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="年龄">
          <el-input v-model.number="form.age" type="number" placeholder="请输入年龄" />
        </el-form-item>
        <el-form-item label="兴趣爱好">
          <el-checkbox-group v-model="selectedHobbies">
            <el-checkbox label="硬核推理">硬核推理</el-checkbox>
            <el-checkbox label="情感沉浸">情感沉浸</el-checkbox>
            <el-checkbox label="欢乐撕逼">欢乐撕逼</el-checkbox>
            <el-checkbox label="阵营博弈">阵营博弈</el-checkbox>
            <el-checkbox label="恐怖">恐怖</el-checkbox>
            <el-checkbox label="机制">机制</el-checkbox>
            <el-checkbox label="本格">本格</el-checkbox>
            <el-checkbox label="变格">变格</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        <el-form-item label="角色">
          <el-tag>{{ form.role === 'SHOP' ? '店家' : '玩家' }}</el-tag>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleUpdate">修改资料</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import request, { baseURL } from '../utils/request'
import { ElMessage } from 'element-plus'

const user = JSON.parse(localStorage.getItem('user') || '{}')
const form = ref({
  id: user.id,
  phone: user.phone,
  nickname: user.nickname,
  gender: user.gender || 'UNKNOWN',
  age: user.age || null,
  hobbies: user.hobbies || '',
  role: user.role,
  avatar: user.avatar
})

// 将字符串格式的兴趣（如 "硬核,恐怖"）转换为数组
const selectedHobbies = ref(form.value.hobbies ? form.value.hobbies.split(/[,，]/).filter(item => item.trim()) : [])

const avatarUrl = computed(() => {
  if (!form.value.avatar) return ''
  if (form.value.avatar.startsWith('http')) return form.value.avatar
  return baseURL + form.value.avatar
})

const handleUpdate = async () => {
  // 提交前将数组转回逗号分隔的字符串
  form.value.hobbies = selectedHobbies.value.join(',')
  
  await request.put('/user/update', form.value)
  ElMessage.success('资料修改成功')
  localStorage.setItem('user', JSON.stringify(form.value))
}

const handleAvatarUpload = async (options) => {
  const formData = new FormData()
  formData.append('file', options.file)
  try {
    const url = await request.post('/file/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    form.value.avatar = url
    // 立即更新数据库中的头像
    await request.put('/user/update', form.value)
    localStorage.setItem('user', JSON.stringify(form.value))
    ElMessage.success('头像上传并保存成功')
    options.onSuccess && options.onSuccess()
  } catch (e) {
    ElMessage.error('头像上传失败')
    options.onError && options.onError(e)
  }
}
</script>

<style scoped>
.profile {
  padding: 16px;
}
.profile-card {
  width: 500px;
  margin: 0 auto;
}
.avatar-row {
  display: flex;
  align-items: center;
  gap: 16px;
}
.avatar-uploader {
  cursor: pointer;
}

@media (max-width: 768px) {
  .profile-card {
    width: 100%;
  }
}
</style>
