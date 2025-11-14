# Caylent Package Manager (CPM)

Centralized platform and development automation for any organization.

> **⚠️ MVP Status:** CPM is currently in MVP phase and actively evolving. The core functionality is **validated, working, and ready for use**, but we're rapidly expanding capabilities. See [Roadmap](#roadmap) for upcoming features.

---

## What is Caylent Package Manager?

CPM is an **open-source DevOps Platform Dependency Manager** that brings version-controlled, reproducible automation to your projects through declarative manifests. Designed for managing platform automation and dependencies, CPM's flexible architecture makes it an ideal overlay for any team wanting to dynamically pull in versioned chunks of automation, capabilities, and repeatable standards—without replacing your existing tools.

**Solves a common problem:**
Many organizations have quality automation scattered across teams—scripts, tasks, and standards that work well but aren't widely adopted because they're hard to discover, version, test, and distribute. CPM enables you to centralize, version, and share this automation across your organization in a tested, reproducible way.

**Fully customizable for your organization:**
- 🏢 **Public or Private** - Use public repositories or host everything privately within your organization
- 🔧 **Your Infrastructure** - Point to your own Git repositories and package sources
- 🎯 **Your Standards** - Define your own manifests, packages, and automation
- 🤝 **Portable** - Teams retain access to automation even after external partnerships end

**Core Purpose:**
- 🏗️ **Platform Dependency Management** - Centralize and version your DevOps automation, dependencies, and standards
- 🔄 **Flexible Overlay** - Works alongside your preferred task runners (Make, npm, Gradle, Maven) and dependency managers
- 🎯 **Team Standards** - Share tested, versioned automation, tasks, and approaches across teams dynamically
- 🔧 **Tool Agnostic** - Adapts to your workflow, not the other way around

**Key Benefits:**
- 🔒 **Reproducible builds** - Pin exact versions of automation and dependencies
- 🎯 **Consistent automation** - Same tasks across all projects, any task runner
- 🔗 **Unify disparate automation** - Tie together quality automation scattered across teams in a versioned, tested way
- ⚡ **Simple management** - One command to sync all packages
- 📦 **Version control** - Track automation and dependency versions alongside code
- 👁️ **Discoverability** - Make hidden automation visible and accessible across your organization
- 🤝 **Developer freedom** - Use your preferred tools while benefiting from shared standards

---

## System Requirements

**Recommended:** Ubuntu LTS (20.04, 22.04, or 24.04)

**Required for fresh installations:**

If asdf is not already installed, CPM will build Python from source. On Ubuntu/Debian, install these build dependencies:

```bash
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl git \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev
```

**For other Linux distributions:** Consult your distribution's documentation for equivalent build tools and development libraries.

**If asdf is already installed:** No additional dependencies required.

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

CPM is **tool agnostic** - it works with any task runner or build system. Each manifest provides different artifacts (automation tasks, dependencies, configurations, or code assets) tailored to your ecosystem.

**Make-based projects:**
```bash
make help  # See all available targets
make test  # Run tests
```

**npm-based projects:**
```bash
npm run    # See available scripts
```

**Gradle/Maven projects:**
```bash
gradle tasks  # See available tasks
```

CPM's orchestration pattern adapts to your workflow. Current examples use Make, but the architecture supports npm, Gradle, Maven, and any other task runner. **We welcome contributions** for additional task runner integrations!

**[Full Setup Guide →](docs/setup-guide.md)**

---

## Use Cases

**Unify Disparate Automation:**
Your organization has quality automation scattered across teams—testing frameworks, linting configs, deployment scripts, security scans—but they're not widely adopted because they're hard to find, version, and integrate. CPM lets you package this automation, version it, and make it available to all teams through simple manifests.

**Platform Engineering:**
Provide golden paths and paved roads to development teams. Package your organization's standards, policies, and automation as versioned dependencies that teams can pull into their projects.

**Client Delivery:**
Deliver tested, versioned automation to clients that they can continue using after your engagement ends. Everything is portable and self-contained.

**Multi-Project Consistency:**
Ensure the same testing, linting, security scanning, and deployment automation across hundreds of projects without copy-pasting or manual synchronization.

---

## Available Manifests

**Caylent-Provided Examples:**
- **[Git Connection](repo-specs/git-connection/README.md)** - Shared remote definitions for all manifests
- **[Terraform Modules Monorepo](repo-specs/terraform/caylent-terraform-modules-monorepo/modules/README.md)** - Testing, linting, and automation for Terraform module subdirectories

**Note:** These are reference implementations. You can create your own manifests pointing to your organization's repositories. See [Contributing Guide](docs/contributing.md) for creating custom manifests.

---

## How It Works

CPM uses a fork of the Gerrit `repo` tool to orchestrate dependencies across Git repositories. Manifests define what to clone, where to place it, and how to wire it together. You can point CPM to any Git repositories—public or private, within your organization or external.

**[Complete Technical Walkthrough →](docs/how-it-works.md)**

---

## Documentation

- **[Setup Guide](docs/setup-guide.md)** - Step-by-step setup instructions
- **[How It Works](docs/how-it-works.md)** - Complete technical walkthrough
- **[Pipeline Integration](docs/pipeline-integration.md)** - CI/CD pipeline configuration
- **[Contributing](docs/contributing.md)** - Create manifests and package repositories
- **[Git Connection Manifest](repo-specs/git-connection/README.md)** - Remote definitions
- **[Terraform Modules Manifest](repo-specs/terraform/caylent-terraform-modules-monorepo/modules/README.md)** - Terraform automation

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
              │    domain and automation repos     │
              └──────────────────┬─────────────────┘
                                 │
        references               │                references
                                 │
             ▼                                       ▼
┌───────────────────────┐                ┌────────────────────────┐
│  Package Repositories │                │ Automation Repositories│
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

Current version: `1.0.0`

---

## Roadmap

CPM is actively evolving. Here's what's coming:

**In Development:**
- 📜 **Policy as Code** - Reusable policy definitions for compliance and governance
- 🤖 **AI Agent Prompts** - Pre-written prompts for developer assistance and automation
- 🧪 **Testing Framework** - Comprehensive unit, functional, and integration tests
- 🚀 **CI/CD Pipelines** - Full pipeline automation for CPM itself
- 🛠️ **Task Runner Examples** - npm, Gradle, Maven, and more

**Future Enhancements:**
- Additional ecosystem manifests (Python, Java, Go, .NET)
- Enhanced package discovery and search
- Dependency conflict resolution
- Package signing and verification

Want to contribute to any of these? Check out our [Contributing Guide](docs/contributing.md)!

---

## Contributing

CPM is designed to be flexible and extensible. We welcome contributions!

**Ways to contribute:**
- 📦 Create manifests for new ecosystems (Python, Java, Go, etc.)
- 🔧 Add task runner examples (npm, Gradle, Maven)
- 📚 Improve documentation
- 🐛 Report issues and suggest features
- ⭐ Share your use cases and success stories

Your contributions help make CPM more valuable for everyone. Whether you're adapting CPM for a new language, creating reusable automation packages for your organization, or improving the developer experience—we'd love to see what you build!

**Using CPM in your organization:**
CPM is designed to be fully customizable. Fork it, point it to your own repositories, and create your own manifests and packages. What Caylent provides are mature reference implementations that you can use, extend, or replace entirely.

**[Contributing Guide →](docs/contributing.md)**

---

## License

Apache 2.0

---

## Support

- **Issues:** [GitHub Issues](https://github.com/caylent-solutions/cpm/issues)
- **Slack:** `#cpm-support`
