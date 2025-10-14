import fs from 'fs/promises';
import path from 'path';

const ROOT_DIR = process.cwd();
const WEBAPP_DIR = path.join(ROOT_DIR, 'apps/web');
const WEBAPP_DIST = path.join(WEBAPP_DIR, 'build');
const WRAPPER_HTML_TPL = path.join(WEBAPP_DIR, 'static/ios-wrapper.html');
const FINAL_INDEX_HTML = path.join(WEBAPP_DIST, 'index.html');

async function inject() {
  try {
    console.log('[inject-bundle] Reading files...');
    const wrapperContent = await fs.readFile(WRAPPER_HTML_TPL, 'utf-8');
    const indexContent = await fs.readFile(FINAL_INDEX_HTML, 'utf-8');

    console.log('[inject-bundle] Extracting script content...');
    const match = indexContent.match(/<script>([\s\S]*?)<\/script>/m);
    if (!match) {
      throw new Error('No inline script found in index.html');
    }
    const scriptContent = match[1];

    console.log('[inject-bundle] Injecting script into wrapper...');
    const finalHtml = wrapperContent.replace('`__SVELTE_APP_BUNDLE__`', scriptContent);

    console.log('[inject-bundle] Writing new index.html...');
    await fs.writeFile(FINAL_INDEX_HTML, finalHtml);

    console.log('[inject-bundle] ✅ Injection complete!');
  } catch (error) {
    console.error('[inject-bundle] ❌ Error:', error);
    process.exit(1);
  }
}

inject();
