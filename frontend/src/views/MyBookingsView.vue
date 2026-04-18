<template>
  <div class="my-bookings">
    <el-card>
      <template #header>
        <div class="header-with-tip">
          <div class="title-row">
            <span>{{ user.role === 'SHOP' ? '所有预约管理' : '我的预约记录' }}</span>
            <span class="tip" v-if="user.role === 'SHOP'">
              提示：请在开局前根据实际人数，手动“确认”或“拒绝”每一条预约。
            </span>
          </div>
          <!-- 筛选区域 -->
          <div v-if="user.role === 'SHOP'" class="filter-bar">
            <el-radio-group v-model="filterStatus" size="small" @change="loadBookings">
              <el-radio-button :label="null">全部</el-radio-button>
              <el-radio-button :label="0">待确认</el-radio-button>
              <el-radio-button :label="1">已确认</el-radio-button>
              <el-radio-button :label="2">已取消/拒绝</el-radio-button>
            </el-radio-group>
          </div>
        </div>
      </template>
      <!-- 移动端：卡片式列表 -->
      <div v-if="isMobile" class="mobile-card-list">
        <el-card v-for="item in bookings" :key="item.id" class="mobile-booking-card" shadow="never">
          <div class="card-content">
            <div class="card-header-row">
              <span class="script-name">{{ item.scriptName || '加载中...' }}</span>
              <el-tag :type="statusType(item.status)" size="small" effect="dark">
                {{ statusText(item.status) }}
              </el-tag>
            </div>
            
            <div class="info-item">
              <el-icon><Calendar /></el-icon>
              <span>{{ formatTime(item.sessionTime) }}</span>
            </div>
            
            <div class="info-item">
              <el-icon><User /></el-icon>
              <span>预约人数：{{ item.reserveNum }} 人</span>
            </div>

            <div v-if="user.role === 'SHOP'" class="user-detail">
              <div class="info-item">
                <el-icon><Avatar /></el-icon>
                <span>{{ item.userNickname }}</span>
              </div>
              <div class="info-item">
                <el-icon><Phone /></el-icon>
                <a :href="'tel:' + item.userPhone" class="phone-link">{{ item.userPhone }}</a>
              </div>
            </div>

            <div class="info-item time-info">
              <span>申请时间：{{ formatTimeShort(item.createTime) }}</span>
            </div>

            <div class="card-actions-row">
              <!-- 评价操作：仅已确认且未评价过显示 -->
              <template v-if="user.role === 'PLAYER' && item.status === 1 && (item.hasEvaluated === 0 || item.hasEvaluated === null)">
                <el-button type="primary" size="small" plain @click="openEvaluation(item)">评价剧本</el-button>
              </template>

              <!-- 玩家操作 -->
              <template v-if="user.role === 'PLAYER' && (item.status === 0 || item.status === 1)">
                <el-button 
                  type="danger" 
                  size="small" 
                  plain 
                  style="width: 100%"
                  :disabled="!canCancel(item.createTime)"
                  @click="handleStatus(item.id, 2)"
                >
                  {{ canCancel(item.createTime) ? '取消预约 (' + getCancelTimeLeft(item.createTime) + ')' : '超过15分钟不可取消' }}
                </el-button>
              </template>

              <!-- 店家操作 -->
              <template v-if="user.role === 'SHOP' && item.status === 0">
                <el-button type="success" size="small" @click="handleStatus(item.id, 1)">确认预约</el-button>
                <el-button type="danger" size="small" plain @click="handleStatus(item.id, 2)">拒绝预约</el-button>
              </template>
            </div>
          </div>
        </el-card>
        <el-empty v-if="bookings.length === 0" description="暂无预约记录" />
      </div>

      <!-- PC 端：表格展示 -->
      <div v-else class="table-wrapper">
        <el-table :data="bookings" style="width: 100%" border stripe size="small">
          <el-table-column label="剧本信息" min-width="150">
            <template #default="scope">
              <div class="script-info">
                <span class="script-name">{{ scope.row.scriptName || '加载中...' }}</span>
                <span class="session-time">{{ formatTime(scope.row.sessionTime) }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column v-if="user.role === 'SHOP'" label="用户信息" min-width="120">
            <template #default="scope">
              <div class="user-info-cell">
                <span>{{ scope.row.userNickname }}</span>
                <span class="phone">{{ scope.row.userPhone }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="reserveNum" label="人数" width="50" align="center" />
          <el-table-column label="状态" width="100" align="center">
            <template #default="scope">
              <el-tooltip
                v-if="scope.row.status === 3"
                content="该场次因开局前15分钟人数未达标已自动取消"
                placement="top"
              >
                <el-tag :type="statusType(scope.row.status)" effect="dark" class="status-tag" size="small">
                  不足
                  <el-icon><InfoFilled /></el-icon>
                </el-tag>
              </el-tooltip>
              <el-tag v-else :type="statusType(scope.row.status)" effect="dark" size="small">
                {{ statusText(scope.row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="申请时间" width="140">
            <template #default="scope">
              <span class="create-time">{{ formatTimeShort(scope.row.createTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" :width="isMobile ? '110' : '220'" fixed="right" align="center">
            <template #default="scope">
              <!-- 评价操作：仅已确认且未评价过显示 -->
              <template v-if="user.role === 'PLAYER' && scope.row.status === 1 && (scope.row.hasEvaluated === 0 || scope.row.hasEvaluated === null)">
                <el-button type="primary" size="small" plain @click="openEvaluation(scope.row)">评价</el-button>
              </template>

              <!-- 玩家：仅待确认或已确认且在15分钟内可取消 -->
              <template v-if="user.role === 'PLAYER' && (scope.row.status === 0 || scope.row.status === 1)">
                <div class="cancel-container">
                  <el-button 
                    type="danger" 
                    size="small" 
                    plain
                    :disabled="!canCancel(scope.row.createTime)"
                    @click="handleStatus(scope.row.id, 2)"
                  >取消</el-button>
                  <span class="cancel-tip" v-if="canCancel(scope.row.createTime)">
                    {{ getCancelTimeLeft(scope.row.createTime) }}
                  </span>
                  <span class="cancel-expired" v-else>不可取消</span>
                </div>
              </template>
              
              <!-- 店家：待确认可确认或取消 -->
              <template v-if="user.role === 'SHOP' && scope.row.status === 0">
                <div class="action-buttons">
                  <el-button type="success" size="small" @click="handleStatus(scope.row.id, 1)">确认</el-button>
                  <el-button type="danger" size="small" plain @click="handleStatus(scope.row.id, 2)">拒绝</el-button>
                </div>
              </template>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-card>

    <!-- 评价弹窗 -->
    <el-dialog v-model="evalVisible" title="评价剧本" width="400px">
      <el-form :model="evalForm" label-width="80px">
        <el-form-item label="评分">
          <el-rate v-model="evalForm.score" show-score />
        </el-form-item>
        <el-form-item label="内容">
          <el-input v-model="evalForm.content" type="textarea" :rows="3" placeholder="写下你的游玩体验吧..." />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="evalVisible = false">取消</el-button>
        <el-button type="primary" @click="submitEvaluation">提交评价</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import request from '../utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'
import { InfoFilled, Calendar, User, Avatar, Phone } from '@element-plus/icons-vue'

const user = JSON.parse(localStorage.getItem('user') || '{}')
const bookings = ref([])
const filterStatus = ref(null) // 店家筛选状态
const isMobile = ref(false)

// 评价相关
const evalVisible = ref(false)
const evalForm = ref({
  scriptId: null,
  userId: user.id,
  score: 5,
  content: ''
})

const openEvaluation = (row) => {
  evalForm.value = {
    scriptId: row.scriptId,
    bookingId: row.id, // 关联预约ID
    userId: user.id,
    score: 5,
    content: ''
  }
  evalVisible.value = true
}

const submitEvaluation = async () => {
  if (!evalForm.value.scriptId || !evalForm.value.bookingId) {
    ElMessage.error('评价失败：信息缺失')
    return
  }
  try {
    await request.post('/evaluation/add', evalForm.value)
    ElMessage.success('感谢评价！')
    evalVisible.value = false
    loadBookings() // 刷新列表，隐藏评价按钮
  } catch (e) {
    // 错误信息已由拦截器处理
  }
}

const checkMobile = () => {
  isMobile.value = window.innerWidth <= 768
}

const loadBookings = async () => {
  try {
    let url = user.role === 'SHOP' 
      ? `/booking/shop/list?shopId=${user.id}${filterStatus.value !== null ? '&status=' + filterStatus.value : ''}` 
      : `/booking/my?userId=${user.id}`
    const res = await request.get(url)
    bookings.value = res || []
  } catch (e) {
    console.error('加载预约失败', e)
    ElMessage.error('加载预约记录失败')
  }
}

// 是否可以取消（15分钟内）
const canCancel = (createTime) => {
  if (!createTime) return false
  const now = new Date()
  const create = new Date(createTime)
  const diff = (now - create) / 1000 / 60
  return diff <= 15
}

// 获取剩余取消时间
const getCancelTimeLeft = (createTime) => {
  if (!createTime) return ''
  const now = new Date()
  const create = new Date(createTime)
  const diff = Math.floor((15 * 60 * 1000 - (now - create)) / 1000)
  if (diff <= 0) return ''
  const m = Math.floor(diff / 60)
  const s = diff % 60
  return `剩余 ${m}:${s < 10 ? '0' + s : s}`
}

// 刷新倒计时
const timer = ref(null)
onMounted(() => {
  if (user.id) {
    loadBookings()
    checkMobile()
    window.addEventListener('resize', checkMobile)
    timer.value = setInterval(() => {
      // 触发视图更新
      bookings.value = [...bookings.value]
    }, 1000)
  }
})

onUnmounted(() => {
  if (timer.value) clearInterval(timer.value)
  window.removeEventListener('resize', checkMobile)
})

const handleStatus = (id, status) => {
  const action = status === 1 ? '确认' : '取消/拒绝'
  ElMessageBox.confirm(`确定要${action}该预约吗？`, '提示').then(async () => {
    await request.post(`/booking/confirm/${id}?status=${status}`)
    ElMessage.success('操作成功')
    loadBookings()
  })
}

const statusText = (status) => {
  const map = { 0: '待确认', 1: '已确认', 2: '已取消/拒绝', 3: '人数不足取消' }
  return map[status] || '未知'
}

const statusType = (status) => {
  const map = { 0: 'warning', 1: 'success', 2: 'info', 3: 'danger' }
  return map[status] || ''
}

const formatTime = (time) => {
  return new Date(time).toLocaleString()
}

const formatTimeShort = (time) => {
  const d = new Date(time)
  return `${d.getMonth() + 1}/${d.getDate()} ${d.getHours()}:${d.getMinutes() < 10 ? '0' + d.getMinutes() : d.getMinutes()}`
}
</script>

<style scoped>
.my-bookings {
  padding: 20px;
}
.mobile-card-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.mobile-booking-card {
  border-radius: 8px;
  border: 1px solid #ebeef5;
}
.mobile-booking-card .card-content {
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.card-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f0f0f0;
  padding-bottom: 8px;
  margin-bottom: 4px;
}
.card-header-row .script-name {
  font-weight: bold;
  font-size: 16px;
  color: #303133;
}
.info-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #606266;
}
.info-item .el-icon {
  color: #909399;
}
.time-info {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}
.user-detail {
  background-color: #f9f9f9;
  padding: 8px;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.phone-link {
  color: #409eff;
  text-decoration: none;
}
.card-actions-row {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 8px;
  border-top: 1px solid #f0f0f0;
  padding-top: 12px;
}
.card-actions-row .el-button {
  flex: 1;
}
.table-wrapper {
  overflow-x: auto;
}
.header-with-tip {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.title-row {
  display: flex;
  flex-direction: column;
}
.filter-bar {
  margin-left: 20px;
}
.cancel-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}
.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.cancel-tip {
  font-size: 12px;
  color: #e6a23c;
}
.cancel-expired {
  font-size: 12px;
  color: #f56c6c;
}
.status-tag {
  display: flex;
  align-items: center;
  gap: 4px;
  cursor: help;
}
.tip {
  margin-top: 4px;
  font-size: 13px;
  color: #909399;
}
.script-info, .user-info-cell {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.script-name {
  font-weight: bold;
  color: #303133;
}
.session-time, .phone, .create-time {
  font-size: 12px;
  color: #606266;
}
.phone::before {
  content: '📞 ';
}

@media (max-width: 768px) {
  .header-with-tip {
    align-items: flex-start;
  }
}
</style>
