import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    component: () => import('../views/LoginView.vue')
  },
  {
    path: '/scripts',
    component: () => import('../views/ScriptListView.vue')
  },
  {
    path: '/bookings',
    component: () => import('../views/MyBookingsView.vue')
  },
  {
    path: '/shop-scripts',
    component: () => import('../views/ShopScriptView.vue')
  },
  {
    path: '/shop-stat',
    component: () => import('../views/ShopStatView.vue')
  },
  {
    path: '/profile',
    component: () => import('../views/ProfileView.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 简单登录守卫：未登录时强制跳转到登录页
router.beforeEach((to, from, next) => {
  if (to.path === '/login') {
    next()
    return
  }
  const user = JSON.parse(localStorage.getItem('user') || '{}')
  if (!user.id) {
    next('/login')
  } else {
    next()
  }
})

export default router
