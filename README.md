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
- WebView wrappers loading Vite static bundle
- Native Swift (iOS) and Kotlin (Android)


## Setup

This project uses `mise` to manage all required tooling, including Node.js, pnpm, just, and bun. To get started, ensure you have `mise` installed, then set up the project environment:

```bash
# Install tools defined in .mise.toml (e.g., node, pnpm, just, bun)
mise install
```

## Quick Start

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

# Native bundle workflow
timeout 20 just web clean   # Remove prior build artifacts
timeout 20 just web bundle  # Run SvelteKit production build (apps/web/build)
timeout 20 just web start   # Serve build locally on :3333 for verification

# Prototypes (legacy Next.js visual mockups only)
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
