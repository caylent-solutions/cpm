# Git Connection Manifest

Shared remote definitions used across all CPM manifests.

## Purpose

Defines the Git remote configurations that all CPM manifests reference. This allows centralized management of Git organizations used for cloning package repositories.

**Customization:** This example uses Caylent's public repositories. Create your own `remote.xml` pointing to your organization's Git repositories (GitHub, GitLab, Bitbucket, or self-hosted).

## Files

- `remote.xml` - Defines remotes for Caylent GitHub organizations

## Remote Definitions

```xml
<remote name="caylent-solutions" fetch="https://github.com/caylent-solutions/"/>
<remote name="caylent" fetch="https://github.com/caylent/"/>
```

**Available remotes:**
- `caylent-solutions` - https://github.com/caylent-solutions/
- `caylent` - https://github.com/caylent/

## Usage

All CPM manifests include this remote definition:

```xml
<manifest>
  <include name="repo-specs/git-connection/remote.xml" />
  <!-- ... project definitions ... -->
</manifest>
```

Projects specify which remote to use:

```xml
<project name="cpm-terraform-modules-monorepo"
         path=".packages/cpm-terraform-modules-monorepo"
         remote="caylent-solutions"
         revision="refs/tags/0.2.0"/>
```

## Adding Custom Remotes

To add your organization's remotes, extend or replace `remote.xml`:

```xml
<remote name="your-org" fetch="https://github.com/your-org/"/>
<remote name="internal" fetch="https://gitlab.internal.company.com/"/>
```

You can use any Git hosting provider: GitHub, GitLab, Bitbucket, Azure DevOps, or self-hosted Git servers.
