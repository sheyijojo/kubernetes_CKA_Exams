#!/bin/bash

# Check if a commit message was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <commit-message>"
  exit 1
fi

# Run git commands
git add .
git commit -m "$1"
git push

# Confirm success
if [ $? -eq 0 ]; then
  echo "Changes pushed successfully! í¾‰"
else
  echo "An error occurred while pushing changes. âŒ"
fi

