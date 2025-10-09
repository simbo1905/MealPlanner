import { beforeAll, afterAll, describe, expect, test } from 'vitest'
import puppeteer, { Browser, Page } from 'puppeteer'
import { spawn } from 'node:child_process'
import path from 'node:path'
import fs from 'node:fs/promises'
import { createServer, type Server } from 'node:http'
import { createReadStream } from 'node:fs'

const WEB_DIR = path.resolve(__dirname, '..')
const TEST_ARTIFACT_DIR = path.resolve(__dirname, '__artifacts__')
const PORT = process.env.WEB_E2E_PORT ? Number(process.env.WEB_E2E_PORT) : 3123
const BASE_URL = `http://127.0.0.1:${PORT}`

let staticServer: Server | null = null
let browser: Browser | null = null
let page: Page | null = null

async function runCommand(command: string, args: string[], cwd: string) {
  await new Promise<void>((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
      stdio: 'inherit',
      env: { ...process.env }
    })

    child.on('error', reject)
    child.on('exit', code => {
      if (code === 0) {
        resolve()
      } else {
        reject(new Error(`${command} ${args.join(' ')} exited with code ${code}`))
      }
    })
  })
}

async function waitForServer(url: string, attempts = 30) {
  for (let i = 0; i < attempts; i += 1) {
    try {
      const response = await fetch(url)
      if (response.ok) return
    } catch (error) {
      // swallow and retry
    }
    await new Promise(resolve => setTimeout(resolve, 1000))
  }
  throw new Error(`Timed out waiting for server at ${url}`)
}

function resolveFilePath(requestPath: string): string {
  const cleanPath = decodeURIComponent(requestPath.split('?')[0] ?? '/')
  const safePath = cleanPath.replace(/\../g, '')
  let resolved = path.join(WEB_DIR, 'dist', safePath)

  if (safePath.endsWith('/')) {
    resolved = path.join(resolved, 'index.html')
  }

  return resolved
}

function determineContentType(filePath: string): string {
  if (filePath.endsWith('.html')) return 'text/html; charset=utf-8'
  if (filePath.endsWith('.css')) return 'text/css; charset=utf-8'
  if (filePath.endsWith('.js')) return 'application/javascript; charset=utf-8'
  if (filePath.endsWith('.json')) return 'application/json; charset=utf-8'
  if (filePath.endsWith('.svg')) return 'image/svg+xml'
  if (filePath.endsWith('.png')) return 'image/png'
  if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) return 'image/jpeg'
  if (filePath.endsWith('.woff2')) return 'font/woff2'
  return 'application/octet-stream'
}

async function startStaticServer(port: number) {
  const distDir = path.join(WEB_DIR, 'dist')
  const server = createServer(async (req, res) => {
    if (!req.url) {
      res.statusCode = 400
      res.end('Bad request')
      return
    }

    let filePath = resolveFilePath(req.url)
    try {
      let stats = await fs.stat(filePath)
      if (stats.isDirectory()) {
        filePath = path.join(filePath, 'index.html')
        stats = await fs.stat(filePath)
      }

      res.statusCode = 200
      res.setHeader('Content-Type', determineContentType(filePath))
      res.setHeader('Cache-Control', 'no-store')
      const stream = createReadStream(filePath)
      stream.pipe(res)
    } catch (error) {
      // Fallback to index.html for client-side routing
      const fallback = path.join(distDir, 'index.html')
      try {
        await fs.access(fallback)
        res.statusCode = 200
        res.setHeader('Content-Type', 'text/html; charset=utf-8')
        createReadStream(fallback).pipe(res)
      } catch {
        res.statusCode = 404
        res.end('Not found')
      }
    }
  })

  await new Promise<void>((resolve, reject) => {
    server.once('error', reject)
    server.listen(port, resolve)
  })

  staticServer = server
}

describe('Recipe Explorer smoke test', () => {
  beforeAll(async () => {
    await runCommand('pnpm', ['build'], WEB_DIR)

    await startStaticServer(PORT)
    await waitForServer(`${BASE_URL}/`)

    browser = await puppeteer.launch({
      headless: true,
      executablePath: puppeteer.executablePath(),
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    })
    page = await browser.newPage()
  }, 120_000)

  afterAll(async () => {
    if (page) await page.close()
    if (browser) await browser.close()
    if (staticServer) {
      await new Promise(resolve => staticServer?.close(resolve))
    }
  })

  test('searching and viewing recipes works', async () => {
    if (!page) throw new Error('Browser page not initialised')

    await page.goto(`${BASE_URL}/`, { waitUntil: 'networkidle0' })
    await page.waitForSelector('input[placeholder="Try \"stir fry\" or type #chicken to add a tag"]')

    const initialTitles = await page.$$eval('[data-testid="recipe-card"] h3', nodes =>
      nodes.map(node => node.textContent?.trim()).filter(Boolean)
    )

    expect(initialTitles.length).toBeGreaterThan(0)
    expect(initialTitles[0]).toContain('Spaghetti')

    await page.click('input[placeholder="Try \"stir fry\" or type #chicken to add a tag"]')
    await page.type('input[placeholder="Try \"stir fry\" or type #chicken to add a tag"]', 'Fish')

    await page.waitForFunction(() => {
      const firstCard = document.querySelector('[data-testid="recipe-card"] h3')
      return firstCard?.textContent?.includes('Fish')
    })

    await fs.mkdir(TEST_ARTIFACT_DIR, { recursive: true })
    const screenshotPath = path.join(TEST_ARTIFACT_DIR, 'recipe-search.png') as `${string}.png`
    await page.screenshot({
      path: screenshotPath,
      fullPage: true
    })

    const detailTitle = await page.$eval('aside h2', node => node.textContent?.trim())
    expect(detailTitle).toContain('Fish')
  })
})
