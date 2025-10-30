#!/bin/bash

# setup_recipesv1.sh - Set up recipesv1 collection in Firestore
# This script reads recipe titles from the extracted dataset and uploads them to Firestore

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(dirname "$(dirname "$PROJECT_DIR")")"

# Configuration
FIREBASE_PROJECT="planmise"
COLLECTION_NAME="recipesv1"
RECIPES_FILE="${REPO_ROOT}/.tmp/recipe_dataset_titles.txt"
DART_SCRIPT="${SCRIPT_DIR}/upload_recipes.dart"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up recipesv1 in Firestore...${NC}"

# Check if recipes file exists
if [ ! -f "$RECIPES_FILE" ]; then
  echo -e "${RED}Error: Recipe file not found at $RECIPES_FILE${NC}"
  echo "Make sure you have extracted recipes using the extraction scripts."
  exit 1
fi

# Check if Firebase CLI is available
if ! command -v firebase &> /dev/null; then
  echo -e "${RED}Error: Firebase CLI not found. Install with: curl -sL https://firebase.tools | bash${NC}"
  exit 1
fi

# Verify Firebase is using correct project
echo -e "${YELLOW}Verifying Firebase project...${NC}"
CURRENT_PROJECT=$(firebase use 2>&1 | grep "Using project" | awk '{print $3}' || echo "")
if [ "$CURRENT_PROJECT" != "$FIREBASE_PROJECT" ]; then
  echo -e "${YELLOW}Switching to project: $FIREBASE_PROJECT${NC}"
  firebase use "$FIREBASE_PROJECT"
fi

# Run Dart script to upload recipes
echo -e "${YELLOW}Uploading recipes to Firestore...${NC}"
if [ -f "$DART_SCRIPT" ]; then
  cd "$SCRIPT_DIR"
  dart run upload_recipes.dart "$RECIPES_FILE"
else
  echo -e "${RED}Error: Dart script not found at $DART_SCRIPT${NC}"
  echo "Please ensure upload_recipes.dart exists in the recipes/v1 directory."
  exit 1
fi

echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${GREEN}Recipe collection 'recipesv1' has been created in Firestore.${NC}"
