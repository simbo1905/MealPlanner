import App from './App.svelte'
import './app.css'

const target = document.getElementById('app')

if (!target) {
  throw new Error('Root element #app not found')
}

const app = new App({
  target
})

export default app
