import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import path from 'path'

export default defineConfig({
  base: './',
  plugins: [svelte()],
  resolve: {
    alias: {
      '$lib': path.resolve('./src/lib')
    }
  },
  server: {
    port: 3001,
    strictPort: false
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: undefined,
        inlineDynamicImports: true
      }
    }
  }
})
