# Changelog

All notable changes to the Caylent Package Manager (CPM) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-14

### Added
- **Open-source DevOps Platform Dependency Manager** - Version-controlled, reproducible automation through declarative manifests
- **Platform Dependency Management** - Centralize and version DevOps automation, dependencies, and standards
- **Flexible Overlay Architecture** - Works alongside any task runner (Make, npm, Gradle, Maven) and dependency managers
- **Tool Agnostic Design** - Adapts to your workflow without replacing existing tools
- **Manifest System** - Declarative XML manifests define package dependencies and relationships
- **Git Repository Orchestration** - Fork of Gerrit `repo` tool for multi-repository dependency management
- **Environment Variable Substitution** - Dynamic configuration via environment variables in manifests
- **Automated Setup** - `cpm-configure` command installs asdf, Python, and repo tool automatically
- **Version Pinning** - Pin exact versions of automation and dependencies for reproducible builds
- **Multi-Package Support** - Glob pattern includes automatically discover and include all package automation
- **Pipeline Integration** - CI/CD support with environment variable overrides
- **Customizable for Any Organization** - Point to your own Git repositories (public or private)
- **Portable Automation** - Teams retain access to automation after external partnerships end

### Documentation
- **Setup Guide** - Step-by-step installation and configuration instructions
- **How It Works** - Complete technical walkthrough of CPM's internal process
- **Pipeline Integration Guide** - CI/CD configuration for GitHub Actions, GitLab CI, and Jenkins
- **Contributing Guide** - Instructions for creating custom manifests and package repositories
- **Architecture Documentation** - System design and component relationships

### Manifests
- **Git Connection Manifest** - Shared remote definitions for all manifests
- **Terraform Modules Monorepo Manifest** - Testing, linting, and automation for Terraform module subdirectories

### Use Cases
- **Unify Disparate Automation** - Centralize quality automation scattered across teams
- **Platform Engineering** - Provide golden paths and paved roads to development teams
- **Client Delivery** - Deliver portable, versioned automation to clients
- **Multi-Project Consistency** - Same automation across hundreds of projects

### Features
- Reproducible builds with version-controlled automation
- Consistent automation across all projects
- Simple one-command package synchronization
- Discoverability of hidden automation across organizations
- Developer freedom to use preferred tools
- Support for public and private repositories
- Custom manifest and package creation
- Task runner agnostic architecture

[1.0.0]: https://github.com/caylent-solutions/cpm/releases/tag/1.0.0
