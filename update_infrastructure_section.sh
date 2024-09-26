#!/bin/bash

# Function to create directory if it doesn't exist
create_directory() {
  local dir=$1
  if [ ! -d "$dir" ]; then
    echo "Creating directory: $dir"
    mkdir -p "$dir"
  else
    echo "Directory already exists: $dir"
  fi
}

# Function to create file if it doesn't exist
create_file() {
  local file=$1
  if [ ! -f "$file" ]; then
    echo "Creating file: $file"
    touch "$file"
  else
    echo "File already exists: $file"
  fi
}

# Ensure the required directories exist
create_directory "./scripts/infrastructure"
create_directory "./docs/modules"
create_directory "./.github/workflows"

# Create the necessary infrastructure setup script and documentation
create_file "./scripts/infrastructure/setup_lightsail_runner.sh"
create_file "./docs/modules/setup_lightsail_runner.md"

# Create the GitHub workflow for manually setting up Lightsail runner
WORKFLOW_FILE="./.github/workflows/setup_lightsail_runner.yml"

if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "Creating GitHub Action workflow for Lightsail Runner setup..."
  cat <<EOL > "$WORKFLOW_FILE"
name: Setup Lightsail Runner

on:
  workflow_dispatch:

jobs:
  setup-lightsail-runner:
    name: Setup Lightsail-Runner Instance
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up GitHub CLI
        uses: actions/setup-gh@v1

      - name: Set up AWS CLI
        uses: aws-actions/configure-aws-cli@v1
        with:
          aws-access-key-id: \${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: \${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-central-1

      - name: Run Lightsail-Runner Setup Script
        run: |
          chmod +x ./scripts/infrastructure/setup_lightsail_runner.sh
          ./scripts/infrastructure/setup_lightsail_runner.sh
EOL
  echo "Workflow created at $WORKFLOW_FILE"
else
  echo "Workflow file already exists: $WORKFLOW_FILE"
fi

# Notify the user of completion
echo "Repository structure updated: Infrastructure directories, files, and GitHub Action workflow created."

