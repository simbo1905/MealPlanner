# Repository Guidelines

## Project Structure & Module Organisation
The monorepo uses pnpm workspaces. Application code lives in `apps/` (currently `apps/web` for the Svelte + Vite PWA), shared logic in `packages/` (recipe data models, validation, persistence), and internal tooling configurations in `tooling/`. Research artefacts, user evidence, and decision logs stay under `memory/`, `interviews/`, and `specs/`; keep these in sync with the MealPlanner constitution before coding.

## Build, Test, and Development Commands
Run `pnpm install` once per machine to hydrate workspaces. Use `pnpm dev` for a multi-package watch, or `pnpm dev:web` for the web app alone. `pnpm build` builds packages then apps, while `pnpm typecheck`, `pnpm lint`, and `pnpm test` fan out to the workspace scripts. When adjusting individual packages, you can scope via `pnpm test --filter @mealplanner/web` or similar pnpm workspace filters.

### Long-Running Command Discipline
Always guard potentially slow scripts with shell timeouts: start with `timeout 20 <command>` and only increase (in 60-second increments) when the command shows ongoing progress. Never sit on an unbounded install/build—relaunch with a higher timeout instead of waiting.

## Coding Style & Naming Conventions
Source is TypeScript-first; maintain strict typing and prefer discriminated unions in shared packages. Follow the repo Prettier and ESLint presets (`pnpm format:fix`, `pnpm lint:fix`) using two-space indentation and trailing commas. Component files should use `PascalCase` (`FamilyPlanner.svelte`), stores and utilities `camelCase` (`useOfflineSync.ts`), and constants `SCREAMING_SNAKE_CASE`. Keep Svelte components lean and mobile responsive from the outset.

## Testing Guidelines
Vitest backs unit and integration coverage. Name spec files `<name>.test.ts` or `<name>.test.svelte.ts` beside the implementation. When touching shared packages, add contract tests that validate recipe schemas and guard against offline sync regressions. Run `pnpm test` locally before raising a pull request, and capture gaps or flakey cases in the Learning Log so follow-up tasks can be traced.

## Commit & Pull Request Guidelines
Write commits in the imperative mood (`Add VoU sync guard`) and reference the related VoU or Learning Log identifier when applicable (`#MP-012`). Keep diffs focused; amend instead of stacking noise. Pull requests must include: problem statement, evidence link (Learning Log or VoU ticket), test results (`pnpm test` output or screenshots), and mobile validation notes (<3s 3G load, offline checks). Request review only after linting, type checks, and tests pass.

## Security & Configuration Tips
Never commit `.env*` secrets or build artifacts. Verify Node ≥22.11 and pnpm ≥9.12 via `mise use` or local tooling before running scripts. For prototype work, isolate experiments under `prototype/<id>` and document any data fixtures or temporary endpoints in the accompanying Learning Log entry.

## Technology Stack

### Web Application (apps/web)
- **Framework**: Svelte 5 (runes enabled)
- **Build Tool**: Vite 6
- **UI Components**: bits-ui (Svelte component library)
- **Styling**: Tailwind CSS 3 with tailwindcss-animate
- **Icons**: lucide-svelte
- **Drag & Drop**: svelte-dnd-action
- **State Management**: Svelte stores + svelte-persisted-store
- **Date Handling**: date-fns
- **Testing**: Vitest

### Shared Packages (packages/*)
- **Language**: TypeScript (ES2022, ESM modules)
- **Build**: tsup with watch mode
- **Validation**: JTD RFC 8927 schemas
- **Testing**: Vitest

### Prototypes (prototype/*)
- **Framework**: Next.js (reference/mockup only - DO NOT MODIFY)
- **Purpose**: Visual reference for UI porting

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

## Vite Workflow

The webapp uses Vite for development and building. Vite provides instant HMR (Hot Module Replacement) for fast development.

### Development Server

```bash
# Start Vite dev server (with HMR)
just webapp start
# Server runs on http://localhost:3001

# Stop dev server
just webapp stop

# Restart dev server
just webapp reload
```

### Build & Preview

```bash
# Build for production
pnpm build:web
# Outputs to apps/web/dist/

# Preview production build
cd apps/web && pnpm preview
```

### Prototype Management

Prototypes use `./scripts/prototype.sh` wrapped by `just`:

```bash
# just command → script delegation
just prototype 02 start  # Calls: sh ./scripts/prototype.sh 02 start
just prototype 02 stop   # Calls: sh ./scripts/prototype.sh 02 stop
```

**Note**: Prototypes build before serving (typically starts quickly, usually under 10 seconds depending on machine).

## Troubleshooting

### pnpm Store Corruption

If `pnpm install` fails with ENOENT copyfile errors:

```bash
# Clear pnpm cache completely
rm -rf ~/.pnpm-store ~/.local/share/pnpm/store
rm -rf node_modules pnpm-lock.yaml

# Reinstall
pnpm install
```

### Vite Server Not Starting

Check if port 3001 is already in use:
```bash
lsof -ti:3001
# If process found, kill it: kill $(lsof -ti:3001)
```

Verify dev script exists in root `package.json`:
```bash
grep "dev:web" package.json
# Should show: "dev:web": "pnpm --filter @mealplanner/web run dev"
```

Check Vite config port:
```bash
grep "port:" apps/web/vite.config.ts
# Should show: port: 3001
```

### Missing Dependencies

If Vite command not found:
```bash
cd apps/web
pnpm install
```

If mise commands fail:
```bash
mise install
mise use
```

## Web App Prototypes

Prototypes live under `prototype/<id>/` as standalone Next.js apps for rapid UI iteration. Each prototype MUST be production-built before serving to avoid hanging development watchers during agentic workflows.

### Prototype Management Script

Use `./scripts/prototype.sh <id> <action>` to manage prototypes:

```bash
# Build and start prototype (runs npm build then npm start)
./scripts/prototype.sh 02 start

# Stop a running prototype
./scripts/prototype.sh 02 stop

# Reload (stop + start)
./scripts/prototype.sh 02 reload
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
We use a mono repo structure where ./apps/* are independent deployables. 
The web app uses **Svelte + Vite** for the screens. 
We MUST have TypeScript modules for any business logic. 
The screens SHOULD use the business logic TypeScript modules. 
We MUST use TDD for business logic TypeScript modules. 
We MAY share the business logic TypeScript modules across many apps in the mono repo. 
We SHOULD create a pure webapp of **all** the screens that can be tested with Playwright. 
We MAY package the pure webapp into the other ./apps/* deployables to deploy mobile or desktop applications. 



