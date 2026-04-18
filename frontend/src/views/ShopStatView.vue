<template>
  <div class="shop-stat">
    <el-row :gutter="20">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-item">
            <div class="stat-label">总剧本数</div>
            <div class="stat-value">{{ stat.scriptCount || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-item">
            <div class="stat-label">总场次数</div>
            <div class="stat-value">{{ stat.sessionCount || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-item">
            <div class="stat-label">成交预约</div>
            <div class="stat-value">{{ stat.bookingCount || 0 }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-item">
            <div class="stat-label">累计营收</div>
            <div class="stat-value revenue">￥{{ stat.totalRevenue || 0 }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :xs="24" :lg="12">
        <el-card shadow="hover" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>近七日营收趋势</span>
            </div>
          </template>
          <div ref="revenueChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card shadow="hover" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>剧本类型分布</span>
            </div>
          </template>
          <div ref="typeChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20">
      <el-col :xs="24">
        <el-card shadow="hover" class="chart-card">
          <template #header>
            <div class="card-header">
              <span>剧本热度排行 (Top 5)</span>
            </div>
          </template>
          <div ref="rankChartRef" class="chart-container rank-chart"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 公告管理 (集成在统计页面或单独页面，这里简化集成在管理页) -->
    <el-card class="notice-manage">
      <template #header>
        <div class="card-header">
          <span>公告管理</span>
          <el-button type="primary" size="small" @click="handleAddNotice">发布新公告</el-button>
        </div>
      </template>
      <el-table :data="notices" style="width: 100%">
        <el-table-column prop="content" label="公告内容" />
        <el-table-column prop="createTime" label="发布时间" width="180">
          <template #default="scope">
            {{ formatTime(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100">
          <template #default="scope">
            <el-button type="danger" size="small" link @click="handleDeleteNotice(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 公告弹窗 -->
    <el-dialog v-model="noticeVisible" title="发布公告" width="400px">
      <el-form :model="noticeForm">
        <el-form-item label="内容">
          <el-input v-model="noticeForm.content" type="textarea" :rows="4" placeholder="输入公告内容..." />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="noticeVisible = false">取消</el-button>
        <el-button type="primary" @click="submitNotice">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import request from '../utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'
import * as echarts from 'echarts'

const user = JSON.parse(localStorage.getItem('user') || '{}')
const stat = ref({})
const notices = ref([])
const noticeVisible = ref(false)
const noticeForm = ref({
  shopId: user.id,
  content: ''
})

// 图表相关
const revenueChartRef = ref(null)
const typeChartRef = ref(null)
const rankChartRef = ref(null)
let revenueChart = null
let typeChart = null
let rankChart = null

const initCharts = () => {
  if (revenueChartRef.value) {
    revenueChart = echarts.init(revenueChartRef.value)
  }
  if (typeChartRef.value) {
    typeChart = echarts.init(typeChartRef.value)
  }
  if (rankChartRef.value) {
    rankChart = echarts.init(rankChartRef.value)
  }
}

const updateCharts = () => {
  if (revenueChart && stat.value.revenueTrend) {
    revenueChart.setOption({
      tooltip: { trigger: 'axis' },
      xAxis: { type: 'category', data: stat.value.revenueTrend.map(i => i.date) },
      yAxis: { type: 'value', name: '金额 (元)' },
      series: [{
        data: stat.value.revenueTrend.map(i => i.amount),
        type: 'line',
        smooth: true,
        areaStyle: { opacity: 0.2 },
        itemStyle: { color: '#f56c6c' }
      }]
    })
  }

  if (typeChart && stat.value.typeDistribution) {
    typeChart.setOption({
      tooltip: { trigger: 'item' },
      legend: { bottom: '0', left: 'center' },
      series: [{
        name: '剧本类型',
        type: 'pie',
        radius: ['40%', '70%'],
        avoidLabelOverlap: false,
        itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
        label: { show: false, position: 'center' },
        emphasis: { label: { show: true, fontSize: 16, fontWeight: 'bold' } },
        data: stat.value.typeDistribution
      }]
    })
  }

  if (rankChart && stat.value.scriptRank) {
    rankChart.setOption({
      tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
      grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
      xAxis: { type: 'value', name: '预约人次' },
      yAxis: { 
        type: 'category', 
        data: stat.value.scriptRank.map(i => i.name).reverse() 
      },
      series: [{
        name: '累计预约',
        type: 'bar',
        data: stat.value.scriptRank.map(i => i.value).reverse(),
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
            { offset: 0, color: '#83bff6' },
            { offset: 0.5, color: '#188df0' },
            { offset: 1, color: '#188df0' }
          ])
        },
        label: { show: true, position: 'right' }
      }]
    })
  }
}

const handleResize = () => {
  revenueChart?.resize()
  typeChart?.resize()
  rankChart?.resize()
}

const loadStat = async () => {
  try {
    const res = await request.get(`/stat/shop/${user.id}`)
    stat.value = res || {}
    nextTick(() => {
      updateCharts()
    })
  } catch (e) {
    console.error('加载统计数据失败', e)
  }
}

const loadNotices = async () => {
  try {
    const res = await request.get('/notice/list')
    // 仅显示该店家的公告
    notices.value = (res || []).filter(n => n.shopId === user.id)
  } catch (e) {
    console.error('加载公告失败', e)
  }
}

onMounted(() => {
  if (user.id && user.role === 'SHOP') {
    initCharts()
    loadStat()
    loadNotices()
    window.addEventListener('resize', handleResize)
  }
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  revenueChart?.dispose()
  typeChart?.dispose()
  rankChart?.dispose()
})

const handleAddNotice = () => {
  noticeForm.value.content = ''
  noticeVisible.value = true
}

const submitNotice = async () => {
  if (!noticeForm.value.content) return
  await request.post('/notice/save', noticeForm.value)
  ElMessage.success('发布成功')
  noticeVisible.value = false
  loadNotices()
}

const handleDeleteNotice = (id) => {
  ElMessageBox.confirm('确定删除吗？', '提示').then(async () => {
    await request.delete(`/notice/delete/${id}`)
    ElMessage.success('已删除')
    loadNotices()
  })
}

const formatTime = (time) => {
  return new Date(time).toLocaleString()
}
</script>

<style scoped>
.shop-stat {
  padding: 20px;
}
.stat-card {
  margin-bottom: 20px;
  text-align: center;
}
.stat-item {
  padding: 10px 0;
}
.stat-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 10px;
}
.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
}
.revenue {
  color: #f56c6c;
}
.chart-card {
  margin-bottom: 20px;
}
.chart-container {
  height: 350px;
  width: 100%;
}
.rank-chart {
  height: 400px;
}
.notice-manage {
  margin-top: 20px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
