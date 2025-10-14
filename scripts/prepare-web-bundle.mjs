import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';
import base64 from './base64.mjs';

const ROOT_DIR = execSync('git rev-parse --show-toplevel').toString().trim();
const WEBAPP_DIR = path.join(ROOT_DIR, 'apps/web');
const WEBAPP_DIST = path.join(WEBAPP_DIR, 'build');
const FINAL_INDEX_HTML = path.join(WEBAPP_DIST, 'index.html');
const ORIGINAL_INDEX_HTML = path.join(WEBAPP_DIST, 'index.original.html');
const INLINE_INDEX_HTML = path.join(WEBAPP_DIST, 'index.inline.html');
const WRAPPER_HTML_TPL = path.join(WEBAPP_DIR, 'static/ios-wrapper.html');

async function main() {
  try {
    // 1. Get build info
    const gitSha = execSync('git rev-parse --short HEAD').toString().trim();
    const gitBranch = execSync('git rev-parse --abbrev-ref HEAD').toString().trim();
    const buildDate = new Date().toISOString().replace('T', ' ').substring(0, 19);

    // 2. Build the SvelteKit app
    console.log('Building SvelteKit app...');
    execSync('npm --prefix apps/web run build', { stdio: 'inherit' });

    // 3. Preserve the original SvelteKit output for side-by-side inspection
    const originalHtml = await fs.readFile(FINAL_INDEX_HTML, 'utf-8');
    await fs.writeFile(ORIGINAL_INDEX_HTML, originalHtml);
    console.log(`Saved SvelteKit output to ${ORIGINAL_INDEX_HTML}`);

    const manifestPath = path.join(WEBAPP_DIR, '.svelte-kit/output/client/.vite/manifest.json');
    const manifest = JSON.parse(await fs.readFile(manifestPath, 'utf-8'));

    // 4. Find and read the CSS file from the manifest
    console.log('Extracting CSS content from manifest...');
    const cssFile = Object.values(manifest).find(entry => entry.src === 'style.css');
    if (!cssFile) {
      throw new Error('No entry CSS found in manifest.json');
    }
    const cssPath = path.join(WEBAPP_DIR, '.svelte-kit/output/client', cssFile.file);
    const cssContent = await fs.readFile(cssPath, 'utf-8');
    console.log(`Extracted CSS from ${cssPath}`);

    // 5. Extract the script content
    // 6. Find and read the JS file from the manifest
    console.log('Extracting JS content from manifest...');
    const jsFile = Object.values(manifest).find(entry => entry.isEntry && entry.file.endsWith('.js'));
    if (!jsFile) {
      throw new Error('No entry JS found in manifest.json');
    }
    const jsPath = path.join(WEBAPP_DIR, '.svelte-kit/output/client', jsFile.file);
    const scriptContent = await fs.readFile(jsPath, 'utf-8');
    console.log(`Extracted JS from ${jsPath}`);

    // 7. Base64 encode the script content
    console.log('Base64 encoding script content...');
    const encodedScript = base64.encode(scriptContent);

    // 6. Create the new wrapper HTML
    console.log('Creating new wrapper HTML...');
    const wrapperContent = await fs.readFile(WRAPPER_HTML_TPL, 'utf-8');
    let finalHtml = wrapperContent.replace('`__SVELTE_APP_BUNDLE__`', "`" + encodedScript + "`");

    // 7. Inject build info and CSS content together
    const buildInfo = `
    <!-- Build Info:
      Commit: ${gitSha} (${gitBranch})
      Build Date: ${buildDate}
    -->
    <script>
      console.log('Build Info:', {
        commit: '${gitSha}',
        branch: '${gitBranch}',
        buildDate: '${buildDate}'
      });
    </script>
    `;
    const styleTag = `<style>${cssContent}</style>`;
    finalHtml = finalHtml.replace('</head>', `${buildInfo}${styleTag}</head>`);

    // 9. Write the inline-bundle HTML without replacing the original entry point
    console.log('Writing inline bundle to index.inline.html...');
    await fs.writeFile(INLINE_INDEX_HTML, finalHtml);

    console.log('✅ Web bundle preparation complete!');

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

main();
