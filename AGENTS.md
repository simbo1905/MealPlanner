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
- **Framework**: Next.js (legacy visual mockups only - DO NOT MODIFY)
- **Purpose**: Historical UI reference for porting to Svelte

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

**Note**: Prototypes build before serving (typically starts quickly, usually under 10 seconds). These are legacy Next.js mockups for visual reference only.

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
./scripts/prototype.sh 02 start

# 2. Use Playwright MCP tools to navigate and interact
# mcp_playwright_browser_navigate to http://localhost:3000/calendar
# mcp_playwright_browser_snapshot to capture UI state
# mcp_playwright_browser_click, etc. for interactions

# 3. Stop when done
./scripts/prototype.sh 02 stop
```

## Stack

**Important:** JSON Schema is a dumpster fire and MUST NOT be used. JTD RFC 8927 MAY be used.

We use a monorepo structure where `./apps/*` are independent deployables.

The web app uses **Svelte 5 + Vite 6** for all screens.

We MUST have TypeScript modules for business logic in `./packages/*`.

The screens SHOULD use the business logic TypeScript modules from `./packages/*`.

We MUST use TDD for business logic TypeScript modules.

We MAY share the business logic TypeScript modules across many apps in the monorepo.

We SHOULD create a pure webapp of **all** screens that can be tested with Playwright.

We MAY package the pure Vite webapp bundle into the other `./apps/*` deployables to deploy mobile or desktop applications. 


## Automation Semantics

- Recipes named `build-*` perform an incremental build for that deployable only. They must not rebuild shared web bundles or launch simulators/emulators.
- Recipes named `deploy-*` first ensure the latest web bundle is produced and copied where needed, then launch/install the target application.
- Recipes named `clean-*` remove build artifacts for their own deployable, but must not clear shared artifacts such as the web bundle; provide explicit commands if the web bundle ever needs to be cleaned.

## Git Discipline

- Only the user may request staging or committing work. This monorepo is actively updated by multiple agents in parallel.
- Agents must never run `git add`, `git commit`, or similar commands on files they did not modify directly, or outside the deployable they have personally built and tested.
- Keep local diffs focused on the requested task; leave all repository-wide staging to the user.

## Fearless Refactoring and Clean Pivots

### The Sunk Cost Fallacy in AI-Assisted Development

When working with AI coding agents, a common failure pattern emerges: the agent will attempt to "preserve," "migrate," or "adapt" existing code even when explicitly instructed to replace it. This stems from training on traditional enterprise development practices that emphasize caution and incremental change.

**This is wrong for modern agent-assisted development.**

### Core Principles

1. **Git is your safety net, not caution.** With version control, there is no risk in deleting code. The agent should never hesitate to `git rm -rf` entire directories when instructed to start fresh.

2. **Working prototypes trump legacy code.** If you have a working demo/spike that proves an approach, that becomes the new foundation. The old code is not "technical debt to migrate"—it's a failed experiment to discard.

3. **Trust explicit instructions over implicit preservation.** When the user says "replace," "delete," or "start from scratch," this is not hyperbole requiring interpretation. It's a technical decision already made.

4. **Concurrent experimentation is normal.** Multiple spikes, demos, and proof-of-concepts may exist simultaneously at `./tmp/`, `./experiments/`, etc. The user will explicitly state which one becomes the new baseline.

### Anti-Patterns to Avoid

**❌ DON'T:**
- Suggest "migrating" code when replacement is requested
- Propose "preserving" functionality from code described negatively or as being named as obsolete
- Create "adaptation layers" between old and new architectures
- Ask for "confirmation" about deleting code after it's been described negatively or as being named obsolete
- Hedge with "we could keep X in case we need it later" we have git and we keep many branches and prototypes and write-ups around. 

**✅ DO:**
- Execute `git rm -rf` commands without hesitation when instructed
- Copy working demo code wholesale without "adaptation"
- Document what user-facing **functionality** existed (not code structure)
- Rebuild features incrementally with TDD after establishing new baseline using browser tools, curl, and things like playwright and kapture
- Use Vite/HMR to validate each small addition tailing the vite logs when things break

### The Correct Workflow for Clean Pivots

When the user has decided to pivot to a new architecture:

1. **Pivot completely:** Remove all old code as instructed. Use git commands such as `git rm` to prune old files FIRST. Redirect `git status` to a log file for reference as you pivot.

2. **Analyze functionality, not code:** Review the deleted code only to extract: "Component X allowed users to do Y." Document intended UX features, not implementation details.

3. **Establish new baseline:** Copy the working demo/spike exactly as-is. Install, run, test  using browser tools, curl, and things like playwright and kapture.

4. **Rebuild incrementally:** For each UX feature identified in step 2, use TDD to add it back to the new architecture. Test with hot reload after each addition.

5. **Never look back:** The old code is gone. If something is truly needed, it will become apparent during the rebuild and can be re-implemented properly. If we go wrong the user will use git to get is back to where we need to be and make a fresh start armed with new knowledge. 

### Why This Works

- **Git provides perfect undo:** Caution is unnecessary
- **Working code reduces risk:** Starting from a proven demo is safer than tangled migrations  
- **Clean architecture emerges:** Rebuilding features one-by-one prevents cruft accumulation
- **Fast feedback loops:** HMR + Playwright + browser tools provide immediate validation
- **Clear decision points:** Each feature addition is explicit and testable

### Agent Behavior Expectations

When the user indicates a pivot decision:

- **Assume competence:** The user has evaluated the tradeoffs and has run spikes and experiments
- **Execute boldly:** Delete old code immediately and completely AND prune any **/*.md documentation that refers to any deleted code
- **Copy faithfully:** Use demo code verbatim, no "adaptation"
- **Rebuild methodically:** Add features back with TDD and hot reload AND update all **/*.md documentation with what is new
- **Trust the process:** The user knows source control exists and has branches, tags, spike, and builds spikes in other git repos as necessary for continual learning. 

This is not reckless—this is **modern lean development** optimized for the rapid iteration capabilities of AI-assisted coding.

# No Advertising

- Never put in an authored by or co-authored by into any commit the use is the only intellect and owner of all rights and IP. 
