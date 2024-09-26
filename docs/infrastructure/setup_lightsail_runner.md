Let’s write the documentation for the changes made to the repository. This documentation will describe the purpose of the **`setup_github_secrets.sh`** script and the **Lightsail Runner setup workflow**, as well as how to use them in compliance with the **FountainAI Norms**.

### Documentation for `setup_github_secrets.sh` and Lightsail Runner Setup

#### Purpose:
The purpose of the **`setup_github_secrets.sh`** script is to automate the creation of the required **GitHub Secrets** that are used in the **Lightsail Runner setup** workflow. The workflow sets up an AWS Lightsail instance, registers it as a GitHub Actions runner, and ensures all necessary environment variables are securely stored as GitHub Secrets. This follows the **FountainAI manual-first approach**, which emphasizes deliberate, secure, and traceable infrastructure management.

#### Location:
- The `setup_github_secrets.sh` script can be found in `scripts/infrastructure/`.
- The corresponding GitHub Actions workflow (`setup_lightsail_runner.yml`) is located in `.github/workflows/`.

---

### 1. **GitHub Secrets Setup Script**

**File**: `setup_github_secrets.sh`  
**Location**: `scripts/infrastructure/`

#### Description:
The **`setup_github_secrets.sh`** script is responsible for creating the following required GitHub Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AVAILABILITY_ZONE`
- `BLUEPRINT_ID`
- `BUNDLE_ID`

These secrets are essential for configuring the AWS CLI and creating a Lightsail instance during the GitHub Actions workflow.

#### Required Inputs:
- **AWS Credentials** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`): Necessary to authenticate with AWS and manage Lightsail resources.
- **AWS Region** (`AWS_REGION`): Defines the region in which to create the Lightsail instance (e.g., `eu-central-1`).
- **Availability Zone** (`AVAILABILITY_ZONE`): Further narrows the location within the region (e.g., `eu-central-1a`).
- **Blueprint ID** (`BLUEPRINT_ID`): Specifies the operating system for the instance (e.g., `ubuntu_20_04`).
- **Bundle ID** (`BUNDLE_ID`): Defines the instance size (e.g., `nano_2_0`).

#### How to Run:
1. Ensure you have the **GitHub CLI (`gh`)** installed and authenticated.
2. Run the following command to execute the script and set the secrets:
   ```bash
   ./scripts/infrastructure/setup_github_secrets.sh
   ```

The script will prompt for the required input if not already provided in your environment.

---

### 2. **Lightsail Runner Setup Workflow**

**File**: `setup_lightsail_runner.yml`  
**Location**: `.github/workflows/`

#### Description:
The **Lightsail Runner Setup** workflow is a GitHub Actions workflow designed to automate the setup of a **GitHub Actions runner** on AWS Lightsail. It consists of the following steps:
1. **Run the GitHub Secrets Setup Script**: Ensures all required GitHub Secrets (like AWS credentials) are securely created.
2. **Configure AWS CLI**: Uses the secrets to authenticate with AWS.
3. **Run the Lightsail Runner Setup Script**: Creates a Lightsail instance and registers it as a GitHub Actions runner.

#### How to Trigger:
1. Navigate to the **Actions** tab in your GitHub repository.
2. Select **"Setup Lightsail Runner"** workflow.
3. Click **"Run workflow"** to manually trigger the setup.

---

### 3. **Lightsail Runner Setup Script**

**File**: `setup_lightsail_runner.sh`  
**Location**: `scripts/infrastructure/`

#### Description:
This script is responsible for creating and configuring the **AWS Lightsail instance** for the GitHub Actions runner. It ensures that the instance is created in the specified AWS region and availability zone with the correct operating system and instance size. The script also registers the instance as a **GitHub Actions runner** for the specified repository.

#### Required Environment Variables (Set as GitHub Secrets):
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AVAILABILITY_ZONE`
- `BLUEPRINT_ID`
- `BUNDLE_ID`
- `GITHUB_REPO`: The repository where the runner will be registered.

#### How to Run:
The script is automatically executed by the GitHub Actions workflow, but it can also be run manually by executing:
```bash
./scripts/infrastructure/setup_lightsail_runner.sh
```

---

### Compliance with FountainAI Norms:
- **Manual-first approach**: The setup is triggered manually via GitHub Actions, ensuring full control over the infrastructure setup process.
- **Modularity**: The script and workflow are self-contained and can be easily reused or modified.
- **Traceability**: All actions are logged through GitHub Actions and the secure management of GitHub Secrets, ensuring transparency and control.

### Next Steps:
- Ensure the documentation is kept up to date as you modify or extend the scripts and workflows.
- Test the workflow by running it manually and verifying the correct setup of the Lightsail instance and GitHub runner.

---

This documentation should be added to the `docs/infrastructure/setup_lightsail_runner.md` file.


