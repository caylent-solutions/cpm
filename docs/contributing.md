# Contributing to CPM

Guide for contributing to CPM and customizing it for your organization.

## Open Source & Customizable

CPM is open source and designed for any organization to use, customize, and extend:

- **Use as-is:** Leverage Caylent's public manifests and packages
- **Customize:** Fork CPM and point to your own repositories
- **Extend:** Create your own manifests and packages for your organization
- **Contribute back:** Share improvements that benefit the community

What Caylent provides are mature reference implementations. You're free to use them, extend them, or create entirely custom solutions for your organization.

---

## Contribution Areas

CPM has three main areas for contribution and customization:

1. **Creating Top-Level Manifests** - Define new package ecosystems for your organization (Terraform, Python, Java, etc.)
2. **Creating Package Repositories** - Build shared automation that your manifests reference
3. **Core CPM Development** - Improve the CPM framework itself and contribute back to the community

---

## Creating Top-Level Manifests

Top-level manifests define how CPM integrates with specific project types (Terraform modules, Python packages, Java applications, etc.).

### Required Structure

Manifests can be organized with multiple levels of nesting to scope by ecosystem, project type, and use case:

```
repo-specs/
├── terraform/
│   ├── generic/
│   │   ├── modules/
│   │   │   ├── example/
│   │   │   ├── meta.xml
│   │   │   └── packages.xml
│   │   └── policies/
│   ├── providers/
│   └── caylent-terraform-modules-monorepo/
│       ├── modules/
│       └── policies/
├── python/
│   ├── clis/
│   ├── lambdas/
│   ├── containers/
│   └── django/
└── java/
    ├── spring-boot/
    └── microservices/
```

**Each manifest directory must contain:**
```
<manifest-path>/
├── example/
│   ├── <task-runner-file>  # Makefile, package.json, build.gradle, etc.
│   └── .cpmenv
├── meta.xml
├── packages.xml
└── README.md
```

### Required Files

#### 1. `example/` Directory

Contains all files developers need to set up CPM in their projects. Developers will curl these files directly.

**Required files:**
- Task runner file (Makefile, package.json, build.gradle, pom.xml, etc.)
- `.cpmenv` - Configuration file with all required variables

#### 2. Task Runner File Requirements

The task runner file MUST implement these CPM tasks:

| Task | Purpose | Behavior |
|------|---------|----------|
| `cpm-configure` | Initialize CPM | Install dependencies, run repo init/sync, update .gitignore |
| `cpm-clean` | Remove synced packages | Delete .packages/ and .repo/ directories |
| `cpm-install-asdf` | Install asdf version manager | Clone asdf if not present, create .tool-versions |
| `cpm-install-tools` | Install tools from .tool-versions | Add asdf plugins, run asdf install |
| `cpm-install-repo` | Install repo tool | pip install repo tool at specified version |
| `help` | Show available targets | List all available tasks (optional, root provides this) |

**Task Dependencies:**
```
cpm-configure
  ├── cpm-install-asdf
  ├── cpm-install-tools
  └── cpm-install-repo
```

#### 3. `.cpmenv` File Requirements

Must define these variables:

```bash
# CPM Repository
REPO_MANIFESTS_URL ?= https://github.com/caylent-solutions/cpm.git
REPO_MANIFESTS_REVISION ?= refs/tags/1.0.0
REPO_MANIFESTS_PATH ?= repo-specs/<path>/<to>/<manifest>/meta.xml

# Repo Tool
REPO_URL ?= https://github.com/caylent-solutions/git-repo.git
REPO_REV ?= caylent-1.0.0

# Git Base URL
GITBASE ?= https://github.com/caylent-solutions/

# Pipeline Configuration
IS_PIPELINE ?= false
JOB_NAME ?= job
JOB_EMAIL ?= job@job.job

# asdf Configuration
ASDF_URL ?= https://github.com/asdf-vm/asdf.git
ASDF_VERSION ?= v0.15.0
ASDF_DIR ?= $$HOME/.asdf
TOOL_VERSIONS_FILE ?= .tool-versions
DEFAULT_PYTHON_VERSION ?= 3.12.9

# Package Directory
PACKAGES_DIR ?= .packages
```

**Important:** Use `$$HOME` (double dollar) for Make variable escaping, or use appropriate syntax for your task runner.

#### 4. Manifest Files

**meta.xml** - Includes other manifests:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <include name="repo-specs/git-connection/remote.xml" />
  <include name="repo-specs/<path>/<to>/<manifest>/packages.xml" />
</manifest>
```

**Examples:**
- `repo-specs/terraform/caylent-terraform-modules-monorepo/modules/meta.xml`
- `repo-specs/python/lambdas/meta.xml`
- `repo-specs/java/spring-boot/meta.xml`

**packages.xml** - Defines package repositories to clone:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="<package-repo-name>"
           path=".packages/<package-repo-name>"
           remote="caylent-solutions"
           revision="refs/tags/1.0.0" />
</manifest>
```

#### 5. README.md

Document:
- What the manifest provides
- Target use cases
- How to use it
- Available tasks/targets
- Example usage

### Task Runner Examples

#### Make (Makefile)

```makefile
.PHONY: cpm-configure
cpm-configure: cpm-install-asdf cpm-install-tools cpm-install-repo
	@if [ ! -f .gitignore ] || ! grep -q "^$(PACKAGES_DIR)/$$" .gitignore; then \
		echo "$(PACKAGES_DIR)/" >> .gitignore; \
	fi
	@if [ ! -f .gitignore ] || ! grep -q "^\.repo/$$" .gitignore; then \
		echo ".repo/" >> .gitignore; \
	fi
	@ASDF_DIR=$(ASDF_DIR) && . $$ASDF_DIR/asdf.sh && \
	repo init --no-repo-verify \
		-u "$(REPO_MANIFESTS_URL)" \
		-b "$(REPO_MANIFESTS_REVISION)" \
		-m "$(REPO_MANIFESTS_PATH)" \
		--repo-rev="$(REPO_REV)" && \
	repo sync
```

#### npm (package.json)

```json
{
  "scripts": {
    "cpm-configure": "npm run cpm-install-asdf && npm run cpm-install-tools && npm run cpm-install-repo && npm run cpm-repo-sync",
    "cpm-clean": "rm -rf .packages .repo",
    "cpm-install-asdf": "...",
    "cpm-install-tools": "...",
    "cpm-install-repo": "...",
    "cpm-repo-sync": "repo init ... && repo sync"
  }
}
```

#### Gradle (build.gradle)

```gradle
task cpmConfigure {
    dependsOn 'cpmInstallAsdf', 'cpmInstallTools', 'cpmInstallRepo'
    doLast {
        exec {
            commandLine 'repo', 'init', ...
        }
        exec {
            commandLine 'repo', 'sync'
        }
    }
}
```

### Testing Your Manifest

1. Create a test project
2. Copy files from your manifest's `example/` directory
3. Run the configure task: `make cpm-configure` (or equivalent)
4. Verify packages are cloned to `.packages/`
5. Verify all tasks work correctly

---

## Creating Package Repositories

Package repositories contain shared automation that manifests reference.

### Repository Structure

```
<package-repo-name>/
├── Makefile (or equivalent)    # MUST be at root for Make-based projects
├── common.mk (optional)        # Shared variables/functions
├── README.md
└── <other tooling files>
```

**For Make-based projects:** The Makefile MUST be at the repository root because the root Makefile uses glob patterns to include them:

```makefile
-include $(PACKAGES_DIR)/*/Makefile
```

**For other task runners:** The integration pattern depends on the task runner. For example:
- **npm:** May use `npm run` to execute scripts from package.json in `.packages/`
- **Gradle:** May use `apply from:` to include build files
- **Maven:** May use parent POM references

### Package Repository Guidelines

1. **Root-level task file** - For Make: Must be at repository root for glob pattern inclusion. For other runners: Follow that runner's conventions
2. **No `help` target** (Make only) - Root Makefile provides generic help that discovers all targets
3. **Shared includes** - Use `common.mk` (Make), shared modules (npm), or similar for shared variables/functions
4. **Documentation** - Explain what automation tasks are provided and how to use them
5. **Versioning** - Use semantic versioning tags

### Example Package Repository

```makefile
# Makefile at root
.PHONY: test lint format

test:
	@echo "Running tests..."
	@pytest

lint:
	@echo "Linting code..."
	@pylint src/

format:
	@echo "Formatting code..."
	@black src/
```

### Including Shared Files

If you need shared variables or functions:

```makefile
# common.mk
TEST_TIMEOUT ?= 300
PYTHON_VERSION ?= 3.12

# Makefile
include $(dir $(lastword $(MAKEFILE_LIST)))common.mk

test:
	@timeout $(TEST_TIMEOUT) pytest
```

---

## Core CPM Development

### Repository Structure

```
cpm/
├── examples/                    # Task runner templates
│   └── example-make-task-runner/
│       ├── Makefile
│       └── .cpmenv
├── repo-specs/                  # Top-level manifests
│   ├── git-connection/
│   └── <ecosystem>/
├── docs/                        # Documentation
├── scripts/                     # Validation scripts
└── README.md
```

### Adding New Task Runner Support

1. Create `examples/example-<runner>-task-runner/` directory
2. Implement all required CPM tasks in that runner's syntax
3. Add `.cpmenv` with all required variables
4. Document in README.md
5. Create example manifest using that runner

### Testing Changes

1. Update version numbers
2. Commit changes
3. Create annotated tags
4. Push tags
5. Test with a real project

---

## Submission Guidelines

### Pull Request Checklist

- [ ] All required CPM tasks implemented
- [ ] `.cpmenv` has all required variables
- [ ] `example/` directory contains all necessary files
- [ ] README.md documents usage
- [ ] XML manifests are valid (run `make validate-xml`)
- [ ] Tested with a real project
- [ ] Version numbers updated
- [ ] Documentation updated

### Commit Message Format

```
<type>: <description>

<body>
```

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

Examples:
- `feat: Add Python manifest support`
- `fix: Correct ASDF_DIR expansion in Makefile`
- `docs: Update contributing guide`

---

## Questions?

- **Issues:** [GitHub Issues](https://github.com/caylent-solutions/cpm/issues)
- **Slack:** `#cpm-support`
