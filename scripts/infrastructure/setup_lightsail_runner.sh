#!/bin/bash

# FountainAI Norm: Step Zero - Lightsail-runner Setup for GitHub Actions with Secure Key and Token Management

# Variables (Customize as needed)
GITHUB_REPO="<your-github-repo>"           # Your GitHub repository, e.g., user/repo
AWS_REGION="eu-central-1"                  # AWS region for Lightsail and Secrets Manager (Frankfurt)
AVAILABILITY_ZONE="eu-central-1a"          # Availability zone in Frankfurt region
BLUEPRINT_ID="ubuntu_20_04"                # OS blueprint for the instance (Ubuntu 20.04)
BUNDLE_ID="nano_2_0"                       # Instance size (e.g., nano, micro, small)
SSH_KEY_NAME="lightsail_key_Lightsail-runner"  # Name of the SSH key pair

# Secret names for SSH key and runner token
GITHUB_SECRET_RUNNER_TOKEN="ACTIONS_RUNNER_TOKEN"  # Runner token stored as GitHub secret

# Function to check and install GitHub CLI
check_and_install_github_cli() {
  if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. Installing..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update && sudo apt install gh -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install gh
    else
      echo "Unsupported OS. Please install GitHub CLI manually."
      exit 1
    fi
  fi

  if ! gh auth status &> /dev/null; then
    echo "GitHub CLI not authenticated. Please authenticate."
    gh auth login
  fi
}

# Function to check and install AWS CLI
check_and_install_aws_cli() {
  if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update && sudo apt install awscli -y
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install awscli
    else
      echo "Unsupported OS. Please install AWS CLI manually."
      exit 1
    fi
  fi

  if ! aws sts get-caller-identity &> /dev/null; then
    echo "AWS CLI not authenticated. Please configure AWS credentials."
    aws configure
  fi
}

# Function to check if a Lightsail instance exists
check_lightsail_instance() {
  INSTANCE_NAME="Lightsail-runner"
  echo "Checking for Lightsail instance: $INSTANCE_NAME..."
  
  INSTANCE_EXISTS=$(aws lightsail get-instances --query "instances[?name=='$INSTANCE_NAME'].name" --output text --region "$AWS_REGION")
  
  if [ -z "$INSTANCE_EXISTS" ]; then
    echo "Instance $INSTANCE_NAME not found. Creating instance..."
    create_lightsail_instance "$INSTANCE_NAME"
  else
    echo "Instance $INSTANCE_NAME exists."
  fi
}

# Function to create a new Lightsail instance
create_lightsail_instance() {
  INSTANCE_NAME="Lightsail-runner"
  echo "Creating Lightsail instance: $INSTANCE_NAME..."
  
  aws lightsail create-instances \
    --instance-names "$INSTANCE_NAME" \
    --availability-zone "$AVAILABILITY_ZONE" \
    --blueprint-id "$BLUEPRINT_ID" \
    --bundle-id "$BUNDLE_ID" \
    --region "$AWS_REGION"
  
  echo "Instance $INSTANCE_NAME is being created. Please wait for it to become active..."
  aws lightsail wait instance-running --instance-name "$INSTANCE_NAME" --region "$AWS_REGION"
  
  echo "Instance $INSTANCE_NAME is now active."
}

# Function to retrieve runner token from GitHub Secrets
retrieve_runner_token() {
  echo "Retrieving GitHub Actions runner token from GitHub Secrets..."
  gh secret list --repo "$GITHUB_REPO" | grep -q "$GITHUB_SECRET_RUNNER_TOKEN"
  
  if [ $? -ne 0 ]; then
    echo "Runner token not found in GitHub Secrets."
    exit 1
  fi

  echo "Runner token found. Retrieving..."
  RUNNER_TOKEN=$(gh secret view "$GITHUB_SECRET_RUNNER_TOKEN" --repo "$GITHUB_REPO")
}

# Function to install and configure GitHub Actions runner on the Lightsail-runner instance
install_github_runner() {
  INSTANCE_NAME="Lightsail-runner"
  RUNNER_DIR="/home/ubuntu/actions-runner"

  echo "Installing GitHub Actions runner on $INSTANCE_NAME..."

  ssh -i ~/.ssh/$SSH_KEY_NAME ubuntu@$INSTANCE_NAME << EOF
    mkdir -p $RUNNER_DIR
    cd $RUNNER_DIR
    curl -o actions-runner-linux-x64-2.285.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.285.0/actions-runner-linux-x64-2.285.0.tar.gz
    tar xzf ./actions-runner-linux-x64-2.285.0.tar.gz
    ./config.sh --url https://github.com/$GITHUB_REPO --token $RUNNER_TOKEN
    sudo ./svc.sh install
    sudo ./svc.sh start
EOF

  echo "GitHub Actions runner installed and configured on $INSTANCE_NAME."
}

# Use the fountainai_key_manager.sh script for SSH key management
manage_ssh_keys() {
  echo "Running FountainAI key management module..."
  ./scripts/modules/fountainai_key_manager.sh "$GITHUB_REPO" "$SSH_KEY_NAME" "$AWS_REGION"
}

# Main Execution
check_and_install_github_cli        # Check and install GitHub CLI if necessary
check_and_install_aws_cli           # Check and install AWS CLI if necessary
check_lightsail_instance            # Check if Lightsail-runner instance exists, create if not
manage_ssh_keys                     # Use the key management module to handle SSH keys
retrieve_runner_token               # Retrieve runner token from GitHub Secrets
install_github_runner               # Install GitHub Actions runner on Lightsail-runner

echo "FountainAI Lightsail-runner setup complete with secure key and token management."

