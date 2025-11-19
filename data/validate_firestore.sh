#!/bin/bash
set -euo pipefail

PROJECT="${FIREBASE_PROJECT:-planmise}"
COLLECTION="recipesv1"

if ! command -v gcloud >/dev/null 2>&1; then
  echo "gcloud CLI is required. Install from https://cloud.google.com/sdk/install" >&2
  exit 127
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required for parsing Firestore query results. Install via brew install jq" >&2
  exit 127
fi

if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
  echo "GOOGLE_APPLICATION_CREDENTIALS must point to a service account JSON with Firestore access." >&2
  exit 78
fi

ACCESS_TOKEN=$(gcloud auth application-default print-access-token)
BASE_URL="https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)"

echo "Listing first 5 documents from ${COLLECTION}..."
QUERY_JSON=$(cat <<EOF
{
  "structuredQuery": {
    "from": [{"collectionId": "${COLLECTION}"}],
    "orderBy": [{"field": {"fieldPath": "__name__"}, "direction": "ASCENDING"}],
    "limit": 5
  }
}
EOF
)
RESPONSE=$(curl -s "${BASE_URL}/documents:runQuery" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$QUERY_JSON")

if echo "$RESPONSE" | grep -q '"error":'; then
  echo "Error listing documents:"
  echo "$RESPONSE"
  exit 1
fi

echo "$RESPONSE" | jq -r '.[].document | select(. != null) | "- \(.name | split("/") | last): \(.fields.title.stringValue // .fields.title.mapValue.fields.stringValue.stringValue // "(missing title)")"'

echo ""
echo "Counting documents via aggregation..."
AGG_JSON=$(cat <<EOF
{
  "structuredAggregationQuery": {
    "structuredQuery": {
      "from": [{"collectionId": "${COLLECTION}"}]
    },
    "aggregations": [{"alias": "total", "count": {}}]
  }
}
EOF
)
AGG_RESPONSE=$(curl -s "${BASE_URL}/documents:runAggregationQuery" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$AGG_JSON")

if echo "$AGG_RESPONSE" | grep -q '"error":'; then
  echo "Error counting documents:"
  echo "$AGG_RESPONSE"
  exit 1
fi

echo "$AGG_RESPONSE" \
  | jq -r '.[].result.aggregateFields.total.integerValue // "0"' \
  | awk '{print "Total documents: " $0}'

echo ""
echo "Prefix query (chicken)..."
PREFIX_JSON=$(cat <<EOF
{
  "structuredQuery": {
    "from": [{"collectionId": "${COLLECTION}"}],
    "where": {
      "compositeFilter": {
        "op": "AND",
        "filters": [
          {"fieldFilter": {"field": {"fieldPath": "titleLower.stringValue"}, "op": "GREATER_THAN_OR_EQUAL", "value": {"stringValue": "chicken"}}},
          {"fieldFilter": {"field": {"fieldPath": "titleLower.stringValue"}, "op": "LESS_THAN_OR_EQUAL", "value": {"stringValue": "chicken\uF8FF"}}}
        ]
      }
    },
    "limit": 5
  }
}
EOF
)
PREFIX_RESPONSE=$(curl -s "${BASE_URL}/documents:runQuery" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$PREFIX_JSON")

if echo "$PREFIX_RESPONSE" | grep -q '"error":'; then
  echo "Error performing prefix query:"
  echo "$PREFIX_RESPONSE"
  exit 1
fi

echo "$PREFIX_RESPONSE" \
  | jq -r '.[].document | select(. != null) | (.fields.title.stringValue // .fields.title.mapValue.fields.stringValue.stringValue // empty)'