# Repository Guidelines

## Project Structure & Module Organisation
The monorepo uses pnpm workspaces with Turbo. Application code lives in `apps/` (currently `apps/web` for the Next.js PWA), shared logic in `packages/` (recipe data models, validation, persistence), and internal tooling configurations in `tooling/`. Research artefacts, user evidence, and decision logs stay under `memory/`, `interviews/`, and `specs/`; keep these in sync with the MealPlanner constitution before coding.

## Build, Test, and Development Commands
Run `pnpm install` once per machine to hydrate workspaces. Use `pnpm dev` for a multi-package watch, or `pnpm dev:web` for the web app alone. `pnpm build` executes `turbo run build` across packages, while `pnpm typecheck`, `pnpm lint`, and `pnpm test` fan out to the workspace scripts. When adjusting individual packages, you can scope via `pnpm test --filter @mealplanner/web` or similar Turbo filters.

### Long-Running Command Discipline
Always guard potentially slow scripts with shell timeouts: start with `timeout 20 <command>` and only increase (in 60-second increments) when the command shows ongoing progress. Never sit on an unbounded install/build—relaunch with a higher timeout instead of waiting.

## Coding Style & Naming Conventions
Source is TypeScript-first; maintain strict typing and prefer discriminated unions in shared packages. Follow the repo Prettier and ESLint presets (`pnpm format:fix`, `pnpm lint:fix`) using two-space indentation and trailing commas. Component and class files should use `PascalCase` (`FamilyPlanner.tsx`), hooks and utilities `camelCase` (`useOfflineSync.ts`), and constants `SCREAMING_SNAKE_CASE`. Keep React components lean and mobile responsive from the outset.

## Testing Guidelines
Vitest backs unit and integration coverage. Name spec files `<name>.test.ts` or `<name>.test.tsx` beside the implementation. When touching shared packages, add contract tests that validate recipe schemas and guard against offline sync regressions. Run `pnpm test` locally before raising a pull request, and capture gaps or flakey cases in the Learning Log so follow-up tasks can be traced.

## Commit & Pull Request Guidelines
Write commits in the imperative mood (`Add VoU sync guard`) and reference the related VoU or Learning Log identifier when applicable (`#MP-012`). Keep diffs focused; amend instead of stacking noise. Pull requests must include: problem statement, evidence link (Learning Log or VoU ticket), test results (`pnpm test` output or screenshots), and mobile validation notes (<3s 3G load, offline checks). Request review only after linting, type checks, and tests pass.

## Security & Configuration Tips
Never commit `.env*` secrets; Turbo caches detection will flag them. Verify Node ≥22.11 and pnpm ≥9.12 via `mise use` or local tooling before running scripts. For prototype work, isolate experiments under `prototype/<id>` and document any data fixtures or temporary endpoints in the accompanying Learning Log entry.

## Web App Prototypes

Prototypes live under `prototype/<id>/` as standalone Next.js apps for rapid UI iteration. Each prototype MUST be production-built before serving to avoid hanging development watchers during agentic workflows.

### Prototype Management Script

Use `./prototype.sh <id> <action>` to manage prototypes:

```bash
# Build and start prototype (runs npm build then npm start)
./prototype.sh 02 start

# Stop a running prototype
./prototype.sh 02 stop

# Reload (stop + start)
./prototype.sh 02 reload
```

**Critical**: The script builds the app first (`npm run build`), then serves with `npm run start` (production mode). This ensures no hanging watchers and clean background execution. The server starts within 5 seconds.

### Manual Build & Run

If needed, build and run manually:

```bash
cd prototype/02
npm install           # Install dependencies
npm run build         # Build production bundle
npm run start         # Serve on http://localhost:3000
```

### Testing with Playwright

Always test prototypes with Playwright MCP after starting:

```bash
# 1. Start the prototype
./prototype.sh 02 start

# 2. Use Playwright MCP tools to navigate and interact
# mcp_playwright_browser_navigate to http://localhost:3000/calendar
# mcp_playwright_browser_snapshot to capture UI state
# mcp_playwright_browser_click, etc. for interactions

# 3. Stop when done
./prototype.sh 02 stop
```

## Stack

**Important** JSON Schema is a dumpster fire and MUST NOT be used. JDT RFC 8927 MAY be used. 
We use a mono repo structure where ./app/* are independent deployables. 
We MUST use NextJS for the screens. 
We MUST have TypeScript modules for any business logic. 
The screens SHOULD use the business logic TypeScript modules. 
We MUST use TDD for business logic TypeScript modules. 
We MAY share the business logic TypeScript moodules across many apps in the mono repo. 
We SHOULD create a pure webapp of **all** the screens that can be tested with puppeteer or playwrite. 
We MAY package the pure webapp into the other ./app/* deployables to deploy mobile or desktop applications. 



