# Caylent Package Manager (CPM)

Centralized platform and development automation across Caylent projects.

---

## What is CPM?

CPM provides **version-controlled, reproducible automation** for your projects through declarative manifests. Define your dependencies once, sync them anywhere, and keep your tooling consistent across all repositories.

**Key Benefits:**
- 🔒 **Reproducible builds** - Pin exact versions of tooling and automation
- 🎯 **Consistent automation** - Same tasks across all projects (Make, npm, Gradle, etc.)
- ⚡ **Simple management** - One command to sync all packages
- 📦 **Version control** - Track automation and tooling versions alongside code
- 🔧 **Tool agnostic** - Works with any task runner (Make, npm, Gradle, Maven, etc.)

---

## Quick Start

### 1. Setup

```bash
git checkout https://github.com/caylent-solutions/cpm.git example/Makefile
git checkout https://github.com/caylent-solutions/cpm.git example/.cpmenv
```

### 2. Set Manifest Path

Edit `.cpmenv` and set `REPO_MANIFESTS_PATH` to your desired manifest:

```bash
REPO_MANIFESTS_PATH ?= manifests/terraform/caylent-terraform-modules-monorepo/modules/meta.xml
```

### 3. Configure

```bash
make configure
```

This automatically installs asdf, Python, and the repo tool. It also adds `.packages/` and `.repo/` to `.gitignore`.

**Important:** All synced files in `.packages/` and `.repo/` are ephemeral and should not be committed. Only commit `Makefile` and `.cpmenv` to your repository.

### 4. Use

Each manifest provides different artifacts - automation tasks, dependencies, configurations, or code assets. For Make-based manifests, run `make help` to see available targets. For other manifests, refer to the manifest's README for usage instructions.

**[Full Setup Guide →](docs/setup-guide.md)**

---

## Available Manifests

- **[Git Connection](manifests/git-connection/README.md)** - Shared remote definitions for all manifests
- **[Terraform Modules Monorepo](manifests/terraform/caylent-terraform-modules-monorepo/modules/README.md)** - Testing, linting, and automation for Terraform module subdirectories

---

## How It Works

CPM uses the Caylent fork of the Gerrit `repo` tool to orchestrate dependencies across Git repositories. Manifests define what to clone, where to place it, and how to wire it together. Works with any task runner - Make, npm, Gradle, Maven, or custom scripts.

**[Complete Technical Walkthrough →](docs/how-it-works.md)**

---

## Documentation

- **[Setup Guide](docs/setup-guide.md)** - Step-by-step setup instructions
- **[How It Works](docs/how-it-works.md)** - Complete technical walkthrough
- **[Pipeline Integration](docs/pipeline-integration.md)** - CI/CD pipeline configuration
- **[Git Connection Manifest](manifests/git-connection/README.md)** - Remote definitions
- **[Terraform Modules Manifest](manifests/terraform/caylent-terraform-modules-monorepo/modules/README.md)** - Terraform tooling

---

## Architecture

```text
                   ┌──────────────────────────┐
                   │  Caylent Package Manager │
                   │          (CPM)           │
                   └────────────┬─────────────┘
                                │
               defines          │            uses
                                ▼
              ┌────────────────────────────────────┐
              │     cpm (Meta Manifests Repo)      │
              │  - Top-level dependency manifests  │
              │  - Declares relationships between  │
              │    domain and tooling repos        │
              └──────────────────┬─────────────────┘
                                 │
        references               │                references
                                 │
             ▼                                      ▼
┌──────────────────────┐                  ┌─────────────────────────┐
│  Package Repositories│                  │   Tooling Repositories  │
│ (e.g., cpm-terraform-│                  │ (shared make targets,   │
│  modules-monorepo)   │                  │  validation, linting)   │
└────────────┬─────────┘                  └────────────┬────────────┘
             │                                         │
             └────────────────────┬────────────────────┘
                                  │
                                  ▼
                    ┌───────────────────────────┐
                    │ Caylent Gerrit `repo` Fork│
                    │ (git-repo caylent-1.0.0)  │
                    │ Executes manifests, syncs │
                    │ repos, manages workspace  │
                    └───────────────────────────┘
```

---

## Version

Current version: `0.1.6`

---

## License

Apache 2.0

---

## Support

- **Issues:** [GitHub Issues](https://github.com/caylent-solutions/cpm/issues)
- **Slack:** `#cpm-support`
