CPM_ENV_FILE = .cpmenv
-include $(CPM_ENV_FILE)

# This will always point here
REPO_MANIFESTS_URL ?= https://github.com/caylent-solutions/cpm.git

# Set this revision to a tag or branch
REPO_MANIFESTS_REVISION ?= refs/tags/1.0.0

# Set this equal to a meta manifest
REPO_MANIFESTS_PATH ?= manifests/terraform/modules/meta.xml

# Pull in Caylent Fork of (gerrit) repo utility that supports environment substitution:
REPO_URL ?= https://github.com/caylent-solutions/git-repo.git
REPO_REV ?= caylent-1.0.0
export REPO_REV REPO_URL

# Example variable to substituted after init, but before sync in repo manifests.
GITBASE ?= https://github.com/caylent-solutions/
export GITBASE

# Include project level defaults (env vars, etc.)
-include Makefile.includes

# Set to true in a pipeline context
IS_PIPELINE ?= false

JOB_NAME ?= job
JOB_EMAIL ?= job@job.job

PACKAGES_DIR = packages
-include $(PACKAGES_DIR)/Makefile

MODULE_DIR ?= ${PACKAGES_DIR}/module

REPO_INSTALLED = $(shell which repo > /dev/null 2>&1; echo $$?)

.PHONY: configure
configure:
ifeq ($(REPO_INSTALLED), 0)
	echo n | repo --color=never init --no-repo-verify \
		-u "$(REPO_MANIFESTS_URL)" \
		-b "$(REPO_MANIFESTS_REVISION)" \
		-m "$(REPO_MANIFESTS_PATH)"
	repo sync
else
	$(error Missing Repo, which is required for CPM sync. Install Repo and rerun.)
endif

# The first line finds and removes all the directories pulled in by repo
# The second line finds and removes all the broken symlinks from removing things
# https://stackoverflow.com/questions/42828021/removing-files-with-rm-using-find-and-xargs
.PHONY: clean
clean:
	-repo list | awk '{ print $$1; }' | cut -d '/' -f1 | uniq | xargs rm -rf
	find . -type l ! -exec test -e {} \; -print | xargs rm -rf

.PHONY: init-clean
init-clean:
	rm -rf .git
	git init --initial-branch=main
ifneq (,$(wildcard ./TEMPLATED_README.md))
	mv TEMPLATED_README.md README.md
endif
