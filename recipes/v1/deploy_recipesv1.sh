#!/bin/bash

# deploy_recipesv1.sh - Deploy recipesv1 collection to Firebase
# This script orchestrates the complete data loading pipeline

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}RecipesV1 Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if Firebase CLI is available
if ! command -v firebase &> /dev/null; then
  echo -e "${RED}Error: Firebase CLI not found${NC}"
  echo "Install with: curl -sL https://firebase.tools | bash"
  exit 1
fi

# Check if dart is available
if ! command -v dart &> /dev/null; then
  echo -e "${RED}Error: Dart not found${NC}"
  echo "Install from: https://dart.dev/get-dart"
  exit 1
fi

# Step 1: Transform CSV to batch JSON files
echo ""
echo -e "${YELLOW}Step 1: Transform CSV to batch JSON files...${NC}"
cd "$SCRIPT_DIR"
if [ ! -f "transform_recipes_csv.dart" ]; then
  echo -e "${RED}Error: transform_recipes_csv.dart not found${NC}"
  exit 1
fi

dart run transform_recipes_csv.dart
if [ $? -ne 0 ]; then
  echo -e "${RED}CSV transformation failed${NC}"
  exit 1
fi

echo -e "${GREEN}✓ CSV transformation complete${NC}"

# Step 2: Set Firebase project
echo ""
echo -e "${YELLOW}Step 2: Configuring Firebase project...${NC}"
cd "$PROJECT_ROOT"
firebase use planmise
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Could not set Firebase project${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Firebase project set to planmise${NC}"

# Step 3: Deploy Firestore indexes
echo ""
echo -e "${YELLOW}Step 3: Deploying Firestore indexes...${NC}"
firebase deploy --only firestore:indexes
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Index deployment failed${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Firestore indexes deployed${NC}"

# Step 4: Upload recipes to Firestore
echo ""
echo -e "${YELLOW}Step 4: Uploading recipes to Firestore...${NC}"
cd "$PROJECT_ROOT/meal_planner"
dart run lib/scripts/load_recipes_v1.dart
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Recipe upload failed${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Recipes uploaded to Firestore${NC}"

# Step 5: Deploy Firestore rules
echo ""
echo -e "${YELLOW}Step 5: Deploying Firestore security rules...${NC}"
cd "$PROJECT_ROOT"
firebase deploy --only firestore:rules
if [ $? -ne 0 ]; then
  echo -e "${RED}Error: Rules deployment failed${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Firestore rules deployed${NC}"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "RecipesV1 collection is now ready in Firebase!"
echo "Collection path: recipes_v1"
echo "Total recipes: Check Firebase console"
echo ""
