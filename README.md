# WP Engine Deployment Scripts

A set of Bash scripts for automating WordPress deployments to WP Engine environments. These scripts encapsulate cloning the blog repository, preparing code (composer install, cleaning unneeded files), and pushing to WP Engine’s Git remote. Configuration details (repository URLs, environment settings, etc.) are managed via `env.sh`.

---

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Requirements](#requirements)
4. [Setup](#setup)
5. [Configuration](#configuration)
6. [Usage](#usage)
7. [Optional Bash Aliases](#optional-bash-aliases)
8. [Contributing](#contributing)
9. [License](#license)
10. [Changelog](#changelog)

---

## Introduction

This repository provides a convenient way to manage WordPress deployment flows to WP Engine. Instead of manually copying files or running multiple Git commands, you can simply execute one or two shell commands to prepare and push your code to the desired WP Engine environment (dev, staging, or production).

---

## Project Structure

```bash
. ├── LICENSE 
  ├── README.md <-- You are here! 
  ├── deploy.sh <-- Main deployment script (tasks: readme, init, push, deploy) 
  ├── env.sh <-- Environment variables and paths 
  ├── file_templates 
  │ └── gitignore_wpe 
  └── header.sh <-- Shared script header (strict mode, script directory, env sourcing)
```


1. **`deploy.sh`**
    - The main script containing tasks for deployment (`init`, `push`, `deploy`, etc.).

2. **`env.sh`**
    - Defines environment variables (e.g., `BLOG_GIT_REPO`, `WPE_GIT_DEV/STAG/PROD`) and the list of files to delete before deploy.

3. **`header.sh`**
    - Sets script modes (`set -euo pipefail`), computes script directory, and sources `env.sh`.

4. **`file_templates/gitignore_wpe`**
    - A recommended `.gitignore` for WP Engine, helping to exclude unnecessary or restricted files from your repository.

---

## Requirements

- **Bash or Zsh** on macOS/Linux (Windows users can use Git Bash or WSL).
- **Git** installed.
- **Composer** installed (if you want to use the composer-related steps).
- **GPG** installed (only if you need to decrypt `.env` with GPG, controlled by `RUN_GPG_DECRYPT`).
- **WP Engine** account and git credentials set up.

---

## Setup

1. **Clone or download** this repository to a local folder.
2. **Make scripts executable** (if needed):
   ```bash
   chmod +x deploy.sh
   chmod +x header.sh
    ```
3. Edit env.sh:
  - Set BLOG_GIT_REPO="git@github.com:YOURORG/YOURPROJECT.git".
  - Configure the WP Engine Git repos (WPE_GIT_DEV, WPE_GIT_STAG, WPE_GIT_PROD) and SSH credentials (WPE_SSH_DEV, etc.).
  - Set RUN_GPG_DECRYPT="true" if you want the script to decrypt .env files using GPG (otherwise set it to false).

---

## Configuration

Inside `env.sh`, you’ll find variables like:

```bash
export BLOG_GIT_REPO="git@github.com:YOURORG/YOURPROJECT.git"
export WPE_GIT_DEV="git@git.wpengine.com:production/dev-branch.git"
export WPE_GIT_STAG="git@git.wpengine.com:production/stag-branch.git"
export WPE_GIT_PROD="git@git.wpengine.com:production/prod-branch.git"

export RUN_GPG_DECRYPT="true"
# ...
```

- `BLOG_GIT_REPO`: The GitHub repository containing your WordPress code.
- `WPE_GIT_DEV/STAG/PROD`: WP Engine Git endpoints for Dev, Staging, and Production.
- `RUN_GPG_DECRYPT`: Set true to decrypt .env files using GPG, or false to skip.

Additionally, you’ll see list_of_files_to_delete=() where you can specify files/directories to remove prior to deployment.

---

## Usage

1. Change to the project directory:
    ```bash
    cd /path/to/this-repo
    ```
2. Basic commands:
    - **`./deploy.sh dev readme`**: Displays usage instructions and an overview.
    - **`./deploy.sh dev init`**: Clones your `$BLOG_GIT_REPO` into a tmp folder and optionally decrypts `.env`.
    - **`./deploy.sh dev push`**: Creates a new timestamped branch, runs Composer, removes unwanted files, and pushes to WP Engine’s dev environment.
    - **`./deploy.sh dev deploy`**: Runs `init` + `push` in one go, for a seamless single command deployment.
3. Environments:
    - Replace dev with `stag` or `prod` for staging or production respectively.
    - Make sure your env.sh variables match the correct environment Git endpoints (e.g., `$WPE_GIT_STAG`, `$WPE_GIT_PROD`).
4. Logs & Debug:
    - The script outputs each step to the console.
    - If something goes wrong, check the console output or examine logs on WP Engine’s side.

---

## Optional Bash Aliases

If you find yourself running these commands frequently, you can add aliases to your shell configuration. For example, in `~/.bash_aliases` or `~/.zshrc`:

```bash
alias wpe.deploy="./deploy.sh"
alias wpe.deploy.prod="./deploy.sh prod deploy"
alias wpe.deploy.stag="./deploy.sh stag deploy"
```

- `wpe.deploy`: Aliases directly to the deploy.sh script, so you can run `wpe.deploy dev readme` instead of `./deploy.sh dev readme`.
- `wpe.deploy.prod`: Runs the entire process (init + push) for the production environment in one command.
- `wpe.deploy.stag`: Same but for staging.

After adding these lines, reload your shell:
```bash
source ~/.bashrc   # or ~/.zshrc, depending on your shell
```

Now you can do:
```bash
wpe.deploy.prod
```
instead of typing out the full `./deploy.sh prod deploy`.

---

## Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/some-improvement`).
3. Commit your changes with a [Conventional Commits](https://www.conventionalcommits.org/) style message.
4. Push to your fork and submit a pull request.

Feel free to open issues or suggestions for improvements.

---

## License

Check [the license file](LICENSE) in this repository for details.

---

## Changelog

See [the changelog file](CHANGELOG.md) for details.
