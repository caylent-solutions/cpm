# Pipeline Integration

Guide for using CPM in CI/CD pipelines.

---

## Overview

CPM supports pipeline execution by allowing environment variables to override `.cpmenv` configuration. This enables dynamic configuration per pipeline run without modifying files.

---

## How It Works

The `.cpmenv` file uses Make's `?=` operator for conditional assignment:

```makefile
REPO_MANIFESTS_URL ?= https://github.com/caylent-solutions/cpm.git
REPO_REV ?= caylent-1.0.0
```

**Behavior:**
- If the variable is already set (via environment), use that value
- If not set, use the default from `.cpmenv`

This allows pipelines to inject configuration while developers use local defaults.

---

## Pipeline Configuration

### GitHub Actions

```yaml
name: Build
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      REPO_MANIFESTS_REVISION: refs/tags/2.0.0
      REPO_REV: caylent-2.0.0
      ASDF_DIR: /tmp/.asdf
    steps:
      - uses: actions/checkout@v4
      - run: make configure
      - run: make test
```

### GitLab CI

```yaml
variables:
  REPO_MANIFESTS_REVISION: refs/tags/2.0.0
  REPO_REV: caylent-2.0.0
  ASDF_DIR: /tmp/.asdf

build:
  script:
    - make configure
    - make test
```

### Jenkins

```groovy
pipeline {
    agent any
    environment {
        REPO_MANIFESTS_REVISION = 'refs/tags/2.0.0'
        REPO_REV = 'caylent-2.0.0'
        ASDF_DIR = '/tmp/.asdf'
    }
    stages {
        stage('Build') {
            steps {
                sh 'make configure'
                sh 'make test'
            }
        }
    }
}
```

---

## Common Pipeline Overrides

### Version Pinning

Override CPM and package versions per environment:

```bash
export REPO_MANIFESTS_REVISION=refs/tags/2.0.0
export REPO_REV=caylent-2.0.0
```

### Custom Paths

Use pipeline-specific directories:

```bash
export ASDF_DIR=/tmp/.asdf
export PACKAGES_DIR=/tmp/packages
```

### Git Configuration

Use different Git organizations or mirrors:

```bash
export GITBASE=https://gitlab.internal.company.com/
export REPO_MANIFESTS_URL=https://gitlab.internal.company.com/cpm.git
```

---

## Required Variables

All variables in `.cpmenv` can be overridden. Key variables for pipelines:

| Variable | Purpose | Example |
|----------|---------|---------|
| `REPO_MANIFESTS_REVISION` | CPM version/branch | `refs/tags/0.1.2` |
| `REPO_REV` | repo tool version | `caylent-1.0.0` |
| `ASDF_DIR` | asdf installation path | `/tmp/.asdf` |
| `PACKAGES_DIR` | Package sync location | `packages` |

---

## Validation

The Makefile validates all required variables are set, whether from `.cpmenv` or environment:

```makefile
REQUIRED_VARS := REPO_MANIFESTS_URL REPO_REV ...
$(foreach var,$(REQUIRED_VARS),$(if $($(var)),,$(error Error: $(var) not set)))
```

If a variable is missing from both sources, the build fails with a clear error.

---

## Best Practices

### 1. Keep .cpmenv for Local Development

Commit `.cpmenv` with sensible defaults for developers:

```makefile
REPO_MANIFESTS_REVISION ?= refs/tags/0.1.2
ASDF_DIR ?= $(HOME)/.asdf
```

### 2. Override in Pipeline

Set only what needs to change:

```yaml
env:
  REPO_MANIFESTS_REVISION: refs/tags/2.0.0  # Use newer version
  ASDF_DIR: /tmp/.asdf                       # Pipeline-specific path
```

### 3. Document Pipeline Variables

Add comments to `.cpmenv` indicating which variables pipelines typically override:

```makefile
# Commonly overridden in pipelines
REPO_MANIFESTS_REVISION ?= refs/tags/0.1.2
ASDF_DIR ?= $(HOME)/.asdf
```

### 4. Test Locally

Verify pipeline configuration locally:

```bash
export REPO_MANIFESTS_REVISION=refs/tags/2.0.0
make configure
```

---

## Troubleshooting

### Variable Not Overriding

**Problem:** Environment variable not taking effect

**Solution:** Ensure `.cpmenv` uses `?=` not `=`:

```makefile
# Wrong - always uses file value
REPO_REV = caylent-1.0.0

# Correct - environment can override
REPO_REV ?= caylent-1.0.0
```

### Missing Variable Error

**Problem:** `Error: REPO_REV not set in .cpmenv`

**Solution:** Set the variable in pipeline environment or `.cpmenv`

### Path Issues

**Problem:** Permission denied in pipeline

**Solution:** Use pipeline-writable paths:

```bash
export ASDF_DIR=/tmp/.asdf
export PACKAGES_DIR=/tmp/packages
```

---

## Example: Multi-Environment Setup

### Development (.cpmenv)

```makefile
REPO_MANIFESTS_REVISION ?= refs/heads/main
REPO_REV ?= caylent-1.0.0
```

### Staging Pipeline

```yaml
env:
  REPO_MANIFESTS_REVISION: refs/tags/0.1.2-rc1
```

### Production Pipeline

```yaml
env:
  REPO_MANIFESTS_REVISION: refs/tags/0.1.2
```

Same `.cpmenv` file, different behavior per environment.

---

## Related Documentation

- [Setup Guide](setup-guide.md) - Initial configuration
- [How It Works](how-it-works.md) - Technical details
