# MealPlanner Build Automation
# Use `just` to list all available commands

# Default recipe: list all available commands
default:
    @just --list

# Build and manage prototype servers
# Usage: just prototype <num> <action>
# Actions: start, stop, reload
prototype num action:
    sh ./scripts/prototype.sh {{num}} {{action}}

# Build webapp using Turbo cache (fast incremental)
build-webapp:
    turbo run build --filter @mealplanner/web

# Build webapp bypassing cache (clean build)
clean-build-webapp:
    turbo run build --filter @mealplanner/web --force

# Start webapp dev mode with Turbo
dev-webapp:
    turbo run dev --filter @mealplanner/web

# Start webapp production server
webapp action:
    sh ./scripts/webapp.sh {{action}}

# Clean all build artifacts
clean:
    turbo run clean

# Clean everything including node_modules
clean-all:
    turbo run clean && rm -rf node_modules apps/*/node_modules packages/*/node_modules

# Full repar of web
nuke-web:
    @echo "🩺 Running MealPlanner web environment doctor..."
    cd /Users/Shared/MealPlanner
    rm -rf node_modules pnpm-lock.yaml
    rm -rf node_modules/.pnpm/store
    pnpm store prune --force || true
    rm -rf "$(pnpm store path 2>/dev/null || echo ~/.pnpm-store)"
    pnpm install