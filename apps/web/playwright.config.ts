import { defineConfig, devices } from '@playwright/test'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const WEB_PORT = Number(process.env.PLAYWRIGHT_WEB_PORT ?? 3001)
const WEB_HOST = process.env.PLAYWRIGHT_WEB_HOST ?? 'localhost'
const BASE_URL = `http://${WEB_HOST}:${WEB_PORT}`
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

export default defineConfig({
  testDir: path.resolve(__dirname, 'tests', 'playwright'),
  timeout: 60_000,
  expect: {
    timeout: 10_000,
  },
  fullyParallel: true,
  retries: process.env.CI ? 1 : 0,
  reporter: [['list'], ...(process.env.CI ? [['html', { open: 'never' }]] : [])],
  use: {
    baseURL: BASE_URL,
    trace: 'on-first-retry',
  },
  webServer: {
    command: `pnpm --filter @mealplanner/web run dev -- --host ${WEB_HOST} --port ${WEB_PORT}`,
    url: BASE_URL,
    reuseExistingServer: !process.env.CI,
    stdout: 'pipe',
    stderr: 'pipe',
    timeout: 120_000,
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
})
