# How CPM Works

Complete walkthrough of CPM's internal process from project creation to running automation tasks.

**Note:** This guide uses Caylent's repositories as examples. You can substitute your organization's repositories throughout by updating URLs in `.cpmenv`.

---

## Overview

CPM uses a fork of the Gerrit `repo` tool to orchestrate dependency management across multiple Git repositories. You can point CPM to any Git repositories—public, private, or within your organization. This document explains every step of the process using Caylent's public repositories as examples.

---

## Step 1: User Creates Project

User creates a new project directory:

```bash
mkdir my-project
cd my-project
git init --initial-branch=main
```

**Result:**
```
my-project/
└── .git/
```

---

## Step 2: User Adds CPM Makefile

User copies the CPM example Makefile:

```bash
curl -o Makefile https://raw.githubusercontent.com/caylent-solutions/cpm/main/examples/example-make-task-runner/Makefile
curl -o .cpmenv https://raw.githubusercontent.com/caylent-solutions/cpm/main/examples/example-make-task-runner/.cpmenv
```

**Result:**
```
my-project/
├── .git/
├── Makefile
└── .cpmenv
```

**Key `.cpmenv` variables:**
- `REPO_MANIFESTS_URL` - CPM manifest repository URL
- `REPO_MANIFESTS_REVISION` - CPM version (tag or branch)
- `REPO_MANIFESTS_PATH` - Path to specific manifest
- `GITBASE` - Base URL for cloning packages
- `PACKAGES_DIR` - Directory where packages are cloned
- `REPO_URL` - Repo tool repository URL
- `REPO_REV` - Repo tool version
- `ASDF_VERSION` - asdf version to install
- And more...

**Note:** All configuration is in `.cpmenv`. The Makefile is a static template that never needs editing.

---

## Step 3: User Runs `make cpm-configure`

```bash
make cpm-configure
```

### 3.1: Makefile Execution

The Makefile loads `.cpmenv`, validates all required variables are set, then executes the `cpm-configure` target:

```makefile
.PHONY: cpm-configure
cpm-configure: cpm-install-asdf cpm-install-tools cpm-install-repo
	# repo init and sync commands
```

**Variables loaded from `.cpmenv`:**
- `REPO_MANIFESTS_URL` → `https://github.com/caylent-solutions/cpm.git`
- `REPO_MANIFESTS_REVISION` → `refs/tags/0.2.10`
- `REPO_MANIFESTS_PATH` → `repo-specs/terraform/caylent-terraform-modules-monorepo/modules/meta.xml`
- `PACKAGES_DIR` → `.packages`

**Configure steps:**
1. `cpm-install-asdf`: Install asdf v0.15.0 (if not already installed)
2. `cpm-install-tools`: Install tools from `.tool-versions` via asdf
3. `cpm-install-repo`: Install Caylent repo tool launcher via pip (version from `REPO_REV`)
4. Run `repo init` with manifest configuration and `--repo-rev` flag
5. Repo launcher clones full repo implementation into `.repo/repo/` (version from `REPO_REV`)
6. Run `repo sync` to clone packages

**Note:** The repo tool uses a two-stage architecture:
- **Launcher** (step 3): Lightweight bootstrap script installed via pip
- **Full Implementation** (step 5): Complete repo tool cloned into `.repo/repo/` by the launcher

This is the standard repo tool design - the launcher delegates to the full implementation in `.repo/repo/`. Both use the same `REPO_REV` version.

---

## Step 4: `repo init` Executes

The `repo init` command is executed with the `--repo-rev` flag:

```bash
repo init --no-repo-verify \
  -u "https://github.com/caylent-solutions/cpm.git" \
  -b "refs/tags/0.2.10" \
  -m "repo-specs/terraform/caylent-terraform-modules-monorepo/modules/meta.xml" \
  --repo-rev="caylent-1.0.0"
```

**What `--repo-rev` does:**
- Clones the repo tool itself into `.repo/repo/` at the specified version
- This is the **second installation** of the repo tool (first was via pip)
- Future `repo` commands will use this `.repo/repo/` version
- Ensures the repo tool version matches `REPO_REV` from `.cpmenv`

### 4.1: Clone CPM Manifest Repository

The repo tool clones the CPM manifest repository:

```bash
git clone https://github.com/caylent-solutions/cpm.git .repo/manifests
cd .repo/manifests
git checkout refs/tags/0.2.10
```

**Result:**
```
my-project/
├── .git/
├── .repo/
│   └── manifests/  (CPM repo cloned here - hardcoded by repo tool)
│       ├── repo-specs/
│       │   ├── git-connection/
│       │   │   └── remote.xml
│       │   └── terraform/
│       │       └── caylent-terraform-modules-monorepo/
│       │           └── modules/
│       │               ├── meta.xml
│       │               └── packages.xml
│       └── example/
├── Makefile
└── .cpmenv
```

### 4.2: Load Meta Manifest

Repo tool loads: `.repo/manifests/repo-specs/terraform/caylent-terraform-modules-monorepo/modules/meta.xml`

```xml
<manifest>
  <include name="repo-specs/git-connection/remote.xml" />
  <include name="repo-specs/terraform/caylent-terraform-modules-monorepo/modules/packages.xml" />
</manifest>
```

**Processing:**
1. Includes `repo-specs/git-connection/remote.xml` (absolute from repo root)
2. Includes `repo-specs/terraform/caylent-terraform-modules-monorepo/modules/packages.xml` (absolute from repo root)

**Note:** The path `.repo/manifests/repo-specs/` may look redundant, but it's intentional:
- `.repo/manifests/` is hardcoded by the repo tool (cannot be changed)
- `repo-specs/` is our directory name inside the CPM repository
- This naming eliminates the confusing double `manifests/manifests/` pattern

### 4.3: Load Remote Definition

Loads: `.repo/manifests/repo-specs/git-connection/remote.xml`

```xml
<manifest>
  <remote name="caylent-devops-platform" fetch="${GITBASE}"/>
</manifest>
```

**Processing:**
- Defines remote: `caylent-devops-platform`
- Fetch URL: `${GITBASE}` (environment variable)
- Value: `https://github.com/caylent-solutions/` (set in `.cpmenv`, exported by Makefile)

**Result:** Remote `caylent-devops-platform` = `https://github.com/caylent-solutions/`

### 4.4: Load Package Definitions

Loads: `.repo/manifests/repo-specs/terraform/caylent-terraform-modules-monorepo/modules/packages.xml`

```xml
<manifest>
  <project name="cpm-terraform-modules-monorepo"
           path=".packages/cpm-terraform-modules-monorepo"
           remote="caylent-devops-platform"
           revision="refs/tags/0.2.1" />
</manifest>
```

**Processing:**
- Project name: `cpm-terraform-modules-monorepo`
- Clone to: `.packages/cpm-terraform-modules-monorepo/`
- Remote: `caylent-devops-platform` → `https://github.com/caylent-solutions/`
- Full URL: `https://github.com/caylent-solutions/cpm-terraform-modules-monorepo`
- Revision: `refs/tags/0.2.1`

---

## Step 5: `repo sync` Executes

### 5.1: Clone Package Repository

```bash
git clone https://github.com/caylent-solutions/cpm-terraform-modules-monorepo .packages/cpm-terraform-modules-monorepo
cd .packages/cpm-terraform-modules-monorepo
git checkout refs/tags/0.2.1
```

**Result:**
```
my-project/
├── .git/
├── .repo/
├── .packages/
│   └── cpm-terraform-modules-monorepo/  (cloned here)
│       ├── Makefile
│       └── README.md
├── Makefile
└── .cpmenv
```

---

## Step 6: User Runs Automation Task

User runs an automation task (using Make in this example):

```bash
make test
```

**Note:** While this example uses Make, CPM's orchestration pattern is designed to support any task runner (npm, Gradle, Maven, etc.). Future examples will demonstrate these integrations using the same `.packages/` cloning pattern.

### 6.1: Root Makefile Execution

**File:** `./Makefile`

```makefile
PACKAGES_DIR = .packages
-include $(PACKAGES_DIR)/*/Makefile
```

**Processing:**
- Sets `PACKAGES_DIR = .packages`
- Glob pattern includes all Makefiles: `.packages/*/Makefile`
- Expands to: `.packages/cpm-terraform-modules-monorepo/Makefile`
- Multiple packages would all be included automatically

### 6.2: Package Makefile Execution

**File:** `.packages/cpm-terraform-modules-monorepo/Makefile`

```makefile
.PHONY: test
test:
	@echo "Cleaning Go test cache..."
	@go clean -cache -testcache
	@echo "Running tests..."
	@tftest run --parallel-fixtures=false --parallel-tests=false
```

**Processing:**
- Finds `test` target
- Executes test commands
- Working directory: `my-project/` (root)

---

## Final Directory Structure

```
my-project/
├── .git/
├── .repo/
│   ├── manifests/           # CPM manifest repo
│   ├── repo/                # Repo tool (second installation)
│   ├── manifest.xml         # Resolved manifest
│   └── ...
├── .packages/
│   └── cpm-terraform-modules-monorepo/  # Package repo
│       ├── Makefile         # Make targets
│       └── README.md
├── Makefile                 # User's root Makefile
├── .cpmenv                  # User's environment overrides
└── (user's project files)
```

---

## Make Target Resolution Flow

```
User runs: make test
    ↓
1. Root Makefile (./Makefile)
   - Sets: PACKAGES_DIR = .packages
   - Includes: .packages/*/Makefile (glob pattern)
   - Expands to: .packages/cpm-terraform-modules-monorepo/Makefile
    ↓
2. Package Makefile (.packages/cpm-terraform-modules-monorepo/Makefile)
   - Executes: test target
   - Runs: tftest, go clean, etc.
```

---

## Key Concepts

### Environment Variable Substitution

The Caylent fork of the repo tool supports environment variable substitution in manifests:

```xml
<remote name="caylent-devops-platform" fetch="${GITBASE}"/>
```

The `${GITBASE}` is replaced with the value from the environment (set in `.cpmenv`, exported by Makefile).

### Multi-Package Support

The root Makefile uses a glob pattern to include all package Makefiles:

```makefile
-include $(PACKAGES_DIR)/*/Makefile
```

This automatically includes Makefiles from all packages:
- `.packages/cpm-terraform-modules-monorepo/Makefile`
- `.packages/cpm-python-tools/Makefile`
- `.packages/cpm-go-tools/Makefile`

All targets from all packages become available without manual configuration.

**Important for Package Developers:** When creating CPM package repositories that provide Make targets, the Makefile MUST be at the root of the package repository. This is required because:
- The glob pattern `$(PACKAGES_DIR)/*/Makefile` expects Makefiles at `.packages/<package-name>/Makefile`
- Nested Makefiles (e.g., `.packages/<package-name>/tasks/Makefile`) will not be automatically included
- This keeps the architecture simple and predictable - one Makefile per package at a known location

**Shared Make Includes:** Package developers can also provide `common.mk` or other `.mk` files at the package root for shared variables and functions:

```
cpm-terraform-modules-monorepo/
├── Makefile       # Main targets (automatically included)
├── common.mk      # Shared variables/functions
└── README.md
```

The package Makefile can include these:

```makefile
# In .packages/cpm-terraform-modules-monorepo/Makefile
include $(dir $(lastword $(MAKEFILE_LIST)))common.mk

.PHONY: test
test:
	# Use variables from common.mk
```

### Dual Repo Tool Installation

The repo tool uses a two-stage architecture by design:

**First Installation (via pip) - Launcher:**
```bash
pip install "git+https://github.com/caylent-solutions/git-repo.git@caylent-1.0.0"
```
- Installs a lightweight launcher script
- Provides the initial `repo` command
- Version controlled by `REPO_REV` in `.cpmenv`

**Second Installation (via repo init) - Full Implementation:**
```bash
repo init --repo-rev="caylent-1.0.0" ...
```
- Clones the full repo tool implementation into `.repo/repo/`
- Contains all repo subcommands and logic
- Used for all subsequent `repo` operations (sync, status, etc.)
- Version controlled by `--repo-rev` flag (same as `REPO_REV`)

**How it works:**
This is the standard repo tool architecture. The launcher script (first installation) is a minimal bootstrap that delegates to the full implementation (second installation) in `.repo/repo/`. This allows:
- Different projects to use different repo versions (each project has its own `.repo/repo/` installation)
- The repo tool version to be pinned and version-controlled via `REPO_REV` in `.cpmenv`
- Explicit version upgrades by updating `REPO_REV` and running `make cpm-configure`

Both installations use the same `REPO_REV` version to ensure the launcher and implementation match. The repo tool version only changes when you explicitly update `REPO_REV` in `.cpmenv` or override it via environment variable.

### Variable Inheritance

Make variables from `.cpmenv` are inherited by included Makefiles:

```bash
# .cpmenv
PACKAGES_DIR = .packages
```

```makefile
# Root Makefile loads .cpmenv
include $(CPM_ENV_FILE)
-include $(PACKAGES_DIR)/*/Makefile

# Package Makefile (included)
# PACKAGES_DIR is available here
```

---

## Summary

CPM orchestrates dependency management through:

1. **Manifest Repository** - Defines what to clone and where
2. **Repo Tool** - Executes manifest instructions
3. **Package Repositories** - Provide shared automation
4. **Glob Pattern Includes** - Automatically include all package Makefiles
5. **Make Variables** - Enable path resolution across includes

This architecture enables:
- Version-controlled automation
- Consistent automation across projects
- Single source of truth for dependencies
- Easy updates via version tags
