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

# Build webapp with pnpm
build-webapp:
    pnpm build:web

# Build webapp with clean cache
clean-build-webapp:
    pnpm clean:web && pnpm build:web

# Start webapp dev mode
dev-webapp:
    pnpm dev:web

# Start webapp production server
webapp action:
    sh ./scripts/webapp.sh {{action}}

# Clean all build artifacts
clean:
    pnpm clean

# Clean everything including node_modules
clean-all:
    pnpm clean && rm -rf node_modules apps/*/node_modules packages/*/node_modules

# Full repair of web environment (clear pnpm cache and reinstall)
nuke-web:
    @echo "🩺 Running MealPlanner web environment doctor..."
    rm -rf node_modules pnpm-lock.yaml
    rm -rf node_modules/.pnpm/store
    pnpm store prune --force || true
    rm -rf "$(pnpm store path 2>/dev/null || echo ~/.pnpm-store)"
    pnpm install

# Build webapp to static bundle for deployment
build-bundle:
    sh ./scripts/build_webapp_bundle.sh

# Deploy webapp bundle to iOS Resources
deploy-ios:
    sh ./scripts/build_webapp_bundle.sh
    sh ./scripts/deploy_webapp_to_ios.sh

# Deploy webapp bundle to Android assets
deploy-android:
    sh ./scripts/build_webapp_bundle.sh
    sh ./scripts/deploy_webapp_to_android.sh