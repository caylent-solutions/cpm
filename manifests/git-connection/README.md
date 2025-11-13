# Git Connection Manifest

Shared remote definitions used across all CPM manifests.

## Purpose

Defines the Git remote configurations that all CPM manifests reference. This allows centralized management of Git organizations used for cloning package repositories.

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
  <include name="manifests/git-connection/remote.xml" />
  <!-- ... project definitions ... -->
</manifest>
```

Projects specify which remote to use:

```xml
<project name="cpm-terraform-modules-monorepo"
         path=".packages/modules"
         remote="caylent-solutions"
         revision="refs/tags/0.1.5"/>
```

## Adding Custom Remotes

To add client or custom organization remotes, extend `remote.xml`:

```xml
<remote name="client-org" fetch="https://github.com/acme-corp/"/>
```
