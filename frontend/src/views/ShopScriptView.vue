<template>
  <div class="shop-scripts">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>我的剧本管理</span>
          <el-button type="primary" @click="handleAdd">发布新剧本</el-button>
        </div>
      </template>
      <!-- 移动端：卡片式列表 -->
      <div v-if="isMobile" class="mobile-card-list">
        <el-card v-for="item in scripts" :key="item.id" class="mobile-script-card" shadow="never">
          <div class="card-content">
            <div class="card-header-row">
              <span class="script-name">{{ item.name }}</span>
              <el-tag size="small">{{ item.type }}</el-tag>
            </div>
            
            <div class="info-row">
              <div class="info-item">
                <el-icon><User /></el-icon>
                <span>建议：{{ item.peopleNum }}人</span>
              </div>
              <div class="info-item">
                <el-icon><Timer /></el-icon>
                <span>时长：{{ item.duration }}min</span>
              </div>
            </div>

            <div class="info-row">
              <div class="info-item">
                <el-icon><Histogram /></el-icon>
                <span>开局：{{ item.minPeople }}-{{ item.maxPeople }}人</span>
              </div>
              <div class="info-item price-item">
                <el-icon><Money /></el-icon>
                <span class="price-val">￥{{ item.price }}</span>
              </div>
            </div>

            <div class="card-actions-row">
              <el-button size="small" @click="handleEdit(item)">编辑</el-button>
              <el-button size="small" type="success" @click="handleSession(item)">场次</el-button>
              <el-button size="small" type="danger" plain @click="handleDelete(item.id)">删除</el-button>
            </div>
          </div>
        </el-card>
        <el-empty v-if="scripts.length === 0" description="暂无剧本" />
      </div>

      <!-- PC 端：表格展示 -->
      <div v-else class="table-wrapper">
        <el-table :data="scripts" style="width: 100%">
          <el-table-column prop="name" label="名称" min-width="120" />
          <el-table-column prop="type" label="类型" width="90" />
          <el-table-column prop="peopleNum" label="人数" width="60" />
          <el-table-column prop="price" label="价格" width="70" />
          <el-table-column label="操作" :width="isMobile ? '180' : '250'" fixed="right">
            <template #default="scope">
              <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
              <el-button size="small" type="success" @click="handleSession(scope.row)">场次</el-button>
              <el-button size="small" type="danger" @click="handleDelete(scope.row.id)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-card>

    <!-- 剧本编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑剧本' : '发布剧本'" :width="isMobile ? '95%' : '600px'" top="5vh">
      <el-form ref="formRef" :model="form" :rules="rules" :label-width="isMobile ? '80px' : '100px'">
        <el-form-item label="封面" prop="cover">
          <el-upload
            class="cover-uploader"
            :show-file-list="false"
            :http-request="handleCoverUpload"
          >
            <img v-if="form.cover" :src="form.cover" class="cover-preview" />
            <el-icon v-else class="cover-uploader-icon"><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">建议尺寸 3:4，支持 jpg/png</div>
        </el-form-item>
        <el-form-item label="剧本名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入剧本名称" />
        </el-form-item>
        <el-form-item label="类型" prop="type">
          <el-select v-model="form.type" placeholder="选择类型" style="width: 100%">
            <el-option label="硬核推理" value="硬核推理" />
            <el-option label="情感沉浸" value="情感沉浸" />
            <el-option label="欢乐撕逼" value="欢乐撕逼" />
            <el-option label="阵营博弈" value="阵营博弈" />
          </el-select>
        </el-form-item>
        <el-form-item label="建议人数" prop="peopleNum">
          <el-input-number v-model="form.peopleNum" :min="1" />
        </el-form-item>
        <el-form-item label="剧本时长" prop="duration">
          <el-input-number v-model="form.duration" :min="1" />
          <span style="margin-left: 10px">分钟</span>
        </el-form-item>
        <el-form-item label="开局人数" required>
          <div style="display: flex; align-items: center; gap: 5px; flex-wrap: wrap;">
            <el-form-item prop="minPeople" style="margin-bottom: 0">
              <el-input-number v-model="form.minPeople" :min="1" placeholder="最低" style="width: 110px" />
            </el-form-item>
            <span v-if="!isMobile">-</span>
            <el-form-item prop="maxPeople" style="margin-bottom: 0">
              <el-input-number v-model="form.maxPeople" :min="1" placeholder="最高" style="width: 110px" />
            </el-form-item>
          </div>
        </el-form-item>
        <el-form-item label="价格" prop="price">
          <el-input-number v-model="form.price" :min="0" />
        </el-form-item>
        <el-form-item label="简介" prop="intro">
          <el-input v-model="form.intro" type="textarea" :rows="4" placeholder="请输入剧本简介" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>

    <!-- 发布场次弹窗 -->
    <el-dialog v-model="sessionVisible" title="发布场次" :width="isMobile ? '95%' : '450px'" top="5vh">
      <el-form ref="sessionFormRef" :model="sessionForm" :rules="sessionRules" :label-width="isMobile ? '80px' : '100px'">
        <el-form-item label="剧本">
          <span class="script-name-display">{{ currentScript.name }}</span>
        </el-form-item>
        <el-form-item label="场次时间" prop="sessionTime">
          <el-date-picker 
            v-model="sessionForm.sessionTime" 
            type="datetime" 
            placeholder="选择开局时间" 
            style="width: 100%"
            :disabled-date="disabledPastDates"
          />
        </el-form-item>
        <el-form-item label="默认人数">
          <span>{{ currentScript.peopleNum }} 人 (跟随设定)</span>
        </el-form-item>
        <el-form-item label="默认价格">
          <span>￥{{ currentScript.price }} (跟随设定)</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="sessionVisible = false">取消</el-button>
        <el-button type="primary" @click="submitSession">确认发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import request, { baseURL } from '../utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, User, Timer, Histogram, Money } from '@element-plus/icons-vue'

const user = JSON.parse(localStorage.getItem('user') || '{}')
const scripts = ref([])
const dialogVisible = ref(false)
const sessionVisible = ref(false)
const currentScript = ref({})
const formRef = ref(null)
const sessionFormRef = ref(null)
const isMobile = ref(false)

const checkMobile = () => {
  isMobile.value = window.innerWidth <= 768
}

const form = ref({
  id: null,
  shopId: user.id,
  name: '',
  type: '',
  peopleNum: 6,
  duration: 240,
  minPeople: 6,
  maxPeople: 6,
  price: 0,
  intro: '',
  cover: ''
})

const rules = {
  cover: [{ required: true, message: '请上传剧本封面', trigger: 'change' }],
  name: [{ required: true, message: '请输入剧本名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择剧本类型', trigger: 'change' }],
  peopleNum: [{ required: true, message: '请输入建议人数', trigger: 'blur' }],
  duration: [{ required: true, message: '请输入剧本时长', trigger: 'blur' }],
  minPeople: [{ required: true, message: '请输入最低开局人数', trigger: 'blur' }],
  maxPeople: [{ required: true, message: '请输入最高开局人数', trigger: 'blur' }],
  price: [{ required: true, message: '请输入价格', trigger: 'blur' }],
  intro: [{ required: true, message: '请输入剧本简介', trigger: 'blur' }]
}

const sessionForm = ref({
  scriptId: null,
  shopId: user.id,
  sessionTime: '',
  totalNum: 6,
  price: 0
})

const sessionRules = {
  sessionTime: [{ required: true, message: '请选择开局时间', trigger: 'change' }]
}

const loadScripts = async () => {
  try {
    const res = await request.get(`/script/shop/${user.id}`)
    scripts.value = res || []
  } catch (e) {
    console.error('加载剧本列表失败', e)
  }
}

const disabledPastDates = (time) => {
  return time.getTime() < Date.now() - 8.64e7 // 禁止选择今天之前的日期
}

onMounted(() => {
  loadScripts()
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})

const handleAdd = () => {
  form.value = { 
    id: null, 
    shopId: user.id, 
    name: '', 
    type: '', 
    peopleNum: 6, 
    duration: 240,
    minPeople: 6,
    maxPeople: 6,
    price: 0, 
    intro: '', 
    cover: '' 
  }
  if (formRef.value) formRef.value.clearValidate()
  dialogVisible.value = true
}

const handleEdit = async (row) => {
  // 从后端获取最新数据，确保数据是最新的
  try {
    const res = await request.get(`/script/detail/${row.id}`)
    form.value = { ...res }
    if (formRef.value) formRef.value.clearValidate()
    dialogVisible.value = true
  } catch (e) {
    ElMessage.error('获取剧本详情失败')
  }
}

const handleCoverUpload = async (options) => {
  const formData = new FormData()
  formData.append('file', options.file)
  try {
    const url = await request.post('/file/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    form.value.cover = url
    // 上传成功后清除封面的校验提示
    if (formRef.value) formRef.value.validateField('cover')
    ElMessage.success('封面上传成功')
  } catch (e) {
    ElMessage.error('封面上传失败')
  }
}

const handleDelete = (id) => {
  ElMessageBox.confirm('确定删除该剧本吗？', '提示').then(async () => {
    await request.delete(`/script/delete/${id}`)
    ElMessage.success('删除成功')
    loadScripts()
  })
}

const submitForm = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      if (form.value.minPeople > form.value.maxPeople) {
        ElMessage.warning('最低人数不能大于最高人数')
        return
      }
      await request.post('/script/save', form.value)
      ElMessage.success('操作成功')
      dialogVisible.value = false
      loadScripts()
    }
  })
}

const handleSession = (script) => {
  currentScript.value = script
  sessionForm.value = {
    scriptId: script.id,
    shopId: user.id,
    sessionTime: '',
    totalNum: script.peopleNum,
    price: script.price
  }
  if (sessionFormRef.value) sessionFormRef.value.clearValidate()
  sessionVisible.value = true
}

const submitSession = async () => {
  if (!sessionFormRef.value) return
  await sessionFormRef.value.validate(async (valid) => {
    if (valid) {
      await request.post('/booking/session/save', sessionForm.value)
      ElMessage.success('场次发布成功')
      sessionVisible.value = false
    }
  })
}
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.table-wrapper {
  overflow-x: auto;
}

.mobile-card-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.mobile-script-card {
  border-radius: 8px;
  border: 1px solid #ebeef5;
}

.mobile-script-card .card-content {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.card-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 8px;
}

.card-header-row .script-name {
  font-weight: bold;
  font-size: 16px;
  color: #303133;
}

.info-row {
  display: flex;
  justify-content: space-between;
  gap: 10px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #606266;
  flex: 1;
}

.info-item .el-icon {
  color: #909399;
}

.price-item {
  justify-content: flex-end;
}

.price-val {
  color: #f56c6c;
  font-weight: bold;
  font-size: 15px;
}

.card-actions-row {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  margin-top: 4px;
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
}

.card-actions-row .el-button {
  flex: 1;
}

.script-name-display {
  font-weight: bold;
  color: #409eff;
}

.cover-uploader {
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  width: 120px;
  height: 160px;
  display: flex;
  justify-content: center;
  align-items: center;
  transition: border-color 0.3s;
}

.cover-uploader:hover {
  border-color: #409eff;
}

.cover-uploader-icon {
  font-size: 28px;
  color: #8c939d;
}

.cover-preview {
  width: 120px;
  height: 160px;
  display: block;
  object-fit: cover;
}

.upload-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 5px;
  line-height: 1.2;
}

@media (max-width: 768px) {
  .card-header {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
  .card-header .el-button {
    width: 100%;
  }
}
</style>
