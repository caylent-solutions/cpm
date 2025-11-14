# Caylent Package Manager (CPM)

Centralized platform and development automation across Caylent projects.

---

## What is CPM?

CPM provides **version-controlled, reproducible automation** for your projects through declarative manifests. Define your dependencies once, sync them anywhere, and keep your tooling consistent across all repositories.

**Key Benefits:**
- 🔒 **Reproducible builds** - Pin exact versions of tooling and automation
- 🎯 **Consistent automation** - Same tasks across all projects
- ⚡ **Simple management** - One command to sync all packages
- 📦 **Version control** - Track automation and tooling versions alongside code

---

## Quick Start

### 1. Setup

Copy the task runner files from your chosen manifest's `example/` directory.

**For Terraform Modules:**
```bash
curl -o Makefile https://raw.githubusercontent.com/caylent-solutions/cpm/main/repo-specs/terraform/caylent-terraform-modules-monorepo/modules/example/Makefile
curl -o .cpmenv https://raw.githubusercontent.com/caylent-solutions/cpm/main/repo-specs/terraform/caylent-terraform-modules-monorepo/modules/example/.cpmenv
```

The `.cpmenv` file is pre-configured with the correct manifest path for that ecosystem.

### 2. Verify Configuration

Check that `.cpmenv` has the correct `REPO_MANIFESTS_PATH` for your manifest:

```bash
cat .cpmenv | grep REPO_MANIFESTS_PATH
```

### 3. Configure

```bash
make cpm-configure
```

This automatically installs asdf, Python, and the repo tool. It also adds `.packages/` and `.repo/` to `.gitignore`.

**Important:** All synced files in `.packages/` and `.repo/` are ephemeral and should not be committed. Only commit `Makefile` and `.cpmenv` to your repository.

### 4. Use

Each manifest provides different artifacts - automation tasks, dependencies, configurations, or code assets. For Make-based manifests, run `make help` to see available targets. For other manifests, refer to the manifest's README for usage instructions.

**Note:** While not yet implemented, CPM's orchestration pattern is designed to support any task runner (npm, Gradle, Maven, etc.). Future examples will demonstrate these integrations.

**[Full Setup Guide →](docs/setup-guide.md)**

---

## Available Manifests

- **[Git Connection](repo-specs/git-connection/README.md)** - Shared remote definitions for all manifests
- **[Terraform Modules Monorepo](repo-specs/terraform/caylent-terraform-modules-monorepo/modules/README.md)** - Testing, linting, and automation for Terraform module subdirectories

---

## How It Works

CPM uses the Caylent fork of the Gerrit `repo` tool to orchestrate dependencies across Git repositories. Manifests define what to clone, where to place it, and how to wire it together.

**[Complete Technical Walkthrough →](docs/how-it-works.md)**

---

## Documentation

- **[Setup Guide](docs/setup-guide.md)** - Step-by-step setup instructions
- **[How It Works](docs/how-it-works.md)** - Complete technical walkthrough
- **[Pipeline Integration](docs/pipeline-integration.md)** - CI/CD pipeline configuration
- **[Contributing](docs/contributing.md)** - Create manifests and package repositories
- **[Git Connection Manifest](repo-specs/git-connection/README.md)** - Remote definitions
- **[Terraform Modules Manifest](repo-specs/terraform/caylent-terraform-modules-monorepo/modules/README.md)** - Terraform tooling

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
             ▼                                       ▼
┌───────────────────────┐                ┌────────────────────────┐
│  Package Repositories │                │   Tooling Repositories │
│ (e.g., cpm-terraform- │                │ (shared make targets,  │
│  modules-monorepo)    │                │  validation, linting)  │
└────────────┬──────────┘                └───────────┬────────────┘
             │                                       │
             └───────────────────┬───────────────────┘
                                 │
                                 ▼
                   ┌────────────────────────────┐
                   │ Caylent Gerrit `repo` Fork │
                   │ (git-repo caylent-1.0.0)   │
                   │ Executes manifests, syncs  │
                   │ repos, manages workspace   │
                   └────────────────────────────┘
```

---

## Version

Current version: `0.1.11`

---

## License

Apache 2.0

---

## Support

- **Issues:** [GitHub Issues](https://github.com/caylent-solutions/cpm/issues)
- **Slack:** `#cpm-support`
