### **FountainAI Paper: SSH Key Management Module for Secure Infrastructure**

#### **Title**: FountainAI Secure SSH Key Management Module for Lightsail Instances

#### **Version**: 1.0

#### **Author**: Contexter

#### **Date**: September 2024

---

### **Abstract**:

This paper describes a reusable, modular system for managing SSH key pairs (both public and private) securely, using **GitHub Secrets** and **AWS Secrets Manager** for **FountainAI infrastructure deployments** on **AWS Lightsail**. The module is designed to automate SSH key management (creation, storage, retrieval, and validation) for multiple instances, ensuring a scalable and secure approach to managing SSH access within the FountainAI ecosystem.

---

### **Introduction**:

Managing SSH keys securely is critical for modern infrastructure setups, especially in distributed cloud environments like AWS Lightsail, where multiple services (e.g., **proxy-apps**, **gateway**, **OpenSearch**) need secure communication. This module, part of the FountainAI norm, ensures that SSH keys are generated, stored, and retrieved in a consistent, secure, and reusable way across multiple instances.

The key management module factors out SSH key handling into a dedicated unit that can be used across different FountainAI deployment scripts. It guarantees:
- Secure key creation using strong encryption.
- Private key storage in **GitHub Secrets**.
- Public key storage and retrieval using **AWS Secrets Manager**.
- Consistent and verifiable key management across multiple Lightsail instances.

---

### **Problem Statement**:

Traditional SSH key management involves manually generating, storing, and distributing keys, which is prone to human error and potential security vulnerabilities. Mismanagement of keys can lead to unauthorized access or data breaches.

The FountainAI platform requires a standardized, automated, and secure method to manage SSH key pairs, especially as we scale services across multiple Lightsail instances. Therefore, the following objectives are set:
1. **Securely generate SSH key pairs** for each instance.
2. **Store SSH private keys** in **GitHub Secrets** for safe retrieval.
3. **Store SSH public keys** in **AWS Secrets Manager** for easy deployment across instances.
4. **Automate the retrieval and verification** of these keys during instance creation.

---

### **Solution Overview**:

The **FountainAI SSH Key Management Module** solves this problem by implementing functions that manage SSH key pairs securely. The module supports:
1. **SSH Key Generation**: Automatically creates SSH key pairs if they don't exist for a given instance.
2. **Private Key Storage**: Ensures private keys are uploaded to **GitHub Secrets** to be retrieved later.
3. **Public Key Storage**: Stores public keys in **AWS Secrets Manager**.
4. **Key Retrieval**: Retrieves and verifies both private and public keys from their respective secure storage locations.
5. **Modularity**: This module can be reused across multiple instances and deployment scripts, ensuring consistency and security.

---

### **System Requirements**:

The module is designed to run in environments that meet the following requirements:
- **GitHub CLI (gh)**: For interacting with **GitHub Secrets**.
- **AWS CLI**: For interacting with **AWS Secrets Manager**.
- **Bash**: A UNIX-based shell environment.

The module assumes the existence of **AWS Lightsail instances** and a **GitHub repository** where secrets are securely managed.

---

### **Module Architecture**:

The following is the complete **`fountainai_key_manager.sh`** script used for secure SSH key management:

```bash
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
```

---

### **Module Overview**:

The module consists of several key functions to handle SSH key creation, storage, and retrieval:

#### 1. **create_ssh_key_pair**:
Generates an SSH key pair using RSA 4096-bit encryption, only if the key pair does not already exist.

#### 2. **store_private_key_in_github**:
Uploads the private SSH key to **GitHub Secrets**, making it securely available for retrieval.

#### 3. **store_public_key_in_aws**:
Stores the public SSH key in **AWS Secrets Manager** for future retrieval by instances during setup.

#### 4. **retrieve_private_key**:
Retrieves the private SSH key from **GitHub Secrets** and stores it locally for establishing secure communication.

#### 5. **retrieve_public_key**:
Retrieves the public SSH key from **AWS Secrets Manager** and stores it locally.

#### 6. **manage_ssh_keys**:
Combines the above steps to automate SSH key management for an individual instance.

---

### **Usage Example**:

To use this module, source it in your deployment script and call the `manage_ssh_keys` function for each instance that requires key management:

```bash
#!/bin/bash

source ./fountainai_key_manager.sh

GITHUB_REPO="your-github-repo"
INSTANCE_NAME="proxy-apps-instance"

# Manage SSH keys for the instance
manage_ssh_keys "$GITHUB_REPO" "$INSTANCE

_NAME"
```

---

### **Conclusion**:

This **FountainAI SSH Key Management Module** provides a reusable, scalable, and secure method for managing SSH key pairs across multiple Lightsail instances. By centralizing key management into one module, FountainAI ensures that best practices are followed and that all keys are consistently and securely stored and retrieved, reducing the risk of misconfiguration and unauthorized access.

This paper outlines the structure and functions of the module, providing a foundation for future secure deployments within the FountainAI ecosystem.

---

### **Future Work**:

Future enhancements may include:
- Adding support for **automated key rotation** and **expiration policies**, ensuring that SSH keys are regularly refreshed to further improve security. 

   This enhancement would involve automating the process of generating, storing, and replacing SSH keys at regular intervals. By integrating key rotation into the existing module, we could ensure that no key is kept in use indefinitely, which would minimize the risk of compromised credentials. Moreover, **expiration policies** could enforce time-bound validity for each key, requiring a seamless replacement before the key expires. This future feature would help maintain operational continuity while adhering to stringent security standards. The module would continue to handle the secure storage and retrieval of the new keys from **GitHub Secrets** and **AWS Secrets Manager**, while also removing expired keys to reduce exposure.

