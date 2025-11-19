#!/bin/bash
. "$(dirname "$0")/../../scripts/load_env.sh"

# setup_recipesv1.sh - Build Firestore import bundle for recipesv1 and load via Firebase CLI
# This script generates a Firestore import JSON file and imports it using firebase firestore:import

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(dirname "$PROJECT_DIR")"

FIREBASE_PROJECT="planmise"
COLLECTION_NAME="recipesv1"
RECIPES_FILE="${REPO_ROOT}/data/recipe_dataset_titles.txt"
IMPORT_FILE="${REPO_ROOT}/.tmp/firestore_import.json"
PYTHON_GENERATOR="${SCRIPT_DIR}/generate_firestore_import.py"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Preparing Firestore import bundle for ${COLLECTION_NAME}...${NC}"

# Check if recipes file exists
if [ ! -f "$RECIPES_FILE" ]; then
  echo -e "${RED}Error: Recipe file not found at $RECIPES_FILE${NC}"
  echo "Make sure you have extracted recipes using the extraction scripts."
  exit 1
fi

for dependency in python3; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    echo -e "${RED}Error: '$dependency' not found in PATH${NC}"
    exit 1
  fi
done

if [ ! -f "$PYTHON_GENERATOR" ]; then
  echo -e "${RED}Error: Generator script not found at $PYTHON_GENERATOR${NC}"
  exit 1
fi

echo -e "${YELLOW}Generating Firestore import JSON...${NC}"
python3 "$PYTHON_GENERATOR" --input "$RECIPES_FILE" --output "$IMPORT_FILE" --collection "$COLLECTION_NAME"

if [ ! -f "$IMPORT_FILE" ]; then
  echo -e "${RED}Error: Import file not created at $IMPORT_FILE${NC}"
  exit 1
fi

echo -e "${YELLOW}Importing recipes via Python script...${NC}"
python3 "${SCRIPT_DIR}/import_to_firestore.py" --input "$IMPORT_FILE" --collection "$COLLECTION_NAME"

echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${GREEN}Recipe collection '$COLLECTION_NAME' has been imported into Firestore.${NC}"
