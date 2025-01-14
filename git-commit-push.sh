#!/bin/bash
# git-commit-push.sh

# Check if commit message is provided
if [ -z "$1" ]; then
    echo "Please provide a commit message"
    exit 1
fi

# Store the current branch
CURRENT_BRANCH=$(git branch --show-current)

# Ensure we're on main branch
git checkout main 2>/dev/null || git checkout -b main

# Add all changes
git add .

# Commit changes
git commit -m "$1"

# Push to remote
git push origin main

# Return to original branch if different
if [ "$CURRENT_BRANCH" != "main" ]; then
    git checkout "$CURRENT_BRANCH"
fi