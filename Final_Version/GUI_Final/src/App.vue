<template>
  <div id="app">
    <nav class="navbar">
      <router-link to="/">Home</router-link> | 
      <router-link to="/about">About</router-link> | 
      <router-link to="/main">Main</router-link> | 
      <router-link to="/winner">Winner</router-link> |
      <router-link to="/balance">Balance</router-link>
    </nav>
    <router-view></router-view>
  </div>
</template>
<style scoped>
.navbar {
  left: 0%;
  font-size: 30px;
  position: fixed;
  top: 0;
  width: 100%;
  background-color: #f8f9fa;
  padding: 20px 20px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  
}
</style>