# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.1.0] - 2025-06-27

### Refactored

* Restructured project folders for better modularity:

    * Moved `deploy.sh` and `header.sh` into a new `deploy/` directory.
    * Moved `env.sh` into a new `config/` directory.
* Updated all internal script references and paths to reflect new structure.
* Refactored `push` task into discrete steps (`prep`, `set_upstream`, `perform_gitpush`).
* Introduced `prepare_repo_before_push()` for cleaner task orchestration.
* Simplified `deploy` to call `init`, `prep`, and `push` in sequence.

### Added

* `Makefile` for environment-first command dispatch via `make dev init`, `make stag deploy`, etc.
* `config/example.env.sh` template for safe onboarding and version control.
* GPG decryption support workflow documentation in README.
* Automatic `.env` decryption (via GPG) controlled by `RUN_GPG_DECRYPT`.
* Task dispatcher now includes new `prep` task for pre-push repo preparation.

### Updated

* `README.md` to reflect new structure, new Makefile usage, and GPG steps.
* `env.sh` to support new `SCRIPT_DIR` structure without requiring path rewrites.
* `header.sh` to locate and load `config/env.sh` safely from project root.

---

## [1.0.0] - 2024-12-21

### Added

* Initial `deploy.sh` script to handle WP Engine deployments.
* `env.sh` file for environment variable configurations.
* `header.sh` script to set strict mode and source `env.sh`.
* `file_templates/gitignore_wpe` for recommended WP Engine `.gitignore` rules.
* Documentation in `README.md` for usage and setup instructions.
