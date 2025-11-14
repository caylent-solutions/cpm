# Terraform Modules Monorepo - CPM Manifest

This manifest provides shared automation for Terraform modules in the [Caylent terraform-modules monorepo](https://github.com/caylent-solutions/terraform-modules).

**Reference Implementation:** This is Caylent's example manifest. You can use it as-is, or create your own manifest pointing to your organization's Terraform module repositories.

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

**Note:** This only provides automation for individual module subdirectories. The monorepo root Makefile remains in the terraform-modules repository and is not managed by CPM.

## Package Repository Structure

The `cpm-terraform-modules-monorepo` package repository must have its Makefile at the root:

```
cpm-terraform-modules-monorepo/
├── Makefile          # MUST be at root for glob pattern to find it
├── common.mk         # Optional: shared variables/functions
├── README.md
└── ...
```

**Why:** The root Makefile uses `-include $(PACKAGES_DIR)/*/Makefile` which expects each package's Makefile at `.packages/<package-name>/Makefile`. Nested Makefiles will not be automatically included.

**Shared Includes:** You can add `common.mk` or other `.mk` files at the package root for shared variables and functions. Include them in your Makefile with:

```makefile
include $(dir $(lastword $(MAKEFILE_LIST)))common.mk
```

## Usage

Module developers add the CPM Makefile to their module subdirectory:

```bash
cd providers/aws/primitives/s3
# Copy CPM Makefile from cpm/examples/example-make-task-runner/Makefile
make cpm-configure  # Syncs CPM packages
make test           # Uses package-provided targets
```

## Manifest Path

Use this manifest in your module's Makefile:

```makefile
REPO_MANIFESTS_PATH ?= repo-specs/terraform/caylent-terraform-modules-monorepo/modules/meta.xml
```

## Files

- `meta.xml` - Main manifest (includes remote and packages)
- `packages.xml` - Defines cpm-terraform-modules package
- `../git-connection/remote.xml` - Remote definition (shared across all manifests)

## Related Manifests

Caylent provides reference manifests for different development categories:
- `repo-specs/terraform/caylent-terraform-modules-monorepo/modules/` - This manifest (module subdirectories)
- `repo-specs/python/` - Python projects (future)
- `repo-specs/dotnet/` - .NET projects (future)
- `repo-specs/java/` - Java projects (future)
- `repo-specs/cdk/` - AWS CDK projects (future)

**Create your own:** Follow the [Contributing Guide](../../../../docs/contributing.md) to create manifests for your organization's repositories.
