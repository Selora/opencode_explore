#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <project-name>" >&2
  exit 1
fi

PROJECT_NAME="$1"

# Validate: must start with a lowercase letter, contain only [a-z0-9_-]
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]{3,9}$ ]]; then
  echo "Invalid project name: $PROJECT_NAME" >&2
  echo "Must match: ^[a-z0-9-]{3,9}$ (max 9 lowercase,numbers,dash)" >&2
  exit 1
fi

# Run sed across all tracked files except .git/
find . -type f ! -path "./.git/*" -exec sed -i "s/ocode-ex/${PROJECT_NAME}/g" {} +

echo "All occurrences of ocode-ex replaced with '$PROJECT_NAME'."
echo "Good to go!"
