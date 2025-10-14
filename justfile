# MealPlanner Build Automation
# Use `just` to list all available commands

# Default recipe: list all available commands
default:
    @just --list

# --- Web App --- #

# Manage web app: clean|bundle|dev start|dev stop|start|stop
web action *args:
    #!/usr/bin/env bash
    case "{{action}}" in
        clean)
            rm -rf apps/web/build apps/web/.svelte-kit
            ;;
        bundle)
            sh ./scripts/web-bundle.sh
            ;;
        dev)
            case "{{args}}" in
                start)
                    sh ./scripts/web-vite.sh start
                    ;;
                stop)
                    sh ./scripts/web-vite.sh stop
                    ;;
                *)
                    echo "Usage: just web dev {start|stop}"
                    echo ""
                    echo "  start  - Start Vite development server with HMR"
                    echo "  stop   - Stop Vite development server"
                    exit 1
                    ;;
            esac
            ;;
        start)
            sh ./scripts/web-serve.sh start
            ;;
        stop)
            sh ./scripts/web-serve.sh stop
            ;;
        *)
            echo "Usage: just web {clean|bundle|dev|start|stop}"
            echo ""
            echo "Actions:"
            echo "  clean        - Remove build artifacts"
            echo "  bundle       - Run the production build for native deployment"
            echo "  dev start    - Start Vite development server with HMR"
            echo "  dev stop     - Stop Vite development server"
            echo "  start        - Start bundled app server on port 3333"
            echo "  stop         - Stop bundled app server"
            exit 1
            ;;
    esac

# --- iOS --- #

# Deploy the web app bundle to the iOS project
ios-deploy:
    sh ./scripts/ios-deploy.sh

# Clean the iOS build artifacts
ios-clean:
    rm -rf apps/ios/build

# --- Android (DO NOT TOUCH) --- #

# Build the Android wrapper with the latest web bundle
build-android:
    sh ./scripts/build_android.sh

# Manage Android SDK / launch Android Studio
android-sdk action='studio':
    sh ./scripts/android_sdk.sh {{action}}

# Deploy Android app (rebuild web bundle, copy assets, build, install, launch)
deploy-android:
    sh ./scripts/build_and_deploy_ios.sh # This should be build_and_deploy_android.sh, but for now we use the ios one
    sh ./scripts/build_android.sh
    sh ./scripts/launch_android.sh

# Clean Android build artifacts (web bundle untouched)
clean-android:
    sh ./scripts/clean_android.sh

# --- Prototypes (DO NOT TOUCH) --- #

# Build and manage prototype servers
# Usage: just prototype <num> <action>
# Actions: start, stop, reload
prototype num action:
    sh ./scripts/prototype.sh {{num}} {{action}}

# --- Tooling --- #

# Run repomix to generate code context for a specific platform
# Usage: just repomix <platform> (e.g., web, ios, android, jfx)
repomix platform:
    sh ./scripts/repomix.sh {{platform}}

# --- Global --- #

# Clean all build artifacts
all-clean:
    just web clean
    just ios-clean
    just clean-android

# Full repair of web environment (clear pnpm cache and reinstall)
nuke-web:
    sh ./scripts/nuke_web.sh
