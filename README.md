# A Manual-First Approach to Infrastructure Configuration Management with AWS Lightsail, Kong, Docker, and OpenSearch

## Abstract

This paper outlines a practical, **manual-first approach** to managing infrastructure configurations for a modular system architecture using **AWS Lightsail**. The focus is on the structured repository norm, utilizing **manual triggers** via **GitHub Actions**, **idempotent shell scripts** as defined by the **FountainAI way**, and strict **configuration management**. Each component, including **Kong (DB-less)**, **Docker-based services**, and **OpenSearch**, is controlled and documented through **shell scripts** stored in a well-defined repository structure. The system emphasizes reliability, traceability, and avoiding accidental overwrites, ensuring that every change is intentional and documented.

---

## 1. Introduction

In a world that prioritizes automation, this paper presents a counter-approach based on **manual-first control** over infrastructure management. The foundation of this approach is the **FountainAI method** of shell scripting, which emphasizes:

1. **Manual control over automation**: Prevent unintended changes by relying on manual triggers.
2. **Idempotent, modular shell scripts**: Each script is reusable and ensures consistent results, regardless of how many times it's run, as per **FountainAI’s norms**.
3. **Comprehensive repository structure and documentation**: Strict organization of scripts, configuration files, and documentation ensures clarity and traceability for every action taken.

This approach eliminates the risks associated with over-automation, such as accidental overwrites or undocumented changes, while ensuring that every configuration change is fully controlled and deliberate.

---

## 2. Repository Norm: Structure and Purpose

The **repository norm**, inspired by **Chapter 7 of the FountainAI Book**, establishes a strict structure for organizing scripts, configurations, and documentation. This norm provides a disciplined approach to managing infrastructure, ensuring that each component remains modular and well-documented.

### 2.1. Repository Layout

```
/
├── .github/
│   └── workflows/
│       └── configure_kong.yml        # GitHub Action for Kong
│       └── configure_opensearch.yml  # GitHub Action for OpenSearch
│       └── configure_docker.yml      # GitHub Action for Docker
├── scripts/
│   └── configure_kong.sh             # Shell script for Kong configuration
│   └── configure_opensearch.sh       # Shell script for OpenSearch
│   └── configure_docker.sh           # Shell script for Docker services
├── configs/
│   └── kong/
│       └── kong.yml                  # Kong DB-less configuration
│   └── opensearch/
│       └── opensearch.yml            # OpenSearch configuration
│   └── docker/
│       └── docker-compose.yml        # Docker Compose configuration
├── docs/
│   └── kong_configuration.md         # Kong configuration documentation
│   └── opensearch_configuration.md   # OpenSearch documentation
│   └── docker_services.md            # Docker services documentation
└── README.md                         # High-level project documentation
```

### 2.2. Structure Rationale

As enforced by **FountainAI**, this layout ensures that each component is self-contained and organized according to function:

1. **Scripts** (`scripts/`): Shell scripts are organized by service (Kong, OpenSearch, Docker) and follow **FountainAI’s scripting principles**: each script is modular, well-documented, and idempotent. Each script serves a specific purpose, reducing complexity and ensuring clear separation of concerns.
2. **Configurations** (`configs/`): Configuration files for Kong, OpenSearch, and Docker are kept in distinct subdirectories, allowing for easy access and version control.
3. **Workflows** (`.github/workflows/`): Workflows are linked to the shell scripts via **manual triggers**, ensuring that configurations are only applied when deliberately invoked.
4. **Documentation** (`docs/`): Each service has dedicated documentation that explains how the shell scripts and configurations work together, following the **FountainAI** way of full documentation and clarity.

---

## 3. Manual-First Infrastructure Management

The **manual-first approach** ensures that nothing happens automatically. This strict control is essential to prevent unintentional changes, and it aligns with FountainAI’s principle of **deterministic execution**—where every action is controlled, predictable, and repeatable.

---

## 4. Idempotent Shell Scripts: The FountainAI Way

### 4.1. Defining the **FountainAI Shell Scripting Norms**

The **FountainAI Shell Scripting Norm** consists of several principles that ensure infrastructure management scripts are reusable, modular, reliable, and easy to maintain. These principles are outlined as follows:

- **Modularity**: Each script should perform a single task and be reusable across different environments and systems. This helps reduce complexity and enables easier debugging and updates.
- **Idempotency**: The script must guarantee the same result whether it is run once or multiple times. This ensures that the system remains stable and does not reapply changes unnecessarily.
- **Documentation**: Every script must include clear, concise documentation explaining its purpose, parameters, and usage. This ensures that other team members can understand and modify the script if necessary.

### 4.2. **Exemplifying the Norm**: A Kong Configuration Shell Script

Here is an example shell script for **Kong Gateway DB-less mode**, demonstrating the **FountainAI Shell Scripting Norms**.

```bash
#!/bin/bash

# FountainAI Norm: This script configures Kong Gateway in DB-less mode.

# Define configuration file location
config_file="/etc/kong/kong.yml"

# Function to create Kong configuration only if it doesn't exist
create_kong_config() {
    if [ ! -f "$config_file" ]; then
        echo "Creating Kong configuration."
        cat <<EOL > "$config_file"
_format_version: "3.0"
services:
  - name: api_service
    url: http://backend-service
    routes:
      - name: api_route
        paths:
          - /api
EOL
    else
        echo "Kong configuration already exists at $config_file."
    fi
}

# Execute the function to ensure idempotency
create_kong_config
```

#### **Modularity**:
This script only focuses on configuring **Kong Gateway**. It does not attempt to handle other services or configurations, ensuring that it can be reused or modified without impacting other infrastructure components.

#### **Idempotency**:
The script checks if the configuration file (`kong.yml`) already exists. If it does, the script simply exits, ensuring that re-running the script does not overwrite or change existing configurations unnecessarily. This guarantees that the system remains stable and prevents unintended changes.

#### **Documentation**:
At the top of the script, a comment clearly explains its purpose: configuring Kong Gateway in **DB-less mode**. The script also includes inline comments explaining the **config_file** location and why the configuration is applied conditionally, ensuring that future users of the script understand its functionality.

### 4.3. Application of FountainAI Norms to Other Scripts

The principles demonstrated in the **Kong configuration** script can be applied to other infrastructure components such as **OpenSearch** and **Docker services**. Each script should be:

- **Modular**: Performing only one clear task, such as configuring a Docker service or setting up OpenSearch indices.
- **Idempotent**: Checking for existing configurations or states before applying changes, ensuring that re-running the script does not create unintended effects.
- **Well-documented**: Including clear descriptions, comments, and usage instructions for future maintainers.

---

## 5. Decoupling the Installation Script from the Paper

For clarity and ease of use, the installation script `setup_repository.sh` which creates the repository described in this paper has been **decoupled** from the format of this paper. The installation process can be completed by downloading and running the script manually.

### 5.1. Download and Install the Repository Setup Script

The script can be downloaded and executed manually using the following commands:

```
curl -O https://raw.githubusercontent.com/Contexter/FountainAI-Book/main/scripts/setup_repository.sh
chmod +x setup_repository.sh
./setup_repository.sh
```

This script will handle the following automatically:
- **Delete the existing repository** (if it exists).
- **Create a new repository under the GitHub account** of the authenticated user (using `gh`).
- **Clone the repository** into the current working directory.
- **Set up the directory structure, workflows, and configuration files**.
- **Commit and push** all changes.

The repository will be **automatically created under the authenticated GitHub user’s account**. The script does not need any manual intervention regarding GitHub account selection.

### 5.2. Ensuring Proper User Setup

Users must authenticate with GitHub CLI (`gh`) to run the script. **The script will create the repository under the GitHub account of the authenticated user**. Here's how to ensure proper setup:

1. **Install GitHub CLI (`gh`)**:
   - If `gh` is not already installed, follow the official instructions [here](https://cli.github.com/manual/).
   
   Example for Ubuntu:
   ```bash
   sudo apt install gh
   ```

2. **Log in to GitHub using the CLI**:
   ```bash
   gh auth login
   ```

   Select the default options to authenticate via your web browser. Log in using your GitHub credentials.

3. **Verify your authentication status**:
   ```bash
   gh auth status
   ```

   This command will confirm if you are authenticated and logged in as the correct GitHub user.

### Important: Repository Creation Under the Authenticated User’s Account

Once the user is authenticated with GitHub CLI, the script will **automatically create the repository under the GitHub account of the authenticated user**. This means that whichever user is logged in with `gh auth login` will have the repository created in their GitHub account. No further input is required.

Once you have completed these steps and authenticated with GitHub CLI, you can run the setup script by executing:

```
./setup_repository.sh
```

This ensures that **only authenticated users** can create and configure the repository.

---

## 6. Conclusion: Enforcing the FountainAI Way

This manual-first infrastructure setup enforces the **FountainAI Shell Scripting Norms**, which prioritize modularity, idempotency, and clear documentation. By focusing on manual control and deterministic execution, the system avoids the pitfalls of over-automation, ensuring that configurations are reliable, documented, and under full human control.

---

## Appendix: Security Considerations

### 1. GitHub CLI Authentication and Authorization

The setup process relies on the **GitHub CLI (`gh`)** to ensure that only authorized users can create and manage the repository. The script includes security checks that:

1. **Verify if the user is authenticated** using `gh auth status`.
2. **Ensure that the repository is created under the GitHub account of the authenticated user**.

If any unauthorized user attempts to run the script, it will exit with an error, ensuring that only authenticated users can proceed.

### 2. Infrastructure Security

Beyond authentication, the following general **infrastructure security principles** should be enforced in line with FountainAI's norms:

#### A. Role-Based Access Control (RBAC)

Access to different components of the infrastructure should be restricted using **RBAC policies**. For example:
- **Kong Gateway** should restrict access to specific services using roles and access control lists (ACLs).
- **OpenSearch** should enforce **authentication** (e.g., via HTTPS and API keys) and **authorization** (restricting data access based on user roles).

#### B. Configuration Encryption and Sensitive Data

Sensitive data such as API keys, service credentials, and configuration files (like `.env`) must be securely stored and encrypted. Scripts must be designed to avoid hard-coding sensitive data directly in the codebase. Instead, environmental variables should be used, with `.env` files encrypted and protected. Use `Github Secrets`. 

This broader approach guarantees that both access control and sensitive data handling are properly secured, alongside strict user authorization using `gh`.

