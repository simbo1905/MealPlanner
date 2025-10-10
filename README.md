# MealPlanner

A family meal planning application built with a modern monorepo architecture.

## Tech Stack

**Web Application** (`apps/web`)
- Svelte 5 with runes
- Vite 6
- TypeScript
- Tailwind CSS

**Shared Packages** (`packages/*`)
- Recipe types, validation, and database logic
- TypeScript with strict typing
- Vitest for testing

**Mobile** (`apps/ios`, `apps/android`)
- WebView wrappers for the web application
- Native Swift (iOS) and Kotlin (Android)

## Quick Start

```bash
# Install dependencies
pnpm install

# Build shared packages
pnpm build:packages

# Start web dev server
pnpm dev:web
# Opens at http://localhost:3001

# Or use just commands
just webapp start
```

## Development

See [AGENTS.md](./AGENTS.md) for comprehensive development guidelines.

### Key Commands

```bash
# Development
pnpm dev              # All packages + webapp
pnpm dev:web          # Webapp only

# Building
pnpm build            # All packages + apps
pnpm build:web        # Webapp only
pnpm build:packages   # Shared packages only

# Testing
pnpm test             # Run all tests
pnpm typecheck        # Type checking
pnpm lint             # Linting

# Prototypes (Next.js reference implementations)
just prototype 02 start   # Start on :3000
just prototype 02 stop
```

## Project Structure

```
apps/
  web/          # Svelte + Vite PWA
  ios/          # iOS WebView wrapper
  android/      # Android WebView wrapper
packages/
  recipe-types/      # Shared TypeScript types
  recipe-validator/  # JSON validation
  recipe-database/   # Recipe data & search
tooling/
  typescript/   # Shared TS config
  eslint/       # Shared lint rules
  prettier/     # Shared formatting
```

## Requirements

- Node.js ≥22.11
- pnpm ≥9.12
- mise (for tooling)

```bash
mise install
mise use
```
