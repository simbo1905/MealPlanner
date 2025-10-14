import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';
import base64 from './base64.mjs';

const ROOT_DIR = execSync('git rev-parse --show-toplevel').toString().trim();
const WEBAPP_DIR = path.join(ROOT_DIR, 'apps/web');
const WEBAPP_DIST = path.join(WEBAPP_DIR, 'build');
const FINAL_INDEX_HTML = path.join(WEBAPP_DIST, 'index.html');
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

    // 3. Read the generated index.html
    console.log('Reading generated index.html...');
    const indexContent = await fs.readFile(FINAL_INDEX_HTML, 'utf-8');

    // 4. Extract the script content
    console.log('Extracting script content...');
    const match = indexContent.match(/<script>([\s\S]*?)<\/script>/m);
    if (!match) {
      throw new Error('No inline script found in index.html');
    }
    const scriptContent = match[1];
    const scriptLength = scriptContent.length;
    console.log(`Extracted script length: ${scriptLength}`);

    // 5. Base64 encode the script content
    console.log('Base64 encoding script content...');
    const encodedScript = base64.encode(scriptContent);

    // 6. Create the new wrapper HTML
    console.log('Creating new wrapper HTML...');
    const wrapperContent = await fs.readFile(WRAPPER_HTML_TPL, 'utf-8');
    let finalHtml = wrapperContent.replace('`__SVELTE_APP_BUNDLE__`', "`" + encodedScript + "`");

    // 7. Inject build info
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
    finalHtml = finalHtml.replace('</head>', `${buildInfo}</head>`);


    // 8. Write the new index.html
    console.log('Writing new index.html...');
    await fs.writeFile(FINAL_INDEX_HTML, finalHtml);

    console.log('✅ Web bundle preparation complete!');

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

main();
