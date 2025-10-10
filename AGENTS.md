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

## Build Tool Standards

All build operations MUST use the `just` command runner (installed via mise) for consistent automation across the monorepo.

### Core Principles

1. **Justfile Interface**: All commands exposed through `justfile` at repository root
2. **Script Delegation**: Justfile MUST delegate actual logic to `./scripts/*.sh` shell scripts
3. **Documentation Required**: Every justfile recipe MUST include clear description
4. **Default Listing**: Running `just` with no arguments lists all available recipes with descriptions
5. **Clean Abstraction**: Justfile provides user-friendly commands; scripts handle implementation details

### Standard Recipe Pattern

```just
# Build and start prototype server
prototype num action:
    ./scripts/prototype.sh {{num}} {{action}}

# Build and start main webapp
webapp action:
    ./scripts/webapp.sh {{action}}
```

### Installation

```bash
# just is installed via mise
mise install
just --version
```

### Usage Examples

```bash
# List all available commands
just

# Manage prototypes
just prototype 02 start
just prototype 02 stop

# Manage webapp
just webapp start
just webapp stop
just webapp reload
```

## Build Caching & Performance

**Critical**: All builds MUST leverage Turbo's incremental caching to avoid wasting time on full rebuilds.

### Core Principle

**Incremental-first workflow**: 90% of builds should be fast cached builds; 10% require clean rebuilds when cache is stale.

### Turbo Pipeline Configuration

Caching is configured in `turbo.json` with task definitions for `build`, `lint`, `typecheck`, `test`. Each task specifies:
- `outputs`: Directories to cache (`.next/**`, `dist/**`, `build/**`)
- `dependsOn`: Dependency graph for correct build order
- Cache scope: Local only (no remote cache configured)

**Important**: Only tasks defined in the Turbo pipeline with proper `outputs` are cached. Caching applies to:
- TypeScript compilation outputs (`.next`, `dist`, `build` directories)
- Package build artifacts per turbo.json configuration

### Fast Incremental Builds (Default)

Turbo caches build artifacts and only rebuilds what changed:

```bash
# Build webapp using cache (FAST - use this by default)
just build-webapp
# Delegates to: turbo run build --filter @mealplanner/web

# OR use pnpm directly
pnpm build:web
# Delegates to: turbo run build --filter @mealplanner/web
```

**When to use**: Always use incremental builds first. Turbo tracks file changes and rebuilds only affected packages.

**How it works**: 
- `just build-webapp` → `turbo run build --filter @mealplanner/web`
- Turbo checks cache hash (source files + dependencies)
- If cache hit: restore from `.turbo/cache`, skip build (very fast)
- If cache miss: build and cache outputs

### Clean Builds (When Needed)

Force rebuild bypassing cache when incremental build seems stale:

```bash
# Force clean build (bypasses Turbo cache)
just clean-build-webapp
# Delegates to: turbo run build --filter @mealplanner/web --force

# Clean build artifacts (.next, dist, build, .turbo cache)
just clean
# Delegates to: turbo run clean

# Nuclear option: clean everything including node_modules
just clean-all
# Removes: node_modules, .turbo, .next, dist, build (all packages)
```

**When to use clean builds**:
- Build seems stale ("does not have new code" despite changes)
- Dependency updates not reflected (package.json or pnpm-lock.yaml changed)
- Mysterious build errors that don't make sense
- After major refactoring or package changes
- Environment variable changes affecting builds

**Clean command semantics**:
- `clean`: Removes `.turbo` cache, `.next`, `dist`, `build` directories
- `clean-all`: Also removes `node_modules` at root and all packages (requires `pnpm install` after)

**Trade-off**: Accept that 2 out of 10 builds may need `clean-build-webapp` to work correctly, in exchange for 8 out of 10 builds being dramatically faster.

### Justfile to Turbo Mapping

All `just` commands delegate to Turbo for caching:

```just
# justfile → Turbo command mapping

build-webapp:
    turbo run build --filter @mealplanner/web

clean-build-webapp:
    turbo run build --filter @mealplanner/web --force

dev-webapp:
    turbo run dev --filter @mealplanner/web

clean:
    turbo run clean

clean-all:
    turbo run clean && rm -rf node_modules apps/*/node_modules packages/*/node_modules
```

**Never bypass Turbo**: Direct `pnpm run build` in apps/web loses caching. Always use `just` or `pnpm build:web` (which delegates to Turbo).

### Workflow

```bash
# One-time setup (run when package.json or pnpm-lock.yaml changes)
pnpm install

# Daily workflow (90% of the time)
just build-webapp        # Fast incremental build
just webapp start        # Serve pre-built artifacts (next start in production mode)

# When build seems stale (10% of the time)
just clean-build-webapp  # Force clean rebuild
just webapp start        # Serve fresh artifacts
```

### Prototype Management

Prototypes use `./scripts/prototype.sh` wrapped by `just`:

```bash
# just command → script delegation
just prototype 02 start  # Calls: sh ./scripts/prototype.sh 02 start
just prototype 02 stop   # Calls: sh ./scripts/prototype.sh 02 stop
```

**Note**: Prototypes build before serving (typically starts quickly, usually under 10 seconds depending on machine).

### Cache Invalidation Triggers

Turbo rebuilds when:
- Source files change (tracked by git)
- Dependencies change (package.json, pnpm-lock.yaml)
- Environment variables change (NODE_ENV, etc.)
- turbo.json task configuration changes

**Non-hermetic tasks**: If a task depends on system state (OS differences, global env), mark it with `"cache": false` in turbo.json.

### Troubleshooting Stale Builds

If incremental builds seem wrong:

1. **Try clean build first**: `just clean-build-webapp`
2. **Check Turbo status**: `turbo run build --filter @mealplanner/web --dry`
3. **Clear Turbo cache**: `rm -rf .turbo`
4. **Verify filters**: Ensure `--filter @mealplanner/web` matches package name
5. **Check for env changes**: Env vars can break cache hits
6. **Last resort**: `just clean-all && pnpm install` (requires full reinstall)

### Never Do This

**WRONG**: Running `pnpm install` repeatedly wastes time. Only run when `package.json` or `pnpm-lock.yaml` changes.

**WRONG**: Bypassing Turbo with direct `pnpm run build` commands loses caching benefits.

**WRONG**: Running builds in apps/web directory directly - always use root-level commands.

**RIGHT**: Use `just` commands that delegate to Turbo for intelligent caching.

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



