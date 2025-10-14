# Bundle Decision: Revert to Native SvelteKit Output

**Date:** 2025-10-14

We validated that the unmodified SvelteKit static build renders correctly inside the iOS `WKWebView`. The custom Base64/inline wrapper introduced extra failure modes and is now removed.

## Final Approach
- Use `@sveltejs/adapter-static` with `fallback: 'index.html'` and hash routing.
- Run `just web-bundle` to execute `npm --prefix apps/web run build`; the generated `apps/web/build` folder is the exact artifact copied into native wrappers.
- Serve the build locally with `just web-serve` (Python HTTP server) when validating with Kapture, Playwright, or curl.

## Cleanup Actions
- Delete the bespoke Base64 HTML wrapper logic and temporary comparison files.
- Point all documentation at the standard SvelteKit build pipeline.
- Retain the working documentation of the infinite-scroll architecture; no special post-processing is required.

## Verification Checklist
1. `timeout 20 just web clean`
2. `timeout 20 just web bundle`
3. `timeout 20 just web start`
4. Open `http://localhost:3333/` in Edge via Kapture and verify the infinite-scroll planner renders with Tailwind styling.

> Any future bundling changes must preserve the default SvelteKit runtime; avoid rewriting `index.html` unless absolutely necessary.
