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
