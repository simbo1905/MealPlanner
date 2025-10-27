import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  let serverResponded = false;
  let buildInfoFound = false;
  let wrapperLogFound = false;
  let svelteLogFound = false;

  page.on('console', msg => {
    const text = msg.text();
    console.log("[PLAY]", text);
    if (text.includes('Build Info:')) {
      buildInfoFound = true;
    }
    if (text.includes('[Wrapper] App script injected and executed.')) {
      wrapperLogFound = true;
    }
    if (text.includes('[DEBUG] App.svelte onMount fired')) {
      svelteLogFound = true;
    }
  });

  page.on('response', response => {
    if (response.url() === 'http://localhost:3333/' && response.status() === 200) {
      serverResponded = true;
    }
  });

  try {
    await page.goto('http://localhost:3333', { waitUntil: 'load', timeout: 10000 });

    const appDiv = await page.$('#app');
    const appHasContent = await page.evaluate(() => document.querySelector('#app')?.hasChildNodes());

    console.log("\n--- Playwright Test Results ---");
    console.log(`Server responded: ${serverResponded}`);
    console.log(`Build info found: ${buildInfoFound}`);
    console.log(`Wrapper log found: ${wrapperLogFound}`);
    console.log(`Svelte log found: ${svelteLogFound}`);
    console.log(`Found #app element: ${!!appDiv}`);
    console.log(`App has content: ${appHasContent}`);
    console.log("-----------------------------\n");

    if (!serverResponded || !buildInfoFound || !wrapperLogFound || !svelteLogFound || !appDiv || !appHasContent) {
      console.error("❌ Playwright test failed.");
      process.exit(1);
    }

    console.log("✅ Playwright test passed.");

  } catch (error) {
    console.error("❌ Playwright test failed with error:", error);
    process.exit(1);
  } finally {
    await browser.close();
  }
})();