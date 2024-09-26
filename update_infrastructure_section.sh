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

# Ensure the required directories exist for infrastructure tasks and documentation
create_directory "./scripts/infrastructure"
create_directory "./docs/infrastructure"

# Create the necessary infrastructure setup script and documentation
create_file "./scripts/infrastructure/setup_lightsail_runner.sh"
create_file "./docs/infrastructure/setup_lightsail_runner.md"

# Notify the user of completion
echo "Infrastructure directory and files have been created."

