#!/usr/bin/env bash

#------------------------------------------------------------------------------
# env.sh
#
# Holds environment variables and paths that other scripts can reuse.
# Typically, this file is sourced by header.sh (which sets SCRIPT_DIR first).
#
# Exports:
#   TMP_FOLDER_NAME         : Temporary folder name
#   BLOG_REPO_NAME          : Name of the blog repository
#   WP_ENV_PATH             : Path to the .env file within WordPress
#   WP_ENV_DIR              : Directory that holds WordPress environment config
#   GPG_PARAPHRASE_PATH     : Path to the user's GPG paraphrase file
#   list_of_files_to_delete : Array of files/directories to remove prior to deploy
#   PATH_TO_TMP_FOLDER      : Absolute path to the temporary folder
#   PATH_TO_BLOG_REPO       : Absolute path to the blog repository within the temp folder
#   PATH_TO_BLOG_ENV        : Absolute path to the blog environment config
#   PATH_TO_GITIGNORE_WPE   : Absolute path to the WP Engine gitignore template
#   THIS_TIMESTAMP          : Current timestamp in the format "YYYY.MM.DD-HHMMSS"
#   BLOG_GIT_REPO           : GitHub repository URL (placeholder)
#   WPE_GIT_DEV/STAG/PROD   : WP Engine Git repo URLs (placeholders)
#   WPE_SSH_DEV/STAG/PROD   : WP Engine SSH credentials (placeholders)
#
# Author:  Wasseem Khayrattee
# GitHub:  https://github.com/wkhayrattee
#
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# GITHUB & WP ENGINE REPOSITORY/SSH PLACEHOLDERS
#------------------------------------------------------------------------------
# TODO: Adjust these values to match your own GitHub & WP Engine environments.
## Your Project's Git repo
export BLOG_GIT_REPO="git@github.com:YOURORG/YOURPROJECT.git"
## WP Engine Git repos - DEV, STAG, PROD
export WPE_GIT_DEV="git@git.wpengine.com:production/ENVdevblog.git"
export WPE_GIT_STAG="git@git.wpengine.com:production/ENVstag.git"
export WPE_GIT_PROD="git@git.wpengine.com:production/ENVprod.git"
## WP Engine SSH credentials - DEV, STAG, PROD
export WPE_SSH_DEV="ssh ENVdevblog@ENVdevblog.ssh.wpengine.net"
export WPE_SSH_STAG="ssh ENVstag@ENVstag.ssh.wpengine.net"
export WPE_SSH_PROD="ssh ENVprod@ENVprod.ssh.wpengine.net"

#------------------------------------------------------------------------------
# BASIC VARIABLES
#------------------------------------------------------------------------------
export TMP_FOLDER_NAME='tmp'
export BLOG_REPO_NAME='wpblog'
export WP_ENV_PATH='wp-content/app/config/.env'
export WP_ENV_DIR='wp-content/app/config/'
export GPG_PARAPHRASE_PATH="$HOME/.paraphrase_gpg"

# Array of items to delete before deployment
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
# DEPENDENT PATHS (Require SCRIPT_DIR from header.sh)
#------------------------------------------------------------------------------
export PATH_TO_TMP_FOLDER="${SCRIPT_DIR}/${TMP_FOLDER_NAME}"
export PATH_TO_BLOG_REPO="${PATH_TO_TMP_FOLDER}/${BLOG_REPO_NAME}"
export PATH_TO_BLOG_ENV="${PATH_TO_BLOG_REPO}/wp-content/app/config/"
export PATH_TO_GITIGNORE_WPE="${SCRIPT_DIR}/file_templates/gitignore_wpe"

# For a timestamp in the format "YYYY.MM.DD-HHMMSS"
export THIS_TIMESTAMP="$(date +"%Y.%m.%d-%H%M%S")"
