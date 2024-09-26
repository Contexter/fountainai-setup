# FountainAI Setup - Manual-First Approach to Infrastructure Configuration

## Abstract

This repository outlines a **manual-first, human-controlled approach** to infrastructure configuration for a modular system architecture using **AWS Lightsail**, **GitHub Actions**, and **FountainAI norms**. The key principles focus on **manual triggers**, **idempotent shell scripts**, and **strict configuration management**, ensuring reliability, traceability, and control. Services like **Kong (DB-less)**, **Docker-based services**, **OpenSearch**, and infrastructure components are configured via scripts stored in a well-organized repository structure. This approach avoids over-automation and prevents accidental overwrites, making sure every change is intentional and well-documented.

---

## Design Philosophy: Manual-First and Human Control

At the heart of this repository is the **FountainAI Norm**, which emphasizes **full human control** over automation. The manual-first approach is about:
- **Manual control over automation**: Automation is powerful, but accidental changes or misconfigurations can be dangerous. This approach ensures that nothing happens automatically. All workflows, configurations, and changes are triggered manually, giving you full control over when and how actions are taken.
- **Idempotent, modular shell scripts**: Scripts are designed to be reusable and produce consistent results regardless of how many times they are run. This avoids unintentional changes and guarantees stability.
- **Comprehensive repository structure**: The repository is structured to ensure clarity and traceability. Every action and configuration is documented, ensuring that the infrastructure is always in a known state, with full visibility into what has been done and why.

This approach ensures that **every action is deliberate**, following the guiding principle of **deterministic execution**—meaning that every script or workflow does exactly what it’s supposed to do, and nothing happens unexpectedly.

---

## Repository Structure

The repository is organized to clearly separate concerns, ensuring that scripts, configurations, workflows, and documentation are modular, reusable, and easy to maintain.

### Layout:
- **`.github/workflows/`**: Contains GitHub Actions workflows. These are manually triggered workflows that enforce human control over the infrastructure setup:
  - `configure_docker.yml`: Workflow for Docker service setup.
  - `configure_kong.yml`: Workflow for Kong DB-less setup.
  - `configure_opensearch.yml`: Workflow for OpenSearch setup.
  - `setup_lightsail_runner.yml`: Workflow for setting up the GitHub Actions runner on AWS Lightsail.
  
- **`configs/`**: Holds configuration files for various services:
  - **`docker/`**: Configuration for Docker-based services using Docker Compose.
  - **`kong/`**: Configuration for Kong in DB-less mode.
  - **`opensearch/`**: Configuration for OpenSearch services.

- **`docs/`**: Comprehensive documentation for infrastructure scripts, services, and configuration setups:
  - **`infrastructure/`**: Documentation for infrastructure management scripts, such as `setup_lightsail_runner.md`.
  - **`docker_services.md`**: Documentation for Docker services setup.
  - **`kong_configuration.md`**: Documentation for Kong configuration.
  - **`modules/`**: Contains documentation for reusable modules like `fountainai_key_manager.md`.
  - **`opensearch_configuration.md`**: Documentation for OpenSearch configuration.

- **`scripts/`**: Shell scripts for service and infrastructure setup:
  - **`infrastructure/`**: Infrastructure management scripts:
    - `setup_github_secrets.sh`: Automates the creation of GitHub Secrets required for AWS Lightsail and GitHub Actions runner setup.
    - `setup_lightsail_runner.sh`: Creates and configures an AWS Lightsail instance as a GitHub Actions runner.
  - **`modules/`**: Reusable modules for common tasks like SSH key management.
    - `fountainai_key_manager.sh`: Script to manage SSH keys in a modular, reusable way.

---

## Manual-First Infrastructure Management

### GitHub Secrets Setup

The `setup_github_secrets.sh` script, located in `scripts/infrastructure/`, automates the creation of **GitHub Secrets** required for AWS Lightsail and GitHub Actions workflows. This follows the **FountainAI Norm** of ensuring secure, manual control over credentials and infrastructure management.

**How to Run**:
1. Make sure you have the **GitHub CLI (`gh`)** installed and authenticated.
2. Run the script to set the necessary secrets:
   ```
   ./scripts/infrastructure/setup_github_secrets.sh
   ```

This script ensures that secrets like `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and others are securely stored and available for the GitHub Actions workflows.

---

### Lightsail Runner Setup

The **Lightsail Runner Setup** process involves creating an AWS Lightsail instance and configuring it as a GitHub Actions runner. This is managed by the `setup_lightsail_runner.sh` script, located in `scripts/infrastructure/`.

#### How It Works:
1. The **GitHub Actions workflow** (`setup_lightsail_runner.yml`) is triggered manually to control when the runner is set up.
2. The workflow first ensures that all required secrets are set via the **GitHub Secrets Setup Script**.
3. It then configures the AWS CLI and runs the **Lightsail Runner Setup Script** to create a Lightsail instance and register it as a GitHub Actions runner.

**How to Run the Workflow**:
1. Go to the **Actions** tab in your GitHub repository.
2. Select the **"Setup Lightsail Runner"** workflow.
3. Click **"Run workflow"** to manually trigger the process.

---

## Services Configuration

### Docker Services Setup

The `docker_services.md` provides details on how to configure Docker-based services. The `docker-compose.yml` file in `configs/docker/` defines the services and can be used to spin up containers for the project.

### Kong Configuration

The `kong_configuration.md` explains how to configure **Kong Gateway** in DB-less mode. The Kong configuration file (`kong.yml`) can be found in `configs/kong/`, and the setup is handled via the `configure_kong.sh` script.

### OpenSearch Configuration

The `opensearch_configuration.md` provides instructions for setting up OpenSearch services. The configuration file is located in `configs/opensearch/`, and the setup script (`configure_opensearch.sh`) is in the `scripts/` directory.

---

## Compliance with FountainAI Norms

The FountainAI Norm emphasizes:
- **Manual-first control**: Every action must be manually triggered, ensuring that nothing happens automatically or unexpectedly.
- **Modularity**: Scripts and configurations are designed to be modular and self-contained, enabling easy maintenance and reuse.
- **Idempotency**: Scripts produce consistent results even if run multiple times, ensuring stability and avoiding redundant changes.
- **Documentation**: Each component and action is fully documented, ensuring transparency and enabling collaboration without confusion.

The repository adheres to these norms to ensure that infrastructure and service configurations are secure, reliable, and under full human control.

