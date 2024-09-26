#!/bin/bash

# FountainAI Key Management - A reusable module for SSH key management with GitHub Secrets and AWS Secrets Manager.

# Variables (Customize or pass as needed)
AWS_REGION="eu-central-1"  # AWS region for Secrets Manager (e.g., Frankfurt)

# Function to create SSH key pair if it doesn't exist
create_ssh_key_pair() {
  local SSH_KEY_NAME=$1
  local EMAIL=$2

  if [ ! -f "~/.ssh/$SSH_KEY_NAME" ]; then
    echo "Generating SSH key pair for $SSH_KEY_NAME..."
    ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f ~/.ssh/$SSH_KEY_NAME -N ""
    echo "SSH key pair created: $SSH_KEY_NAME"
  else
    echo "SSH key pair $SSH_KEY_NAME already exists."
  fi
}

# Function to retrieve private SSH key from GitHub Secrets
retrieve_private_key() {
  local GITHUB_REPO=$1
  local GITHUB_SECRET_SSH_PRIVATE=$2
  local SSH_KEY_NAME=$3

  echo "Retrieving private SSH key from GitHub Secrets for $SSH_KEY_NAME..."
  
  if ! gh secret list --repo "$GITHUB_REPO" | grep -q "$GITHUB_SECRET_SSH_PRIVATE"; then
    echo "Private key not found in GitHub Secrets."
    exit 1
  fi

  PRIVATE_KEY=$(gh secret view "$GITHUB_SECRET_SSH_PRIVATE" --repo "$GITHUB_REPO")
  echo "$PRIVATE_KEY" > ~/.ssh/$SSH_KEY_NAME
  chmod 600 ~/.ssh/$SSH_KEY_NAME

  echo "Private SSH key retrieved and stored as $SSH_KEY_NAME."
}

# Function to store private SSH key in GitHub Secrets
store_private_key_in_github() {
  local GITHUB_REPO=$1
  local GITHUB_SECRET_SSH_PRIVATE=$2
  local SSH_KEY_PATH=$3

  echo "Storing private SSH key in GitHub Secrets for $SSH_KEY_PATH..."
  
  PRIVATE_KEY=$(cat "$SSH_KEY_PATH")
  echo "$PRIVATE_KEY" | gh secret set "$GITHUB_SECRET_SSH_PRIVATE" --repo "$GITHUB_REPO"

  echo "Private SSH key stored in GitHub Secrets."
}

# Function to retrieve public SSH key from AWS Secrets Manager
retrieve_public_key() {
  local AWS_SECRET_SSH_PUBLIC=$1
  local SSH_KEY_NAME=$2

  echo "Retrieving public SSH key from AWS Secrets Manager for $SSH_KEY_NAME..."
  
  PUBLIC_KEY=$(aws secretsmanager get-secret-value --secret-id "$AWS_SECRET_SSH_PUBLIC" --query SecretString --output text --region "$AWS_REGION")

  if [ -z "$PUBLIC_KEY" ]; then
    echo "Public key not found in AWS Secrets Manager."
    exit 1
  fi

  echo "$PUBLIC_KEY" > ~/.ssh/$SSH_KEY_NAME.pub

  echo "Public SSH key retrieved and stored as $SSH_KEY_NAME.pub."
}

# Function to store public SSH key in AWS Secrets Manager
store_public_key_in_aws() {
  local AWS_SECRET_SSH_PUBLIC=$1
  local SSH_KEY_PATH=$2
  local INSTANCE_NAME=$3

  echo "Storing public SSH key in AWS Secrets Manager for $INSTANCE_NAME..."

  PUBLIC_KEY=$(cat "$SSH_KEY_PATH.pub")
  aws secretsmanager create-secret --name "$AWS_SECRET_SSH_PUBLIC" \
    --description "Public SSH Key for $INSTANCE_NAME" \
    --secret-string "$PUBLIC_KEY" \
    --region "$AWS_REGION"

  echo "Public SSH key stored in AWS Secrets Manager."
}

# Function to manage SSH keys (create, store, and retrieve) for an instance
manage_ssh_keys() {
  local GITHUB_REPO=$1
  local INSTANCE_NAME=$2
  local GITHUB_SECRET_SSH_PRIVATE="LIGHTSAIL_SSH_PRIVATE_KEY_$INSTANCE_NAME"
  local AWS_SECRET_SSH_PUBLIC="lightsail_public_key_$INSTANCE_NAME"
  local SSH_KEY_NAME="lightsail_key_$INSTANCE_NAME"
  local EMAIL="ssh-$INSTANCE_NAME@example.com"

  # Create SSH key pair if not present
  create_ssh_key_pair "$SSH_KEY_NAME" "$EMAIL"

  # Store private key in GitHub Secrets
  store_private_key_in_github "$GITHUB_REPO" "$GITHUB_SECRET_SSH_PRIVATE" "~/.ssh/$SSH_KEY_NAME"

  # Store public key in AWS Secrets Manager
  store_public_key_in_aws "$AWS_SECRET_SSH_PUBLIC" "~/.ssh/$SSH_KEY_NAME" "$INSTANCE_NAME"

  # Retrieve and verify keys
  retrieve_private_key "$GITHUB_REPO" "$GITHUB_SECRET_SSH_PRIVATE" "$SSH_KEY_NAME"
  retrieve_public_key "$AWS_SECRET_SSH_PUBLIC" "$SSH_KEY_NAME"

  echo "SSH key management complete for instance: $INSTANCE_NAME"
}
