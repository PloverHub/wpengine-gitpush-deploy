#!/usr/bin/env bash

#------------------------------------------------------------------------------
# config/env.sh
#
# Project-specific configuration used during WP Engine deploy.
# Loaded by deploy/header.sh (which defines SCRIPT_DIR and PROJECT_ROOT).
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# GITHUB & WP ENGINE REPOSITORY/SSH PLACEHOLDERS
#------------------------------------------------------------------------------
# Adjust these per project
export BLOG_GIT_REPO="git@github.com:YOURORG/YOURPROJECT.git"

export WPE_GIT_DEV="git@git.wpengine.com:production/ENVdevblog.git"
export WPE_GIT_STAG="git@git.wpengine.com:production/ENVstag.git"
export WPE_GIT_PROD="git@git.wpengine.com:production/ENVprod.git"

export WPE_SSH_DEV="ssh ENVdevblog@ENVdevblog.ssh.wpengine.net"
export WPE_SSH_STAG="ssh ENVstag@ENVstag.ssh.wpengine.net"
export WPE_SSH_PROD="ssh ENVprod@ENVprod.ssh.wpengine.net"

# Enable or disable GPG decryption
export RUN_GPG_DECRYPT="false"

#------------------------------------------------------------------------------
# BASIC STRUCTURE
#------------------------------------------------------------------------------
export TMP_FOLDER_NAME="tmp"
export BLOG_REPO_NAME="wpblog"

# Relative to blog repo root
export WP_ENV_PATH="wp-content/app/config/.env"
export WP_ENV_DIR="wp-content/app/config/"
export GPG_PARAPHRASE_PATH="$HOME/.paraphrase_gpg"

# Files to delete before deploying
export list_of_files_to_delete=(
  "composer.json"
  "composer.lock"
  "meta"
  "bin"
  "deploy"
  ".php_cs"
  ".php_cs.cache"
  "README.md"
  "CHANGELOG.md"
  "LICENSE.md"
  "license.txt"
  "readme.html"
  "wp-content/app/config/*.gpg"
  "wp-content/app/config/test_env"
)

#------------------------------------------------------------------------------
# PATHS — Require SCRIPT_DIR from header.sh
#------------------------------------------------------------------------------
export PATH_TO_TMP_FOLDER="${SCRIPT_DIR}/${TMP_FOLDER_NAME}"
export PATH_TO_BLOG_REPO="${PATH_TO_TMP_FOLDER}/${BLOG_REPO_NAME}"
export PATH_TO_BLOG_ENV="${PATH_TO_BLOG_REPO}/wp-content/app/config/"
export PATH_TO_GITIGNORE_WPE="${SCRIPT_DIR}/file_templates/gitignore_wpe"

# Timestamp (e.g., 2025.06.27-120501)
export THIS_TIMESTAMP="$(date +"%Y.%m.%d-%H%M%S")"
