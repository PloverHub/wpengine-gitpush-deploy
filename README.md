# WP Engine Deployment Scripts

A structured Bash + Makefile toolkit for automating WordPress deployments to WP Engine environments. It includes environment bootstrapping, repository preparation (Composer, cleanup), and Git pushing to environment-specific remotes. Configuration is centralized in `config/env.sh`.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Requirements](#requirements)
4. [Setup](#setup)
5. [Configuration](#configuration)
6. [Usage](#usage)
7. [GPG Workflow (Optional)](#gpg-workflow-optional)
8. [Optional Bash Aliases](#optional-bash-aliases)
9. [Contributing](#contributing)
10. [License](#license)
11. [Changelog](#changelog)

---

## Introduction

This repository provides a robust and reusable set of scripts to manage WordPress deployments to WP Engine. Instead of manually coordinating Git commands and Composer actions, use structured Make targets and Bash tasks to deploy to `dev`, `stag`, or `prod`.

---

## Project Structure

```bash
.
├── Makefile                  # Task-based CLI entry point
├── config/
│   ├── env.sh                # Project-specific settings
│   └── example.env.sh        # Template for new projects
├── deploy/
│   ├── deploy.sh             # Main script: init, prep, push, deploy
│   ├── header.sh             # Strict-mode, path detection, config loader
│   └── file_templates/
│       └── gitignore_wpe     # Gitignore template for WP Engine
├── README.md
├── LICENSE
└── CHANGELOG.md
```

---

## Requirements

* Bash (or Zsh)
* Git
* Composer
* GPG (optional)
* WP Engine Git access

---

## Setup

1. Clone this repo:

   ```bash
   git clone git@github.com:PloverHub/wpengine-gitpush-deploy.git
   cd yourrepo
   ```

2. Copy and configure your environment:

   ```bash
   cp config/example.env.sh config/env.sh
   ```

   Edit `config/env.sh` with your actual repo and WP Engine remotes.

3. Make sure scripts are executable:

   ```bash
   chmod +x deploy/*.sh
   ```

---

## Configuration

Edit `config/env.sh` and fill in your project-specific values:

```bash
export BLOG_GIT_REPO="git@github.com:YOURORG/YOURPROJECT.git"
export WPE_GIT_DEV="git@git.wpengine.com:production/dev-repo.git"
export WPE_SSH_DEV="ssh user@dev.ssh.wpengine.net"
...
export RUN_GPG_DECRYPT="true"
```

Also define the list of files to delete before deploying.

---

## Usage

Run all deployment tasks via Make:

```bash
make dev init        # Clone repo and (optionally) decrypt .env
make dev prep        # Composer install + file cleanup
make dev push        # Git remote setup + push

## OR just:

make dev deploy      # Full init + prep + push
```

Replace `dev` with `stag` or `prod` as needed.

---

## GPG Workflow (Optional)

If your `.env` files are GPG-encrypted, you can enable decryption:

### 1. Enable it in `env.sh`:

```bash
export RUN_GPG_DECRYPT="true"
```

### 2. Place encrypted envs:

```bash
wp-content/app/config/env_dev.gpg
wp-content/app/config/env_stag.gpg
wp-content/app/config/env_prod.gpg
```

### 3. Provide your GPG passphrase file:

```bash
~/.paraphrase_gpg
```

The script will automatically:

* Detect the environment (dev/stag/prod)
* Decrypt `env_<ENV>.gpg`
* Output it to the configured `WP_ENV_PATH`

> Make sure GPG is installed and configured properly with your keypair.

---

## Optional Bash Aliases

```bash
alias wpe.prod="make prod deploy"
alias wpe.stag="make stag deploy"
alias wpe.dev="make dev deploy"
```

Reload shell:

```bash
source ~/.zshrc  # or ~/.bashrc
```

---

## Contributing

1. Fork the repo
2. Create a branch: `feature/my-change`
3. Use Conventional Commits
4. Submit a pull request

---

## License

See [LICENSE](LICENSE)

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md)
