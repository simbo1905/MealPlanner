# Recipe Data Loading - Quick Start

## Prerequisites
- Firebase CLI installed: `curl -sL https://firebase.tools | bash`
- Python 3 available in your PATH
- Firebase project authenticated: `firebase login`

## Data Source
- **File:** `.tmp/recipe_dataset_titles.txt` (13,496 recipe titles)
- **Origin:** Epicurious/Condé Nast via Joseph Martinez's recipe-dataset
- **License:** CC BY-SA 3.0 (see `/ATTRIBUTION.md`)

## Load Data

### Step 1: Build and Import to Firestore
```bash
cd recipes/v1
./setup_recipesv1.sh
```

This will:
1. Generate `.tmp/firestore_import.json` from the titles file
2. Import to Firestore collection `recipesv1`

### Step 2: Validate with gcloud + REST
```bash
GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/serviceAccount.json ./data/validate_firestore.sh
```

Expected output:
- Sample documents
- Approximate document count (resultSizeEstimate)
- Prefix query results (e.g., chicken)

### Step 3: Test Dart Query
```bash
GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/serviceAccount.json dart run data/query_recipes_cli.dart "pasta"
```

Expected: List of matching recipe titles from Firestore (IDs + titles)

## Firestore Collection Structure
```
recipesv1/
  recipe_{id}/
    ├── title: string
    ├── titleLower: string (indexed for search)
    ├── titleWords: array<string> (tokenized words)
    └── createdAt: timestamp
```

## Security Rules
- Collection is world-readable in current `firestore.rules`; adjust before production.
- Command-line tools require a service account with Firestore read access.

## Indexes
The collection has indexes on:
- `titleLower` + `createdAt` (for prefix search with sorting)
- See `/firestore.indexes.json`
