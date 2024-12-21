#!/usr/bin/env bash

#------------------------------------------------------------------------------
# env.sh
#
# Holds environment variables and paths that other scripts can reuse.
# Typically, this file is sourced by header.sh (which sets SCRIPT_DIR first).
#
# Exports:
#   TMP_FOLDER_NAME       : Name for temporary folder
#   BLOG_REPO_NAME        : Name of the blog repository
#   WP_ENV_PATH           : Path to the .env file within WordPress
#   WP_ENV_DIR            : Directory that holds WordPress environment config
#   GPG_PARAPHRASE_PATH   : Path to the user's GPG paraphrase file
#   list_of_files_to_delete : Array of files/directories to remove prior to deploy
#   PATH_TO_TMP_FOLDER    : Absolute path to the temporary folder
#   PATH_TO_BLOG_REPO     : Absolute path to the blog repository within the temp folder
#   PATH_TO_BLOG_ENV      : Absolute path to the blog environment config
#   PATH_TO_GITIGNORE_WPE : Absolute path to the WP Engine gitignore template
#   THIS_TIMESTAMP        : Current timestamp in the format "YYYY.MM.DD-HHMMSS"
#
# Author:  Wasseem Khayrattee
# GitHub:  https://github.com/wkhayrattee
#
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

# ------------------------------------------------------------------------------
# Paths that depend on SCRIPT_DIR (set in header.sh before env.sh is sourced)
# ------------------------------------------------------------------------------
export PATH_TO_TMP_FOLDER="${SCRIPT_DIR}/${TMP_FOLDER_NAME}"
export PATH_TO_BLOG_REPO="${PATH_TO_TMP_FOLDER}/${BLOG_REPO_NAME}"
export PATH_TO_BLOG_ENV="${PATH_TO_BLOG_REPO}/wp-content/app/config/"
export PATH_TO_GITIGNORE_WPE="${SCRIPT_DIR}/file_templates/gitignore_wpe"

# For a timestamp in the format "YYYY.MM.DD-HHMMSS"
export THIS_TIMESTAMP="$(date +"%Y.%m.%d-%H%M%S")"
