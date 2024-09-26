# A Manual-First Approach to Infrastructure Configuration Management with AWS Lightsail, Kong, Docker, and OpenSearch

## Abstract

This paper outlines a practical, **full human control, manual-first approach** to managing infrastructure configurations for a modular system architecture using **AWS Lightsail**. The focus is on the structured repository norm, utilizing **manual triggers** via **GitHub Actions**, **idempotent shell scripts** as defined by the **FountainAI way**, and strict **configuration management**. Each component, including **Kong (DB-less)**, **Docker-based services**, **OpenSearch**, and **modular SSH Key Management**, is controlled and documented through **shell scripts** stored in a well-defined repository structure. The system emphasizes reliability, traceability, and avoiding accidental overwrites, ensuring that every change is intentional and documented.

---

## 1. Introduction

In a world that prioritizes automation, this paper presents a counter-approach based on **manual-first control** over infrastructure management. The foundation of this approach is the **FountainAI method** of shell scripting, which emphasizes:

1. **Manual control over automation**: Prevent unintended changes by relying on manual triggers.
2. **Idempotent, modular shell scripts**: Each script is reusable and ensures consistent results, regardless of how many times it’s run, as per **FountainAI’s norms**.
3. **Comprehensive repository structure and documentation**: Strict organization of scripts, configuration files, and documentation ensures clarity and traceability for every action taken.

This approach eliminates the risks associated with over-automation, such as accidental overwrites or undocumented changes, while ensuring that every configuration change is fully controlled and deliberate.

---

## 2. Repository Norm: Structure and Purpose

The **repository norm** establishes a strict structure for organizing scripts, configurations, and documentation. This norm provides a disciplined approach to managing infrastructure, ensuring that each component remains modular and well-documented.

### 2.1. Repository Layout

```
/
├── .github/
│   └── workflows/
│       ├── configure_docker.yml        # GitHub Action for Docker
│       ├── configure_kong.yml          # GitHub Action for Kong
│       └── configure_opensearch.yml    # GitHub Action for OpenSearch
├── configs/
│   ├── docker/
│   │   └── docker-compose.yml          # Docker Compose configuration
│   ├── kong/
│   │   └── kong.yml                    # Kong DB-less configuration
│   └── opensearch/
│       └── opensearch.yml              # OpenSearch configuration
├── docs/
│   ├── modules/
│   │   └── fountainai_key_manager.md   # Documentation for SSH Key Management module
│   ├── docker_services.md              # Docker services documentation
│   ├── kong_configuration.md           # Kong configuration documentation
│   └── opensearch_configuration.md     # OpenSearch documentation
├── scripts/
│   ├── modules/
│   │   └── fountainai_key_manager.sh   # SSH Key Management module
│   ├── configure_docker.sh             # Shell script for Docker services
│   ├── configure_kong.sh               # Shell script for Kong configuration
│   └── configure_opensearch.sh         # Shell script for OpenSearch
└── README.md                           # High-level project documentation
```

### 2.2. Structure Rationale

As enforced by **FountainAI**, this layout ensures that each component is self-contained, organized according to function, and follows strict norms regarding modularity, documentation, and idempotency.

1. **Scripts** (`scripts/`): Shell scripts are organized by service (Kong, OpenSearch, Docker) and follow **FountainAI’s scripting principles**. Each script must meet the following **Script Module Norms**:
   - **Modularity**: Every script or module handles a specific task. For example, the `fountainai_key_manager.sh` script manages SSH keys. Modules such as these are self-contained and reusable across different parts of the infrastructure.
   - **Idempotency**: Scripts are designed to be run multiple times without unintended side effects, ensuring the same results regardless of execution frequency.
   - **Documentation**: Each script and module is accompanied by comprehensive documentation (stored in the `docs/` folder), explaining its purpose, parameters, and usage to ensure clarity and maintainability.
   
   This modular approach reduces complexity and ensures clear separation of concerns, making it easier to scale and maintain over time.

2. **Configurations** (`configs/`): Configuration files for Kong, OpenSearch, and Docker are kept in distinct subdirectories, allowing for easy access and version control. These configurations define the specific settings required for each service and are versioned to maintain traceability of changes.

3. **Workflows** (`.github/workflows/`): Workflows are linked to the shell scripts via **manual triggers**, ensuring that configurations are only applied when deliberately invoked. This allows for deterministic and controlled execution of the infrastructure setup processes.

4. **Documentation** (`docs/`): Each service has dedicated documentation that explains how the shell scripts and configurations work together, following the **FountainAI way** of comprehensive documentation. This includes instructions for setting up and managing services and modules, ensuring full traceability of actions taken within the infrastructure.

---

## 3. Manual-First Infrastructure Management

The **manual-first approach** ensures that nothing happens automatically. This strict control is essential to prevent unintentional changes, and it aligns with **FountainAI’s principle** of **deterministic execution**—where every action is controlled, predictable, and repeatable.

---

## 4. Idempotent Shell Scripts: The FountainAI Way

### 4.1. Defining the **FountainAI Shell Scripting Norms**

The **FountainAI Shell Scripting Norm** consists of several principles that ensure infrastructure management scripts are reusable, modular, reliable, and easy to maintain. These principles are outlined as follows:

- **Modularity**: Each script should perform a single task and be reusable across different environments and systems. This helps reduce complexity and enables easier debugging and updates.
- **Idempotency**: The script must guarantee the same result whether it is run once or multiple times. This ensures that the system remains stable and does not reapply changes unnecessarily.
- **Documentation**: Every script must include clear, concise documentation explaining its purpose, parameters, and usage. This ensures that other team members can understand and modify the script if necessary.

### 4.2. **Exemplifying the Norm**: Modifying a Deployed Kong Instance in DB-less Mode

In this example, we demonstrate how to **alter the state** of a **deployed instance of Kong** running in **DB-less mode**. Unlike traditional database-backed systems, Kong in DB-less mode relies on a **configuration file** (`kong.yml`) to define its services, routes, and plugins. By modifying this file, you can change Kong's behavior dynamically, without needing database migrations or direct interaction with a backend database.

Here’s an example shell script that modifies **Kong Gateway** by adding a service and route to an existing instance:

```bash
#!/bin/bash

# FountainAI Norm: This script alters the state of a deployed Kong Gateway instance in DB-less mode.

# Define configuration file location
config_file="/etc/kong/kong.yml"

# Function to create or modify Kong configuration if it doesn't exist
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
        # You could add logic here to modify the existing config if needed.
    fi
}

# Execute the function to ensure idempotency
create_kong_config
```

#### **Modularity**:
This script focuses on **altering the state** of an existing **Kong Gateway** instance by modifying its configuration. It does not handle initial deployments or other services, ensuring that it can be reused or modified without affecting unrelated components.

#### **Idempotency**:
The script checks whether the configuration file (`kong.yml`) already exists. If the file exists, no changes are made unless explicitly programmed. This ensures that the script can be run multiple times without causing unintended modifications or disruptions. If the configuration doesn't exist, it creates a new one, making the process safe to reapply.

#### **Framing the Operation**:
This example is not about "setting up" Kong from scratch, but rather about **modifying its active configuration** to reflect new routes or services. The script demonstrates a routine process for environments where **Kong is already deployed in DB-less mode**, and system administrators or developers need to alter Kong’s behavior by updating the configuration file.

By leveraging **DB-less mode**, changes to the `kong.yml` file take effect when the configuration is reloaded, enabling seamless, database-free alterations to a running Kong instance.

#### **Documentation**:
At the top of the script, a comment clearly explains that this script modifies a deployed **Kong Gateway** in **DB-less mode**. Additional inline comments explain the location of the **config_file** and the conditional logic that prevents unwanted overwrites, ensuring that future users understand the script’s functionality.

### 4.3. Application of FountainAI Norms to Other Scripts

The principles demonstrated in the **Kong configuration** script can be applied to other infrastructure components such as **OpenSearch** and **Docker services**. Each script should be:

- **Modular**: Performing only one clear task, such as configuring a Docker service or setting up OpenSearch indices.
- **Idempotent**: Checking for existing configurations or states before applying changes, ensuring that re-running the script does not create unintended effects.
- **Well-documented**: Including clear descriptions, comments, and usage instructions for future maintainers.

---

## 5. Conclusion: Full Human Control - Enforcing the FountainAI Way

This manual-first infrastructure setup enforces the **FountainAI Shell Scripting Norms**, which prioritize modularity, idempotency, and clear documentation. By focusing on manual control and deterministic execution, the system avoids the pitfalls of over-automation, ensuring that configurations are reliable, documented, and under full human control.

