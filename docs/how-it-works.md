# How CPM Works

Complete walkthrough of CPM's internal process from project creation to running automation tasks.

**Note:** This guide uses Make as an example task runner, but CPM is tool-agnostic and works with npm, Gradle, Maven, or any automation tool. The orchestration process is identical regardless of the task runner.

---

## Overview

CPM uses the Caylent fork of the Gerrit `repo` tool to orchestrate dependency management across multiple Git repositories. This document explains every step of the process.

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
git checkout https://github.com/caylent-solutions/cpm.git example/Makefile
git checkout https://github.com/caylent-solutions/cpm.git example/.cpmenv
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

## Step 3: User Runs `make configure`

```bash
make configure
```

### 3.1: Makefile Execution

The Makefile loads `.cpmenv`, validates all required variables are set, then executes the `configure` target:

```makefile
.PHONY: configure
configure: install-asdf install-tools install-repo
	# repo init and sync commands
```

**Variables loaded from `.cpmenv`:**
- `REPO_MANIFESTS_URL` → `https://github.com/caylent-solutions/cpm.git`
- `REPO_MANIFESTS_REVISION` → `refs/tags/0.1.3`
- `REPO_MANIFESTS_PATH` → `manifests/terraform/caylent-terraform-modules-monorepo/modules/meta.xml`

**Configure steps:**
1. Install asdf v0.15.0 (if not already installed)
2. Install tools from `.tool-versions` via asdf
3. Install Caylent repo tool (version from `REPO_REV`)
4. Run `repo init` with manifest configuration
5. Run `repo sync` to clone packages

---

## Step 4: `repo init` Executes

### 4.1: Clone CPM Manifest Repository

The repo tool clones the CPM manifest repository:

```bash
git clone https://github.com/caylent-solutions/cpm.git .repo/manifests
cd .repo/manifests
git checkout refs/tags/0.1.3
```

**Result:**
```
my-project/
├── .git/
├── .repo/
│   └── manifests/  (CPM repo cloned here)
│       ├── manifests/
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

Repo tool loads: `.repo/manifests/manifests/terraform/caylent-terraform-modules-monorepo/modules/meta.xml`

```xml
<manifest>
  <include name="manifests/git-connection/remote.xml" />
  <include name="manifests/terraform/caylent-terraform-modules-monorepo/modules/packages.xml" />
</manifest>
```

**Processing:**
1. Includes `manifests/git-connection/remote.xml` (absolute from repo root)
2. Includes `manifests/terraform/caylent-terraform-modules-monorepo/modules/packages.xml` (absolute from repo root)

### 4.3: Load Remote Definition

Loads: `.repo/manifests/manifests/git-connection/remote.xml`

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

Loads: `.repo/manifests/manifests/terraform/caylent-terraform-modules-monorepo/modules/packages.xml`

```xml
<manifest>
  <project name="cpm-terraform-modules-monorepo"
           path="packages/modules"
           remote="caylent-devops-platform"
           revision="refs/tags/0.1.3">
    <linkfile src="modules/linkfiles/Makefile" dest="packages/Makefile" />
  </project>
</manifest>
```

**Processing:**
- Project name: `cpm-terraform-modules-monorepo`
- Clone to: `packages/modules/`
- Remote: `caylent-devops-platform` → `https://github.com/caylent-solutions/`
- Full URL: `https://github.com/caylent-solutions/cpm-terraform-modules-monorepo`
- Revision: `refs/tags/0.1.3`
- Linkfile: `modules/linkfiles/Makefile` → `packages/Makefile`

---

## Step 5: `repo sync` Executes

### 5.1: Clone Package Repository

```bash
git clone https://github.com/caylent-solutions/cpm-terraform-modules-monorepo packages/modules
cd packages/modules
git checkout refs/tags/0.1.3
```

**Result:**
```
my-project/
├── .git/
├── .repo/
├── packages/
│   └── modules/  (cpm-terraform-modules-monorepo cloned here)
│       ├── modules/
│       │   ├── linkfiles/
│       │   │   └── Makefile
│       │   └── tasks/
│       │       └── Makefile
│       └── README.md
├── Makefile
└── .cpmenv
```

### 5.2: Create Linkfile

**Linkfile definition:**
```xml
<linkfile src="modules/linkfiles/Makefile" dest="packages/Makefile" />
```

**Processing:**
- Source: `packages/modules/modules/linkfiles/Makefile` (relative to workspace root)
- Destination: `packages/Makefile` (relative to workspace root)
- Action: Create symlink

**Command executed:**
```bash
ln -s modules/modules/linkfiles/Makefile packages/Makefile
```

**Result:**
```
my-project/
├── .git/
├── .repo/
├── packages/
│   ├── Makefile@ → modules/modules/linkfiles/Makefile  (SYMLINK CREATED)
│   └── modules/
│       └── modules/
│           ├── linkfiles/
│           │   └── Makefile
│           └── tasks/
│               └── Makefile
├── Makefile
└── .cpmenv
```

---

## Step 6: User Runs Automation Task

User runs an automation task (using Make in this example):

```bash
make test
```

**Note:** The same pattern works with npm (`npm run test`), Gradle (`gradle test`), or any task runner. CPM provides the packages; your task runner executes them.

### 6.1: Root Makefile Execution

**File:** `./Makefile`

```makefile
PACKAGES_DIR = packages
-include $(PACKAGES_DIR)/Makefile
```

**Processing:**
- Sets `PACKAGES_DIR = packages`
- Includes `packages/Makefile`
- This is a symlink: `packages/Makefile` → `packages/modules/modules/linkfiles/Makefile`

### 6.2: Linkfiles Makefile Execution

**File:** `packages/modules/modules/linkfiles/Makefile`

```makefile
# CPM Terraform Modules - Makefile Wrapper
include $(PACKAGES_DIR)/modules/tasks/Makefile
```

**Processing:**
- `$(PACKAGES_DIR)` = `packages` (inherited from root Makefile)
- Expands to: `include packages/modules/tasks/Makefile`
- Working directory: `my-project/` (root)
- Resolves to: `my-project/packages/modules/modules/tasks/Makefile`

### 6.3: Tasks Makefile Execution

**File:** `packages/modules/modules/tasks/Makefile`

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
│   ├── manifest.xml         # Resolved manifest
│   └── ...
├── packages/
│   ├── Makefile@            # Symlink → modules/modules/linkfiles/Makefile
│   └── modules/             # cpm-terraform-modules-monorepo repo
│       └── modules/
│           ├── linkfiles/
│           │   └── Makefile     # Wrapper: includes $(PACKAGES_DIR)/modules/tasks/Makefile
│           └── tasks/
│               └── Makefile     # Actual make targets
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
   - Sets: PACKAGES_DIR = packages
   - Includes: packages/Makefile
    ↓
2. Symlink Resolution
   - packages/Makefile → packages/modules/modules/linkfiles/Makefile
    ↓
3. Linkfiles Makefile (packages/modules/modules/linkfiles/Makefile)
   - Includes: $(PACKAGES_DIR)/modules/tasks/Makefile
   - Expands to: packages/modules/modules/tasks/Makefile
    ↓
4. Tasks Makefile (packages/modules/modules/tasks/Makefile)
   - Executes: test target
   - Runs: tftest, go clean, etc.
```

---

## Key Concepts

### Environment Variable Substitution

The repo tool supports environment variable substitution in manifests:

```xml
<remote name="caylent-devops-platform" fetch="${GITBASE}"/>
```

The `${GITBASE}` is replaced with the value from the environment (set in `.cpmenv`, exported by Makefile).

### Linkfiles

Linkfiles create symlinks from the cloned repository to the workspace:

```xml
<linkfile src="modules/linkfiles/Makefile" dest="packages/Makefile" />
```

- `src` is relative to the cloned project path
- `dest` is relative to workspace root

### Variable Inheritance

Make variables from `.cpmenv` are inherited by included Makefiles:

```bash
# .cpmenv
PACKAGES_DIR = packages
```

```makefile
# Root Makefile loads .cpmenv
include $(CPM_ENV_FILE)
-include $(PACKAGES_DIR)/Makefile

# Linkfiles Makefile (included)
include $(PACKAGES_DIR)/modules/tasks/Makefile  # PACKAGES_DIR is available here
```

---

## Summary

CPM orchestrates dependency management through:

1. **Manifest Repository** - Defines what to clone and where
2. **Repo Tool** - Executes manifest instructions
3. **Package Repositories** - Provide shared tooling
4. **Symlinks** - Connect packages to workspace
5. **Make Variables** - Enable path resolution across includes

This architecture enables:
- Version-controlled tooling
- Consistent automation across projects
- Single source of truth for dependencies
- Easy updates via version tags
