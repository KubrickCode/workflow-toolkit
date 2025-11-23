#!/bin/bash
# get-item-status.sh - Gets the current status of an item in a project
# Usage: ./get-item-status.sh <project_id> <content_id> <status_field_name> [max_pages]
# Outputs: item_id, current_status

set -euo pipefail

PROJECT_ID="$1"
CONTENT_ID="$2"
STATUS_FIELD_NAME="${3:-Status}"
MAX_PAGES="${4:-10}"

echo "::group::Searching for item status in project" >&2
echo "Looking for content: $CONTENT_ID" >&2

CURSOR=""
FOUND=false
ITEM_ID=""
CURRENT_STATUS=""

for ((i=1; i<=MAX_PAGES; i++)); do
  if [ -z "$CURSOR" ]; then
    ITEMS_QUERY=$(gh api graphql -f query='
      query($projectId: ID!) {
        node(id: $projectId) {
          ... on ProjectV2 {
            items(first: 100) {
              pageInfo {
                hasNextPage
                endCursor
              }
              nodes {
                id
                content {
                  ... on Issue { id }
                  ... on PullRequest { id }
                }
                fieldValues(first: 20) {
                  nodes {
                    ... on ProjectV2ItemFieldSingleSelectValue {
                      name
                      field {
                        ... on ProjectV2SingleSelectField {
                          name
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    ' -f projectId="$PROJECT_ID")
  else
    ITEMS_QUERY=$(gh api graphql -f query='
      query($projectId: ID!, $cursor: String!) {
        node(id: $projectId) {
          ... on ProjectV2 {
            items(first: 100, after: $cursor) {
              pageInfo {
                hasNextPage
                endCursor
              }
              nodes {
                id
                content {
                  ... on Issue { id }
                  ... on PullRequest { id }
                }
                fieldValues(first: 20) {
                  nodes {
                    ... on ProjectV2ItemFieldSingleSelectValue {
                      name
                      field {
                        ... on ProjectV2SingleSelectField {
                          name
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    ' -f projectId="$PROJECT_ID" -f cursor="$CURSOR")
  fi

  # Find the item matching our content ID
  ITEM_DATA=$(echo "$ITEMS_QUERY" | jq -r --arg CID "$CONTENT_ID" '.data.node.items.nodes[] | select(.content.id == $CID)')

  if [ -n "$ITEM_DATA" ] && [ "$ITEM_DATA" != "null" ]; then
    ITEM_ID=$(echo "$ITEM_DATA" | jq -r '.id')
    CURRENT_STATUS=$(echo "$ITEM_DATA" | jq -r --arg FIELD "$STATUS_FIELD_NAME" '.fieldValues.nodes[] | select(.field.name == $FIELD) | .name')
    FOUND=true
    break
  fi

  HAS_NEXT=$(echo "$ITEMS_QUERY" | jq -r '.data.node.items.pageInfo.hasNextPage')
  if [ "$HAS_NEXT" = "false" ]; then
    break
  fi

  CURSOR=$(echo "$ITEMS_QUERY" | jq -r '.data.node.items.pageInfo.endCursor')
  echo "Page $i completed, continuing..." >&2
done

echo "::endgroup::" >&2

if [ "$FOUND" = true ] && [ -n "$ITEM_ID" ] && [ "$ITEM_ID" != "null" ]; then
  echo "item_id=$ITEM_ID"
  if [ -n "$CURRENT_STATUS" ] && [ "$CURRENT_STATUS" != "null" ]; then
    echo "current_status=$CURRENT_STATUS"
    echo "Found item with status: $CURRENT_STATUS" >&2
  else
    echo "current_status="
    echo "Found item but no status set" >&2
  fi
else
  echo "::warning::Item not found in project after searching $MAX_PAGES pages" >&2
  echo "item_id="
  echo "current_status="
fi
