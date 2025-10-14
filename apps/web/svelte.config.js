import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: [vitePreprocess()],
  compilerOptions: {
    experimental: {
      async: true
    }
  },
  kit: {
    adapter: adapter({
      fallback: 'index.html'
    }),
    output: {
      bundleStrategy: 'inline'
    },
    router: {
      type: 'hash'
    },
    alias: {
      $routes: "./src/routes",
      "$routes/*": "./src/routes/*",
      "$assets/*": "./src/assets/*"
    }
  }
};

export default config;