# Terraform Modules Monorepo - CPM Manifest

This manifest provides shared tooling for Terraform modules in the [Caylent terraform-modules monorepo](https://github.com/caylent-solutions/terraform-modules).

## Purpose

Provides standardized Make targets for individual Terraform module subdirectories within the terraform-modules monorepo, eliminating code duplication across all modules.

## Target Repository

**Monorepo:** https://github.com/caylent-solutions/terraform-modules

**Structure:**
```
terraform-modules/
├── Makefile                          # Monorepo orchestration (NOT replaced)
├── providers/aws/primitives/s3/
│   ├── Makefile                      # Module tasks (REPLACED by CPM)
│   ├── main.tf
│   └── tests/
└── providers/aws/collections/eks/
    ├── Makefile                      # Module tasks (REPLACED by CPM)
    ├── main.tf
    └── tests/
```

## What This Manifest Provides

- **cpm-terraform-modules-monorepo**: Shared Make targets for module-level operations
  - Testing with Terratest
  - Linting and formatting (Terraform and Go)
  - Documentation generation
  - Security scanning
  - Dependency management

**Note:** This only provides tooling for individual module subdirectories. The monorepo root Makefile remains in the terraform-modules repository and is not managed by CPM.

## Usage

Module developers add the CPM Makefile to their module subdirectory:

```bash
cd providers/aws/primitives/s3
# Copy CPM Makefile from cpm/example/Makefile
make configure  # Syncs CPM packages
make test       # Uses CPM targets
```

## Manifest Path

Use this manifest in your module's Makefile:

```makefile
REPO_MANIFESTS_PATH ?= manifests/terraform/caylent-terraform-modules-monorepo/meta.xml
```

## Files

- `meta.xml` - Main manifest (includes remote and packages)
- `packages.xml` - Defines cpm-terraform-modules package
- `../git-connection/remote.xml` - Remote definition (shared across all manifests)

## Related Manifests

This is one of many CPM manifests for different development categories:
- `manifests/terraform/caylent-terraform-modules-monorepo/modules/` - This manifest (module subdirectories)
- `manifests/python/` - Python projects (future)
- `manifests/dotnet/` - .NET projects (future)
- `manifests/java/` - Java projects (future)
- `manifests/cdk/` - AWS CDK projects (future)
