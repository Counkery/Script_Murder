<template>
  <!-- 登录页使用全屏简单布局，其它页面使用带侧边栏的主布局 -->
  <div v-if="route.path === '/login'" class="fullpage-container">
    <router-view />
  </div>
  <el-container v-else class="layout-container">
    <el-header class="header">
      <div class="header-left">
        <el-button 
          v-if="isMobile" 
          class="menu-toggle" 
          :icon="MenuIcon" 
          circle 
          @click="drawerVisible = true" 
        />
        <div class="logo">剧本杀预约平台</div>
      </div>
      <div class="user-info">
        <div v-if="user.nickname" class="user-brief">
          <el-avatar
            v-if="user.avatar"
            :size="24"
            :src="user.avatar.startsWith('http') ? user.avatar : baseURL + user.avatar"
            style="margin-right: 4px"
          />
          <span v-if="!isMobile">欢迎, {{ user.nickname }}</span>
        </div>
        <el-button v-if="user.id" type="danger" size="small" @click="handleLogout" :plain="isMobile">退出</el-button>
        <el-button v-else type="primary" size="small" @click="router.push('/login')">登录</el-button>
      </div>
    </el-header>

    <el-container class="main-container">
      <!-- PC 端侧边栏 -->
      <el-aside v-if="!isMobile" width="200px" class="aside">
        <el-menu
          :default-active="route.path"
          class="el-menu-vertical"
          router
        >
          <el-menu-item index="/scripts">
            <el-icon><MenuIcon /></el-icon>
            <span>剧本列表</span>
          </el-menu-item>
          <el-menu-item v-if="user.id" index="/bookings">
            <el-icon><Calendar /></el-icon>
            <span>{{ user.role === 'SHOP' ? '预约管理' : '我的预约' }}</span>
          </el-menu-item>
          <el-menu-item v-if="user.role === 'SHOP'" index="/shop-scripts">
            <el-icon><Document /></el-icon>
            <span>我的剧本</span>
          </el-menu-item>
          <el-menu-item v-if="user.role === 'SHOP'" index="/shop-stat">
            <el-icon><DataLine /></el-icon>
            <span>数据公告</span>
          </el-menu-item>
          <el-menu-item v-if="user.role === 'PLAYER'" index="/scripts?collect=1">
            <el-icon><Star /></el-icon>
            <span>我的收藏</span>
          </el-menu-item>
          <el-menu-item v-if="user.id" index="/profile">
            <el-icon><User /></el-icon>
            <span>个人中心</span>
          </el-menu-item>
        </el-menu>
      </el-aside>

      <!-- 移动端抽屉菜单 -->
      <el-drawer
        v-if="isMobile"
        v-model="drawerVisible"
        direction="ltr"
        size="240px"
        :with-header="false"
      >
        <div class="drawer-logo">剧本杀预约平台</div>
        <el-menu
          :default-active="route.path"
          class="el-menu-drawer"
          router
          @select="drawerVisible = false"
        >
          <el-menu-item index="/scripts">
            <el-icon><MenuIcon /></el-icon>
            <span>剧本列表</span>
          </el-menu-item>
          <el-menu-item v-if="user.id" index="/bookings">
            <el-icon><Calendar /></el-icon>
            <span>{{ user.role === 'SHOP' ? '预约管理' : '我的预约' }}</span>
          </el-menu-item>
          <el-menu-item v-if="user.role === 'SHOP'" index="/shop-scripts">
            <el-icon><Document /></el-icon>
            <span>我的剧本</span>
          </el-menu-item>
          <el-menu-item v-if="user.role === 'SHOP'" index="/shop-stat">
            <el-icon><DataLine /></el-icon>
            <span>数据公告</span>
          </el-menu-item>
          <el-menu-item v-if="user.role === 'PLAYER'" index="/scripts?collect=1">
            <el-icon><Star /></el-icon>
            <span>我的收藏</span>
          </el-menu-item>
          <el-menu-item v-if="user.id" index="/profile">
            <el-icon><User /></el-icon>
            <span>个人中心</span>
          </el-menu-item>
        </el-menu>
      </el-drawer>
      
      <el-main class="main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, onMounted, watch, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Menu as MenuIcon, Calendar, User, Document, DataLine, Star } from '@element-plus/icons-vue'
import { baseURL } from './utils/request'

const router = useRouter()
const route = useRoute()
const user = ref({})
const isMobile = ref(false)
const drawerVisible = ref(false)

const checkMobile = () => {
  isMobile.value = window.innerWidth <= 768
}

const loadUser = () => {
  const storedUser = localStorage.getItem('user')
  if (storedUser) {
    user.value = JSON.parse(storedUser)
  } else {
    user.value = {}
  }
}

onMounted(() => {
  loadUser()
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})

watch(() => route.path, () => {
  loadUser()
})

const handleLogout = () => {
  localStorage.removeItem('user')
  localStorage.removeItem('token')
  user.value = {}
  router.push('/login')
}
</script>

<style>
/* 全局基础样式 */
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  background-color: #f5f7fa;
}

.layout-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.header {
  background-color: #fff;
  color: #333;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #e6e6e6;
  padding: 0 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  z-index: 100;
  flex-shrink: 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.menu-toggle {
  font-size: 20px;
  border: none;
  background: transparent;
}

.logo {
  font-size: 18px;
  font-weight: bold;
  color: #409eff;
  white-space: nowrap;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-brief {
  display: flex;
  align-items: center;
  font-size: 14px;
  color: #606266;
}

.main-container {
  flex: 1;
  overflow: hidden;
}

.aside {
  background-color: #fff;
  border-right: 1px solid #e6e6e6;
}

.el-menu-vertical {
  border-right: none;
}

.drawer-logo {
  padding: 20px;
  font-size: 18px;
  font-weight: bold;
  color: #409eff;
  border-bottom: 1px solid #f0f0f0;
}

.el-menu-drawer {
  border-right: none;
}

.main {
  background-color: #f5f7fa;
  padding: 20px;
  overflow-y: auto;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .header {
    padding: 0 12px;
  }
  .logo {
    font-size: 16px;
  }
  .main {
    padding: 12px;
  }
}

.fullpage-container {
  height: 100vh;
  background-color: #f5f7fa;
}
</style>
