# CPM Setup Guide

Complete guide for setting up CPM in your project.

**Note:** This guide uses Make as the task runner, but CPM works with any automation tool (npm, Gradle, Maven, custom scripts, etc.). The principles remain the same - just adapt the task runner to your project's needs.

---

## Prerequisites

None! The `make configure` command will automatically install:
- asdf v0.15.0 (if not already installed)
- Python 3.12.9 (via asdf)
- Caylent repo tool (latest version)

---

## Step 1: Create Your Project

```bash
mkdir my-project
cd my-project
git init --initial-branch=main
```

---

## Step 2: Copy CPM Files

Copy the example files from the CPM repository:

```bash
git checkout https://github.com/caylent-solutions/cpm.git example/Makefile
git checkout https://github.com/caylent-solutions/cpm.git example/.cpmenv
```

---

## Step 3: Configure the Manifest

Edit `.cpmenv` to point to your desired manifest. All configuration is in this file - you never need to edit the Makefile.

### Available Manifests

**Terraform Modules (for terraform-modules monorepo subdirectories):**
```bash
REPO_MANIFESTS_PATH = manifests/terraform/caylent-terraform-modules-monorepo/modules/meta.xml
```

**Future manifests:**
- Python: `manifests/python/meta.xml` (coming soon)
- .NET: `manifests/dotnet/meta.xml` (coming soon)
- Java: `manifests/java/meta.xml` (coming soon)
- CDK: `manifests/cdk/meta.xml` (coming soon)

### Example: Terraform Module

Your `.cpmenv` should look like:

```bash
# CPM Configuration
# All variables are set here. Modify as needed for your project.

REPO_MANIFESTS_URL = https://github.com/caylent-solutions/cpm.git
REPO_MANIFESTS_REVISION = refs/tags/0.1.3
REPO_MANIFESTS_PATH = manifests/terraform/caylent-terraform-modules-monorepo/modules/meta.xml

REPO_URL = https://github.com/caylent-solutions/git-repo.git
REPO_REV = caylent-1.0.0

GITBASE = https://github.com/caylent-solutions/

IS_PIPELINE = false
JOB_NAME = job
JOB_EMAIL = job@job.job

ASDF_URL = https://github.com/asdf-vm/asdf.git
ASDF_VERSION = v0.15.0
ASDF_DIR = $(HOME)/.asdf
TOOL_VERSIONS_FILE = .tool-versions
DEFAULT_PYTHON_VERSION = 3.12.9

PACKAGES_DIR = packages
MODULE_DIR = packages/modules
```

---

## Step 4: Verify Configuration

Review `.cpmenv` to ensure all settings are correct for your project. The file contains all CPM configuration - no need to edit the Makefile.

---

## Step 5: Run Configure

Initialize and sync CPM packages:

```bash
make configure
```

This will:
1. Install asdf v0.15.0 (if not already installed)
2. Create `.tool-versions` file with Python 3.12.9 (if not exists)
3. Install all tools from `.tool-versions` via asdf
4. Install the latest Caylent repo tool
5. Initialize the repo tool with your chosen manifest
6. Clone package repositories to `packages/`
7. Create symlinks for shared tooling
8. Make all package targets available

---

## Step 6: Verify Setup

Check that packages were synced:

```bash
ls -la packages/
# Should show: Makefile@ -> modules/linkfiles/Makefile
# Should show: modules/ directory
```

Test a make target:

```bash
make help
# Should show available targets from the package
```

---

## Step 7: Use CPM Targets

Run `make help` to see all available targets from your chosen manifest:

```bash
make help
```

Each manifest provides different automation tasks specific to its purpose. For example, the Terraform modules manifest provides targets like `test`, `tf-lint`, `tf-format`, and `tf-docs`.

---

## Troubleshooting

### "packages/Makefile: No such file or directory"

**Cause:** CPM packages not synced yet.

**Solution:**
```bash
make configure
```

### "Error: Failed to install repo tool"

**Cause:** Network issue or GitHub API rate limit.

**Solution:**
- Check internet connection
- Wait a few minutes and retry
- Check GitHub API rate limits

### Make targets not working

**Cause:** Symlink broken or packages not synced.

**Solution:**
```bash
make clean
make configure
```

---

## Updating CPM Packages

To update to a newer version:

1. Update the revision in `.cpmenv`:
   ```bash
   REPO_MANIFESTS_REVISION = refs/tags/1.1.0
   ```

2. Re-sync:
   ```bash
   make configure
   ```

---

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Configure CPM
        run: make configure
        env:
          GITBASE: https://github.com/caylent-solutions/

      - name: Run tests
        run: |
          . ~/.asdf/asdf.sh
          make test
        env:
          IS_PIPELINE: true
```
