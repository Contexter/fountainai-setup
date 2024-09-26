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
create_directory "./.github/workflows"
create_directory "./scripts/modules"
create_directory "./docs/modules"

# Create the necessary GitHub workflow files if they don't exist
create_file "./.github/workflows/configure_docker.yml"
create_file "./.github/workflows/configure_kong.yml"
create_file "./.github/workflows/configure_opensearch.yml"

# Create the module-specific script and doc files
create_file "./scripts/modules/fountainai_key_manager.sh"
create_file "./docs/modules/fountainai_key_manager.md"

# Notify the user of completion
echo "Repository structure has been updated non-destructively to match the layout in the README."

