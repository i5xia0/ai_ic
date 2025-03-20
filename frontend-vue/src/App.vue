<script setup>
import ImageGenerator from './views/ImageGenerator.vue'
</script>

<template>
  <div id="app">
    <image-generator />
  </div>
</template>

<style>
body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background-color: #f9fafb;
  color: #1f2937;
  line-height: 1.5;
  margin: 0;
  padding: 0;
}

#app {
  min-height: 100vh;
}
</style>
