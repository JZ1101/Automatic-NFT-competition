import { createRouter, createWebHistory } from 'vue-router';
import Home from '@/views/HomeView.vue';
import About from '@/views/AboutView.vue';
import Main from '@/views/MainView.vue';
import Balance from '@/views/BalanceView.vue';
import Winner from '@/views/WinnerView.vue';
const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/about',
    name: 'About',
    component: About
  },
  {
    path: '/main',
    name: 'Main',
    component: Main
  },
  
  {
    path: '/winner',
    name: 'Winner',
    component: Winner
  },
  {
    path: '/balance',
    name: 'Balance',
    component: Balance
  }
  
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
