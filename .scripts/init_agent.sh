#!/usr/bin/env bash
set -euo pipefail

BRANCH="agent/dev"
TARGET_REL="../$BRANCH"
TARGET="$(realpath "$TARGET_REL")"

# If the target path already exists and is a directory, assume it's fine.
if [ -d "$TARGET" ]; then
  echo "Worktree already exists at $TARGET"
else
  # If any worktree already references this branch, skip adding.
  if git worktree list --porcelain 2>/dev/null | grep -q "refs/heads/$BRANCH"; then
    echo "Branch $BRANCH already used by an existing worktree; skipping add"
  else
    if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
      git worktree add "$TARGET" "$BRANCH" || echo "git worktree add failed; skipping"
    else
      git worktree add -b "$BRANCH" "$TARGET" || echo "git worktree add -b failed; skipping"
    fi
  fi
fi

# If the directory exists after the above, cd into it and give instructions.
if [ -d "$TARGET" ]; then
  cd "$TARGET"
  echo "Run \`cd $(pwd) && direnv allow\`"
fi
