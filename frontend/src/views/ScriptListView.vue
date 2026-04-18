<template>
  <div class="script-list">
    <!-- 店家公告栏 -->
    <div v-if="notices.length > 0" class="notice-bar-container">
      <div class="notice-bar-inner">
        <el-icon class="notice-icon"><WarningFilled /></el-icon>
        <div class="notice-carousel-wrapper">
          <el-carousel 
            height="40px" 
            direction="vertical" 
            :autoplay="true" 
            :interval="4000" 
            indicator-position="none" 
            arrow="never"
          >
            <el-carousel-item v-for="notice in notices" :key="notice.id">
              <div class="notice-item-content">
                <span class="notice-badge">最新</span>
                <span class="notice-text">{{ notice.content }}</span>
              </div>
            </el-carousel-item>
          </el-carousel>
        </div>
      </div>
      <el-button type="text" class="notice-close" @click="notices = []">
        <el-icon><Close /></el-icon>
      </el-button>
    </div>

    <div class="content-wrapper">
      <el-card class="filter-card">
      <div class="filter-container">
        <!-- 搜索框 -->
        <div class="filter-row search-row">
          <el-input
            v-model="filterForm.name"
            placeholder="搜索剧本名称..."
            class="search-input"
            clearable
            @input="handleFilter"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>

        <!-- 分类筛选 -->
        <div class="filter-row">
          <span class="filter-label">类型：</span>
          <el-radio-group v-model="filterForm.type" size="small" @change="handleFilter">
            <el-radio-button :label="''">全部</el-radio-button>
            <el-radio-button label="硬核推理">硬核推理</el-radio-button>
            <el-radio-button label="情感沉浸">情感沉浸</el-radio-button>
            <el-radio-button label="欢乐撕逼">欢乐撕逼</el-radio-button>
            <el-radio-button label="阵营博弈">阵营博弈</el-radio-button>
            <el-radio-button label="恐怖">恐怖</el-radio-button>
          </el-radio-group>
        </div>

        <!-- 人数筛选 -->
        <div class="filter-row">
          <span class="filter-label">人数：</span>
          <el-radio-group v-model="filterForm.peopleNum" size="small" @change="handleFilter" style="margin-right: 15px">
            <el-radio-button :label="null">全部</el-radio-button>
            <el-radio-button :label="5">5人</el-radio-button>
            <el-radio-button :label="6">6人</el-radio-button>
            <el-radio-button :label="7">7人</el-radio-button>
            <el-radio-button :label="8">8人</el-radio-button>
          </el-radio-group>
          <div class="custom-people-input">
            <span class="custom-label">其他：</span>
            <el-input-number 
              v-model="customPeopleInput" 
              :min="1" 
              :max="20"
              size="small" 
              controls-position="right"
              placeholder="人数"
              @change="handleCustomPeople"
              style="width: 90px"
            />
            <span class="unit">人</span>
          </div>
          <el-button type="text" style="margin-left: 10px" @click="resetFilter">重置</el-button>
        </div>

        <!-- 排序功能 -->
        <div class="filter-row sort-row">
          <span class="filter-label">排序：</span>
          <el-button-group>
            <el-button 
              size="small" 
              :type="filterForm.sortField === 'createTime' ? 'primary' : ''"
              @click="handleSort('createTime')"
            >最新发布</el-button>
            <el-button 
              size="small" 
              :type="filterForm.sortField === 'price' ? 'primary' : ''"
              @click="handleSort('price')"
            >
              价格
              <el-icon v-if="filterForm.sortField === 'price'">
                <CaretTop v-if="filterForm.sortOrder === 'asc'" />
                <CaretBottom v-else />
              </el-icon>
            </el-button>
          </el-button-group>
        </div>
      </div>
    </el-card>

    <!-- 推荐剧本 (仅玩家可见且无搜索条件时显示) -->
    <div v-if="showRecommend" class="recommend-section">
      <div class="recommend-header-bar">
        <span class="recommend-title">
          <el-icon class="magic-icon"><MagicStick /></el-icon> 猜你喜欢
        </span>
        <span class="recommend-subtitle">根据您的兴趣定制推荐</span>
      </div>
      <el-row :gutter="20">
        <el-col v-for="script in recommendScripts" :key="'rec-'+script.id" :xs="24" :sm="12" :md="8" :lg="6">
          <el-card :body-style="{ padding: '0px' }" class="script-card recommend-card" shadow="hover">
            <div class="card-image-wrapper" @click="showDetail(script)">
              <img v-if="script.cover" :src="script.cover" class="image">
              <div v-else class="image-placeholder">暂无封面</div>
              <!-- 收藏图标 -->
              <div class="favorite-icon" v-if="user.role === 'PLAYER'" @click.stop="toggleFavorite(script)">
                <el-icon :class="{ 'is-active': script.isFavorite }"><StarFilled /></el-icon>
              </div>
              <div class="recommend-badge">推荐</div>
            </div>
            <div style="padding: 14px">
              <div class="title-row">
                <span class="script-title" @click="showDetail(script)">{{ script.name }}</span>
                <el-rate
                  v-model="script.avgScore"
                  disabled
                  show-score
                  text-color="#ff9900"
                  score-template="{value}"
                  size="small"
                />
              </div>
              <div class="bottom clearfix">
                <el-tag size="small" effect="plain">{{ script.type }}</el-tag>
                <span class="price">￥{{ script.price }}</span>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <div class="script-grid">
      <div class="main-list-header">
        <span class="main-list-title">全部剧本</span>
      </div>
      <el-row :gutter="20">
        <el-col v-for="script in scripts" :key="script.id" :xs="24" :sm="12" :md="8" :lg="6">
          <el-card :body-style="{ padding: '0px' }" class="script-card" shadow="hover">
            <div class="card-image-wrapper" @click="showDetail(script)">
              <img v-if="script.cover" :src="script.cover" class="image">
              <div v-else class="image-placeholder">暂无封面</div>
              <!-- 收藏图标 -->
              <div class="favorite-icon" v-if="user.role === 'PLAYER'" @click.stop="toggleFavorite(script)">
                <el-icon :class="{ 'is-active': script.isFavorite }"><StarFilled /></el-icon>
              </div>
              <!-- 徽标 -->
              <div class="badge-tag badge-new" v-if="isNew(script.createTime)">新品</div>
              <div class="badge-tag badge-hot" v-else-if="script.avgScore >= 4.5">热门</div>
            </div>
            <div style="padding: 14px">
              <div class="title-row">
                <span class="script-title" @click="showDetail(script)">{{ script.name }}</span>
                <el-rate
                  v-model="script.avgScore"
                  disabled
                  show-score
                  text-color="#ff9900"
                  score-template="{value}"
                  size="small"
                />
              </div>
              <div class="bottom clearfix">
                <el-tag size="small" effect="plain">{{ script.type }}</el-tag>
                <span class="people-num">
                  {{ script.peopleNum }}人局 
                  <span v-if="script.minPeople" class="range-text">
                    ({{ script.minPeople === script.maxPeople ? script.minPeople : script.minPeople + '-' + script.maxPeople }}人开局)
                  </span>
                </span>
                <span class="price">￥{{ script.price }}</span>
              </div>
              <div class="card-actions">
                <el-button type="primary" size="small" @click="showDetail(script)">查看详情</el-button>
                <el-button type="success" size="small" @click="handleBooking(script)">查看场次</el-button>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <!-- 剧本详情弹窗 -->
    <el-dialog v-model="detailVisible" title="剧本详情" :width="isMobile ? '95%' : '600px'" top="5vh">
      <div class="script-detail-container">
        <div class="detail-header" :class="{ 'mobile-header': isMobile }">
          <img v-if="currentScript.cover" :src="currentScript.cover" class="detail-cover">
          <div class="detail-info">
            <h2>{{ currentScript.name }}</h2>
            <p><el-tag>{{ currentScript.type }}</el-tag></p>
            <p><strong>建议人数：</strong>{{ currentScript.peopleNum }}人局</p>
            <p v-if="currentScript.minPeople">
              <strong>开局人数：</strong>
              <template v-if="currentScript.minPeople === currentScript.maxPeople">
                {{ currentScript.minPeople }} 人
              </template>
              <template v-else>
                {{ currentScript.minPeople }} - {{ currentScript.maxPeople }} 人
              </template>
            </p>
            <p v-if="currentScript.duration"><strong>时长：</strong>{{ currentScript.duration }} 分钟</p>
            <p><strong>单价：</strong><span class="price-text">￥{{ currentScript.price }}</span></p>
          </div>
        </div>
        <el-divider>剧本简介</el-divider>
        <p class="detail-intro">{{ currentScript.intro }}</p>

        <!-- 评价列表 -->
        <el-divider>玩家评价 ({{ evaluations.length }})</el-divider>
        <div class="evaluation-list">
          <div v-for="evalItem in evaluations" :key="evalItem.id" class="eval-item">
            <div class="eval-user">
              <el-avatar :size="32" :src="evalItem.avatar" />
              <div class="user-meta">
                <span class="nickname">{{ evalItem.nickname || '匿名玩家' }}</span>
                <el-rate :model-value="evalItem.score" disabled size="small" />
              </div>
              <span class="eval-time">{{ formatTime(evalItem.createTime) }}</span>
            </div>
            <p class="eval-content">{{ evalItem.content }}</p>
          </div>
          <el-empty v-if="evaluations.length === 0" description="暂无评价" :image-size="60" />
        </div>

        <div class="detail-actions">
          <el-button type="success" size="large" @click="handleBooking(currentScript)" style="width: 100%; margin-bottom: 10px;">立即预约场次</el-button>
          <el-button size="large" @click="detailVisible = false" style="width: 100%; margin-left: 0;">关闭详情</el-button>
        </div>
      </div>
    </el-dialog>

    <!-- 场次列表弹窗 -->
    <el-dialog v-model="dialogVisible" :title="currentScript.name + ' - 可预约场次'" :width="isMobile ? '95%' : '700px'" top="5vh">
      <el-table :data="sessions" style="width: 100%" size="small">
        <el-table-column label="时间" min-width="120">
          <template #default="scope">
            {{ formatTime(scope.row.sessionTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="remainNum" label="剩余" width="60" align="center" />
        <el-table-column prop="price" label="价格" width="70" align="center" />
        <el-table-column label="操作" width="80" align="center">
          <template #default="scope">
            <el-button v-if="scope.row.remainNum > 0" type="success" size="small" @click="handleReserve(scope.row)">预约</el-button>
            <el-button v-else disabled size="small">已满</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, computed, nextTick } from 'vue'
import request, { baseURL } from '../utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter, useRoute } from 'vue-router'
import { Search, CaretTop, CaretBottom, StarFilled, WarningFilled, MagicStick, Filter, Close } from '@element-plus/icons-vue'
import Masonry from 'masonry-layout'
import imagesLoaded from 'imagesloaded'

const router = useRouter()
const route = useRoute()
const scripts = ref([])
const recommendScripts = ref([])
const sessions = ref([])
const notices = ref([])
const evaluations = ref([])
const dialogVisible = ref(false)
const detailVisible = ref(false)
const currentScript = ref({})
const user = JSON.parse(localStorage.getItem('user') || '{}')
const customPeopleInput = ref(null)
const isMobile = ref(false)
const masonryInstance = ref(null)

// 计算是否显示推荐：只有当没有搜索条件且是玩家且不是查看收藏时才显示
const showRecommend = computed(() => {
  return recommendScripts.value.length > 0 && 
         !filterForm.value.name && 
         !filterForm.value.type && 
         !filterForm.value.peopleNum &&
         route.query.collect !== '1'
})

const initMasonry = () => {
  nextTick(() => {
    const grid = document.querySelector('.masonry-container')
    if (grid) {
      // 销毁旧实例
      if (masonryInstance.value) {
        masonryInstance.value.destroy()
      }
      
      masonryInstance.value = new Masonry(grid, {
        itemSelector: '.masonry-item',
        columnWidth: '.masonry-item',
        percentPosition: true,
        transitionDuration: '0.3s'
      })

      // 图片加载完成后重新布局
      imagesLoaded(grid).on('progress', () => {
        masonryInstance.value.layout()
      })
    }
  })
}

const checkMobile = () => {
  isMobile.value = window.innerWidth <= 768
}

// 统一筛选表单
const filterForm = ref({
  name: '',
  type: '',
  peopleNum: null,
  sortField: 'createTime',
  sortOrder: 'desc'
})

const loadNotices = async () => {
  try {
    const res = await request.get('/notice/list', { silent: true })
    notices.value = res || []
  } catch (e) {
    console.warn('加载公告失败，可能是 notice 表不存在', e)
  }
}

const loadRecommend = async () => {
  if (user.id && user.role === 'PLAYER') {
    try {
      const res = await request.get(`/recommend/user/${user.id}`, { silent: true })
      recommendScripts.value = (res || []).map(s => ({
        ...s,
        isFavorite: false,
        avgScore: 0
      }))
      
      // 加载额外信息
      recommendScripts.value.forEach(s => enrichScript(s))
    } catch (e) {
      console.warn('加载推荐失败', e)
    }
  }
}

const enrichScript = async (s) => {
  try {
    if (user.role === 'PLAYER') {
      const isFav = await request.get('/favorite/check', { 
        params: { userId: user.id, scriptId: s.id },
        silent: true 
      })
      s.isFavorite = isFav
    }
    const evals = await request.get(`/evaluation/script/${s.id}`, { silent: true })
    if (evals && evals.length > 0) {
      const sum = evals.reduce((acc, cur) => acc + cur.score, 0)
      s.avgScore = parseFloat((sum / evals.length).toFixed(1))
    }
  } catch (err) {
    console.warn(`加载剧本[${s.name}]额外信息失败`, err)
  }
}

const loadScripts = async () => {
  try {
    let res;
    if (route.query.collect === '1') {
      res = await request.get('/favorite/my', { params: { userId: user.id } })
    } else {
      res = await request.get('/script/list', { 
        params: { 
          type: filterForm.value.type,
          name: filterForm.value.name,
          peopleNum: filterForm.value.peopleNum,
          sortField: filterForm.value.sortField,
          sortOrder: filterForm.value.sortOrder
        } 
      })
    }
    
    // 立即渲染基础数据，防止页面空白
    scripts.value = (res || []).map(s => ({
      ...s,
      isFavorite: false,
      avgScore: 0
    }))

    // 异步加载额外信息（收藏状态、评分），不阻塞主列表显示
    if (user.id && scripts.value.length > 0) {
      scripts.value.forEach(s => enrichScript(s))
    }
    
  } catch (e) {
    console.error('加载剧本列表失败', e)
    // 只有主列表加载失败才弹出提示，但改为更具体的描述
    ElMessage.error('加载剧本列表失败，请检查数据库 script 表是否已更新字段（duration, min_people, max_people）')
  }
}

// 监听路由变化，处理收藏夹切换
watch(() => route.query.collect, () => {
  loadScripts()
})

onMounted(() => {
  loadScripts()
  loadNotices()
  loadRecommend()
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})

const toggleFavorite = async (script) => {
  if (!user.id) {
    ElMessage.warning('请先登录')
    return
  }
  if (script.isFavorite) {
    await request.delete('/favorite/remove', { params: { userId: user.id, scriptId: script.id } })
    script.isFavorite = false
    ElMessage.success('已取消收藏')
  } else {
    await request.post('/favorite/add', { userId: user.id, scriptId: script.id })
    script.isFavorite = true
    ElMessage.success('收藏成功')
  }
}

// 处理筛选
const handleFilter = () => {
  // 当点击快捷筛选时，清空自定义输入
  customPeopleInput.value = null
  loadScripts()
}

// 处理自定义人数
const handleCustomPeople = (val) => {
  // 当进行自定义输入时，清空单选组
  filterForm.value.peopleNum = val
  loadScripts()
}

const resetFilter = () => {
  filterForm.value.type = ''
  filterForm.value.peopleNum = null
  filterForm.value.name = ''
  customPeopleInput.value = null
  loadScripts()
}

// 处理排序
const handleSort = (field) => {
  if (filterForm.value.sortField === field) {
    // 如果点击同一个字段，则切换顺序
    filterForm.value.sortOrder = filterForm.value.sortOrder === 'asc' ? 'desc' : 'asc'
  } else {
    // 如果点击新字段，默认降序
    filterForm.value.sortField = field
    filterForm.value.sortOrder = 'desc'
  }
  loadScripts()
}

const showDetail = async (script) => {
  currentScript.value = script
  detailVisible.value = true
  evaluations.value = [] // 先清空旧数据
  // 加载评价
  try {
    const res = await request.get(`/evaluation/script/${script.id}`)
    console.log('获取到的评价列表:', res)
    evaluations.value = res || []
  } catch (e) {
    console.error('加载评价失败', e)
  }
}

const handleBooking = async (script) => {
  currentScript.value = script
  const res = await request.get('/booking/session/list', { params: { scriptId: script.id } })
  sessions.value = res
  dialogVisible.value = true
  detailVisible.value = false // 如果是从详情打开，关闭详情
}

const handleReserve = async (session) => {
  if (!user.id) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  if (user.role === 'SHOP') {
    ElMessage.warning('店家账号无法直接预约，请通过“我的剧本”管理场次和预约')
    return
  }
  
  ElMessageBox.prompt('请输入预约人数', '预约确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputPattern: /^[1-9]\d*$/,
    inputErrorMessage: '请输入正整数'
  }).then(async ({ value }) => {
    await request.post('/booking/reserve', {
      sessionId: session.id,
      userId: user.id,
      reserveNum: parseInt(value)
    })
    ElMessage.success('预约申请已提交，等待店家确认')
    dialogVisible.value = false
    loadScripts()
  })
}

const isNew = (time) => {
  if (!time) return false
  const date = new Date(time)
  const now = new Date()
  const diff = now - date
  // 7天内算新品
  return diff < 7 * 24 * 60 * 60 * 1000
}
const formatTime = (time) => {
  return new Date(time).toLocaleString()
}
</script>

<style scoped>
.script-list {
  padding: 0;
  background-color: #f5f7fa;
  min-height: 100vh;
}

/* 公告栏新样式 */
.notice-bar-container {
  background-color: #fdf6ec;
  border-bottom: 1px solid #faecd8;
  margin-bottom: 0;
  position: relative; /* 允许关闭按钮绝对定位 */
}
.notice-bar-inner {
  max-width: 1600px;
  margin: 0 auto;
  padding: 0 20px;
  height: 40px;
  display: flex;
  align-items: center;
}
.content-wrapper {
  max-width: 1600px;
  margin: 0 auto;
  padding: 24px 20px;
}
.notice-icon {
  margin-right: 12px;
  font-size: 18px;
  color: #e6a23c;
}
.notice-carousel-wrapper {
  flex: 1;
  height: 40px;
  overflow: hidden;
}
.notice-item-content {
  display: flex;
  align-items: center;
  height: 40px;
}
.notice-badge {
  background-color: #f56c6c;
  color: white;
  font-size: 12px;
  padding: 2px 6px;
  border-radius: 4px;
  margin-right: 8px;
  font-weight: bold;
}
.notice-text {
  font-size: 14px;
  color: #606266;
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.notice-close {
  color: #909399;
  font-size: 16px;
  padding: 0;
  position: absolute;
  right: 20px;
  top: 0;
  height: 40px;
  display: flex;
  align-items: center;
}
.notice-close:hover {
  color: #606266;
}
/* 推荐区样式微调 */
.recommend-section {
  margin-bottom: 32px;
  padding: 20px;
  background: linear-gradient(to bottom, #fffbf0, #fff);
  border-radius: 12px;
  border: 1px solid #faecd8;
}
.main-list-header {
  margin-bottom: 20px;
  margin-top: 10px;
  display: flex;
  align-items: center;
}
.main-list-title {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
  border-left: 4px solid #409eff;
  padding-left: 12px;
  height: 20px;
  line-height: 20px;
}
.meta-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.people-info {
  font-size: 12px;
  color: #909399;
}
.title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}
.script-title {
  font-size: 16px;
  font-weight: bold;
  color: #303133;
  cursor: pointer;
}
.script-title:hover {
  color: #409eff;
}
.price {
  color: #f56c6c;
  font-weight: bold;
  font-size: 16px;
}
.card-actions {
  margin-top: 12px;
  display: flex;
  justify-content: space-between;
  gap: 10px;
}
.card-actions .el-button {
  flex: 1;
}
.card-image-wrapper {
  width: 100%;
  height: 180px;
  overflow: hidden;
  cursor: pointer;
  background-color: #f5f7fa;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
}
.image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
}
.card-image-wrapper:hover .image {
  transform: scale(1.05);
}
.image-placeholder {
  color: #909399;
  font-size: 14px;
}
.favorite-icon {
  position: absolute;
  top: 10px;
  right: 10px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 50%;
  padding: 6px;
  cursor: pointer;
  z-index: 10;
  display: flex;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.favorite-icon .el-icon {
  font-size: 18px;
  color: #dcdfe6;
}
.favorite-icon .el-icon.is-active {
  color: #ff9900;
}
.recommend-section {
  margin-bottom: 24px;
}
.recommend-header-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}
.magic-icon {
  color: #e6a23c;
  font-size: 20px;
}
.recommend-title {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}
.recommend-subtitle {
  font-size: 13px;
  color: #909399;
}
.recommend-card {
  border: 1px solid #faecd8;
  background: #fdf6ec40;
}
.recommend-badge {
  position: absolute;
  top: 10px;
  left: 0;
  background-color: #f56c6c;
  color: white;
  padding: 2px 8px;
  border-radius: 0 4px 4px 0;
  font-size: 12px;
  font-weight: bold;
  z-index: 10;
  box-shadow: 2px 2px 4px rgba(0,0,0,0.2);
}
.filter-card {
  margin-bottom: 24px;
  background-color: #fcfcfc;
}
.filter-container {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
.filter-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
}
.filter-label {
  font-size: 14px;
  color: #606266;
  width: 60px;
  flex-shrink: 0;
  font-weight: bold;
}
.custom-people-input {
  display: flex;
  align-items: center;
  gap: 8px;
}
.custom-label {
  font-size: 13px;
  color: #909399;
}
.unit {
  font-size: 13px;
  color: #909399;
}
.search-row {
  margin-bottom: 4px;
}
.search-input {
  max-width: 400px;
  width: 100%;
}
.script-grid {
  margin-top: 10px;
}
/* 徽标样式 */
.badge-tag {
  position: absolute;
  top: 0;
  left: 0;
  padding: 2px 8px;
  font-size: 12px;
  color: white;
  border-bottom-right-radius: 8px;
  z-index: 2;
  font-weight: bold;
}
.badge-new {
  background: #f56c6c;
}
.badge-hot {
  background: #e6a23c;
}

</style>
