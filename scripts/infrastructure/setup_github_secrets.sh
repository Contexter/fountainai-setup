#!/bin/bash

# Function to create GitHub secret if it doesn't exist
create_github_secret() {
  local secret_name=$1
  local secret_value=$2

  if gh secret list --repo "$GITHUB_REPO" | grep -q "$secret_name"; then
    echo "GitHub Secret '$secret_name' already exists."
  else
    echo "Creating GitHub Secret '$secret_name'..."
    echo "$secret_value" | gh secret set "$secret_name" --repo "$GITHUB_REPO"
    echo "GitHub Secret '$secret_name' created."
  fi
}

# Prompt for GitHub repository name if not set
if [ -z "$GITHUB_REPO" ]; then
  read -p "Enter your GitHub repository (user/repo): " GITHUB_REPO
fi

# Prompt for AWS credentials if not set
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  read -p "Enter your AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  read -p "Enter your AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
fi

# Define the other necessary variables
AWS_REGION="eu-central-1"
AVAILABILITY_ZONE="eu-central-1a"
BLUEPRINT_ID="ubuntu_20_04"
BUNDLE_ID="nano_2_0"

# Set the GitHub Secrets via gh CLI
create_github_secret "AWS_ACCESS_KEY_ID" "$AWS_ACCESS_KEY_ID"
create_github_secret "AWS_SECRET_ACCESS_KEY" "$AWS_SECRET_ACCESS_KEY"
create_github_secret "AWS_REGION" "$AWS_REGION"
create_github_secret "AVAILABILITY_ZONE" "$AVAILABILITY_ZONE"
create_github_secret "BLUEPRINT_ID" "$BLUEPRINT_ID"
create_github_secret "BUNDLE_ID" "$BUNDLE_ID"

echo "All required GitHub secrets have been set."

