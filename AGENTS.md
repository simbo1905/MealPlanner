# Repository Guidelines

## Project Structure & Module Organisation
The monorepo uses pnpm workspaces. Application code lives in `apps/` (currently `apps/web` for the Svelte + Vite PWA), shared logic in `packages/` (recipe data models, validation, persistence), and scripts in `tooling/` called by a self-documenting `justfile`. Research artefacts, user evidence, and decision logs stay under `memory/`, `interviews/`, and `specs/`; keep these in sync with the MealPlanner constitution before coding.

## Build, Test, and Development Commands

All frameworks and tools (including `just`) must be installed via mise for consistent "works on all machines" with isolated mise controlled virtual environments. 

The `just` recipes must be documented and have no logic they should just pass args and to `./scripts/xxx.sh` that:
1.  **Backgrounding:** The server process MUST be started in the background using `&`.
2.  **PID Management:** The script MUST write the Process ID (PID) of the server to a file in `/tmp/<script_name>.pid`.
3.  **Logging:** All `stdout` and `stderr` from the server process MUST be redirected to a log file at `/tmp/<script_name>.log`.
4.  **Health Check:** The script should provide a way to check if the server is running, for example, by using `hup -0 ${pid}`.

```just
# Verb-first naming convention
<target>-<verb>:
    ./scripts/{{target}}_{{verb}}.sh
```

Where the targets can be: 
- `web`
- `ios`
- `android`
- `jfx`
- ...

The verbs will be things like `clean|build|package|deploy|retart`

### Long-Running Command Discipline
You MUST always guard ALL scripts with shell timeouts: start with `timeout 20 just <command>` as the prior section says that there should be pid management you can then `sleep 30 hup -0 ${pid} ; tail -100 /tmp/<script_name>.log` to monitor what is going on and that progress is being made. 

## Coding Style & Naming Conventions
Source is TypeScript-first; maintain strict typing and prefer discriminated unions in shared packages. Follow the repo Prettier and ESLint presets using two-space indentation and trailing commas. Component files should use `PascalCase` (`FamilyPlanner.svelte`), stores and utilities `camelCase` (`useOfflineSync.ts`), and constants `SCREAMING_SNAKE_CASE`. Keep Svelte components lean and mobile responsive from the outset.

## Commit & Pull Request Guidelines
Write commits in the imperative mood (`[feat|bug] Add VoU sync guard`) and reference the related VoU or Learning Log identifier when applicable (`#MP-012`). Keep diffs focused; amend instead of stacking noise. Pull requests must include: problem statement, evidence link (Learning Log or VoU ticket), test results (test output or screenshots), and mobile validation notes (<3s 3G load, offline checks). Request review only after linting, type checks, and tests pass.

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
- **Framework**: Only because of historic accident we are using Next.js for visual mock ups only - DO NOT USE Next.js outside of mockups at ./prototypes/XX
- **Purpose**: Rapid UX throw-away prototypes only.

### Core Principles

0. **Write The Documentation First**: Before any changes are made all `**/*.md` must be updated FIRST. 
1. **Write The Tests First**: Before fixing bugs write a test that isolates the bug. 
2. **Justfile Interface**: All commands exposed through `justfile` at repository root
3. **Script Delegation**: Justfile MUST delegate actual logic to `./scripts/*.sh` shell scripts
4. **Documentation Required**: Every justfile recipe MUST include clear description
5. **Default Listing**: Running `just` with no arguments lists all available recipes with descriptions
6. **Clean Abstraction**: Justfile provides user-friendly commands; scripts handle implementation details
7. **No Sunk Costs**: The user is an expert in git and lean agile so a pivot MUST be seen as zero cost. 
8. **Do Not Ingore Immediate Requests**: If the user says "document x now as you are going to compact soon" you MUST comply immediately. 


### Usage Examples

```bash
# List all available commands
just

# Create a self-contained web app bundle for native deployment
just web-bundle

# Serve the web app bundle locally for testing
just web-serve
```

## Web App Workflow

The web app development and deployment process is managed through the `justfile` and is divided into several distinct steps to ensure a reliable build for both local development and native app deployment.

### Local Development
-   **`just web-vite`**: Starts the Vite dev server with Hot Module Replacement (HMR) for rapid development. The server runs on `http://localhost:3001`.

### Bundling for Native Apps
-   **`just web-bundle`**: Runs the standard SvelteKit static build (`npm --prefix apps/web run build`) so the generated `apps/web/build` output can be embedded directly in native `WKWebView`/`WebView` shells.
-   **`just web-serve`**: Serves the static build directory on `http://localhost:3333` for local testing with `curl`, Playwright, or Kapture.

### Deployment to Native Apps
-   **`just ios-deploy`**: Deploys the generated web app bundle to the iOS project.

### Prototype Management

Prototypes use `./scripts/prototype.sh` wrapped by `just`:

```bash
# just command → script delegation
just prototype 02 start  # Calls: sh ./scripts/prototype.sh 02 start
just prototype 02 stop   # Calls: sh ./scripts/prototype.sh 02 stop
```

**Note**: Prototypes build before serving (typically starts quickly, usually under 10 seconds). These are legacy Next.js mockups for visual reference only.

## Troubleshooting

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

## Web App Prototypes

Prototypes live under `prototype/<id>/` as standalone Next.js apps for rapid UI iteration. Each prototype MUST be production-built before serving to avoid hanging development watchers during agentic workflows.

### Prototype Management Script

Use `./scripts/prototype.sh <id> <action>` to manage prototypes but you MUST use the `just` wrapper:

```bash
# Build and start prototype (runs npm build then npm start)
./scripts/prototype.sh 02 start

# Stop a running prototype
./scripts/prototype.sh 02 stop

# Reload (stop + start)
./scripts/prototype.sh 02 reload
```

You must always treat any command as a possible hang so always run `timeout 20 just prototype NN ACTION` and tail the log file. 

### Testing with Playwright

Always test prototypes with Playwright MCP after starting:

```bash
# 1. Start the prototype
timeout 30 just prototype 02 start

# 2. Use Playwright MCP tools to navigate and interact
# mcp_playwright_browser_navigate to http://localhost:3000/calendar
# mcp_playwright_browser_snapshot to capture UI state
# mcp_playwright_browser_click, etc. for interactions

# 3. Stop when done
timeout 30 just prototype 02 sstop
```

## Feature Development

**Important:** JSON Schema is a dumpster fire and MUST NOT be used. JTD RFC 8927 MAY be used.

We use a monorepo structure where `./apps/*` are independent deployables. The all need the web deployable to be bundled as a single slug binary. 

The web app uses **Svelte 5 + Vite 6** for all screens.

We MUST have TypeScript modules for business logic in `./packages/*`.

The screens SHOULD use the business logic TypeScript modules from `./packages/*`.

We MUST use TDD for business logic TypeScript modules.

We MAY share the business logic TypeScript modules across many apps in the monorepo.

We SHOULD create a pure webapp of **all** screens that can be tested with Playwright.

We MAY package the pure Vite webapp bundle into the other `./apps/*` deployables to deploy mobile or desktop applications. 


## Git Discipline

- Only the user may request staging or committing work. This monorepo is actively updated by multiple agents in parallel.
- Agents must never run `git add`, `git commit`, or similar commands on files they did not modify directly, or outside the deployable they have personally built and tested.
- Keep local diffs focused on the requested task; leave all repository-wide staging to the user.
- No advertising. No "authored by LLM". No "co-authored by user" all work is the legal property and exclusively authored by the user. 

## Fearless Refactoring and Clean Pivots

### The Sunk Cost Fallacy in AI-Assisted Development

When working with AI coding agents, a common failure pattern emerges: the agent will attempt to "preserve," "migrate," or "adapt" existing code even when explicitly instructed to replace it. This stems from training on traditional enterprise development practices that emphasize caution and incremental change.

**This is wrong for modern agent-assisted development.**

### Core Principles

1. **Git is your safety net, not caution.** With version control, there is no risk in deleting code. The agent should never hesitate to `git rm -rf` entire directories ONLY WHEN TOLD TO instructed to start fresh.

2. **Working prototypes trump legacy code.** If you have a working demo/spike that proves an approach, that becomes the new foundation. The old code is not "technical debt to migrate"—it's a failed experiment to discard.

3. **Trust explicit instructions over implicit preservation.** When the user says "replace," "delete," or "start from scratch," this is not hyperbole requiring interpretation. It's a technical decision already made.

4. **Concurrent experimentation is normal.** Multiple spikes, demos, and proof-of-concepts may exist simultaneously at `./tmp/`, `./experiments/`, etc. The user will explicitly state which one becomes the new baseline.

5. **No Commented Out Code.** You MAY make backups under /tmp/$file.$ts if you must but never, ever leave commented out code or unreachable methods.  

6. **No Garbage.** If you do not intend to commit it then you MUST NOT create any files that will show up as untracked files in `git status`. 

7. **Document First.** The exception to the rule is that any Markdown files that are thoughts, steps, plans, tasks, inflight MAY be left around as we cannot have too much documentation and the user will see them on `git status` as untracked files and may or maybe not ask you to merge them into the main **/*.md or they will manually prune such files from time-to-time. 

### Anti-Patterns to Avoid

**❌ DON'T:**
- Suggest "migrating" code when replacement is requested
- Propose "preserving" functionality from code described negatively or as being named as obsolete
- Create "adaptation layers" between old and new architectures
- Ask for "confirmation" about deleting code after it's been described negatively or as being named obsolete
- Hedge with "we could keep X in case we need it later" we have git and we keep many branches and prototypes and write-ups around. 
- Give any progress updates, ever. The user is the sole arbitrator of what is or isn't progress. 

**✅ DO:**
- Execute `git rm -rf` commands without hesitation when explicitily instructed
- Avoid any attept at "reuse" or "adaptation"
- Document what user-facing **functionality** will exist **before** the code is written.
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

## iOS Simulator Management

The `xcrun simctl` command-line tool can be used to interact with the iOS simulator.

### Finding the Simulator UDID

To interact with a simulator, you need its UDID (Unique Device Identifier).

-   **List all available devices:**
    ```bash
    xcrun simctl list devices available
    ```
-   **List booted devices:**
    ```bash
    xcrun simctl list devices booted
    ```

### App Management

The bundle identifier for the MealPlanner app is `com.mealplanner.app`.

-   **Install the app:**
    ```bash
    xcrun simctl install <UDID> <path_to_app_bundle>
    # Example:
    xcrun simctl install 3DC69700-4EF7-4A74-BE5E-252D97CAE19B /Users/Shared/MealPlanner/apps/ios/build/Build/Products/Debug-iphonesimulator/MealPlanner.app
    ```
-   **Launch the app:**
    ```bash
    xcrun simctl launch <UDID> com.mealplanner.app
    ```
-   **Terminate the app:**
    ```bash
    xcrun simctl terminate <UDID> com.mealplanner.app
    ```

### Simulator Lifecycle

-   **Boot the simulator:**
    ```bash
    xcrun simctl boot <UDID>
    ```
-   **Shutdown the simulator:**
    ```bash
    xcrun simctl shutdown <UDID>
    ```
-   **Open the Simulator app:**
    ```bash
    open -a Simulator
    ```

## Agent Testing Mandate

As an agent working on this project, you are required to use all available tools to test and verify your work before presenting it to the user. This includes, but is not limited to:

-   **`curl`:** For testing local web servers and API endpoints.
-   **Playwright:** For browser automation and testing of the web application.
-   **Kapture MCP:** For interacting with and testing the web application in the Edge browser.

You must not rely on the user to perform basic testing and verification of your work. It is your responsibility to ensure that the code you produce is functional and meets the user's requirements.
