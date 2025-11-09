#!/usr/bin/env bash
set -euo pipefail

# Ensure .project_name exists; prompt until a valid name is provided.
REGEX='^[a-z0-9-]{3,9}$'
HELPER='Must match: ^[a-z0-9-]{3,9}$ (max 9 lowercase,numbers,dash)'
EXCLUDE=("./.git/*" "./devenv.nix")

if [ -f .project_name ]; then
  echo ".project_name exists; skipping"
  exit 0
fi

trap 'echo; echo "Interrupted; aborting"; exit 1' INT

while true; do
  printf "Enter project name (3-9 lowercase, numbers, dash) - %s: " "$HELPER"
  if ! read -r PN; then
    echo "No input available; aborting" >&2
    exit 1
  fi

  if printf '%s' "$PN" | grep -Eq "$REGEX"; then
    # Perform replacements inline (same behavior as original init_project.sh)
    # Exclude paths (configured above) so we don't accidentally modify sensitive files.
    exclude_args=()
    for p in "${EXCLUDE[@]}"; do
      exclude_args+=("!" "-path" "$p")
    done

    find . -type f "${exclude_args[@]}" -exec sed -i "s/__PROJECT_NAME__/${PN}/g" {} + || {
      echo "replacement failed; aborting"
      exit 1
    }

    printf '%s\n' "$PN" >.project_name

    git stash push
    git add .project_name
    if git commit -m "Setting project name: \"$PN\"" -- .project_name; then
      echo ".project_name written and committed"
      git stash pop
      exit 0
    else
      echo "git commit failed; aborting" >&2
      git stash pop
      exit 1
    fi
  else
    echo "Invalid project name; $HELPER"
  fi
done
