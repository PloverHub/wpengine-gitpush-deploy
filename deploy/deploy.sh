#!/usr/bin/env bash
#
# deploy.sh - A Bash script for deploying a WordPress blog to WP Engine using GIT PUSH
#
# Usage:
#   ./deploy.sh <environment> <task>
#
# Environments: dev, stag, prod
#
# Tasks:
#   init    - Sets up the tmp folder, clones the blog repo from $BLOG_GIT_REPO,
#             optionally decrypts .env
#   prep    - Prepares the repo: composer + clean up
#   push    - Sets remote and force pushes to WP Engine
#   deploy  - Combines init + prep + push
#
# Note: BLOG_GIT_REPO is sourced from config/env.sh
#
# Author:  Wasseem Khayrattee
# GitHub:  https://github.com/wkhayrattee
#------------------------------------------------------------------------------

###############################################################################
# 1. Detect script directory and load bootstrap header
###############################################################################
if [ -n "$BASH_VERSION" ]; then
  SCRIPT_SOURCE="${BASH_SOURCE[0]}"
elif [ -n "$ZSH_VERSION" ]; then
  SCRIPT_SOURCE="$0"
else
  SCRIPT_SOURCE="$0"
fi

SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd -P)"
source "${SCRIPT_DIR}/header.sh"

###############################################################################
# 2. Parse arguments
###############################################################################
ENVIRONMENT="${1:-}"
TASK="${2:-}"

if [[ -z "$ENVIRONMENT" || -z "$TASK" ]]; then
  echo "[Error] Not enough arguments!"
  echo "Usage: $0 <environment> <task>"
  echo "Where <environment> is one of: dev, stag, prod"
  echo "      <task> is one of: init, prep, push, deploy"
  exit 1
fi

###############################################################################
# 3. Configure environment
###############################################################################
case "$ENVIRONMENT" in
  dev)
    echo "[INFO] Setting environment to DEV"
    APP_ENV="dev"
    WPE_GIT_BRANCH="development"
    WPE_GIT="${WPE_GIT_DEV}"
    WPE_SSH="${WPE_SSH_DEV}"
    ;;
  stag)
    echo "[INFO] Setting environment to STAG"
    APP_ENV="stag"
    WPE_GIT_BRANCH="staging"
    WPE_GIT="${WPE_GIT_STAG}"
    WPE_SSH="${WPE_SSH_STAG}"
    ;;
  prod)
    echo "[INFO] Setting environment to PROD"
    APP_ENV="prod"
    WPE_GIT_BRANCH="production"
    WPE_GIT="${WPE_GIT_PROD}"
    WPE_SSH="${WPE_SSH_PROD}"
    ;;
  *)
    echo "[Error] Invalid environment: $ENVIRONMENT"
    echo "Use one of: dev, stag, prod"
    exit 1
    ;;
esac

###############################################################################
# 4. Define Task Functions
###############################################################################

function init() {
  if [[ -z "${BLOG_GIT_REPO}" ]]; then
    echo "[Error] BLOG_GIT_REPO not defined in env.sh"
    exit 1
  fi

  print_separator
  echo "[INIT] Removing any previous '${TMP_FOLDER_NAME}' folder..."
  rm -rf "${TMP_FOLDER_NAME}"

  echo "[INIT] Creating '${TMP_FOLDER_NAME}' folder..."
  mkdir -p "${TMP_FOLDER_NAME}"

  echo "[INIT] Cloning blog repo from: ${BLOG_GIT_REPO}"
  (
    safe_cd "${TMP_FOLDER_NAME}"
    rm -rf "${BLOG_REPO_NAME}"
    git clone "${BLOG_GIT_REPO}" "${BLOG_REPO_NAME}"
  )

  if [[ "${RUN_GPG_DECRYPT}" == "true" ]]; then
    echo "[INIT] RUN_GPG_DECRYPT=true; proceeding to decrypt .env..."
    decrypt_env_inside_deploy_folder
    echo "[INIT] Done decrypting .env!"
  else
    echo "[INIT] RUN_GPG_DECRYPT=false; skipping .env decryption..."
  fi

  local env_file="${PATH_TO_BLOG_REPO}/${WP_ENV_PATH}"
  if [[ -f "$env_file" ]]; then
    echo "[INIT] Found .env: $env_file"
  else
    echo "[Warning] .env file not found at $env_file"
  fi

  echo "[INIT] init() completed."
  print_separator
}

function prepare_repo_before_push() {
  print_separator
  echo "[PREP] Preparing repo before push..."

  echo "[PREP] Checking out new branch: wpe-${APP_ENV}-${THIS_TIMESTAMP}"
  (
    safe_cd "${PATH_TO_BLOG_REPO}"
    git branch "wpe-${APP_ENV}-${THIS_TIMESTAMP}"
    git checkout "wpe-${APP_ENV}-${THIS_TIMESTAMP}"
  )

  sub_prep_repo
  echo "[PREP] Repo preparation complete."
  print_separator
}

function push() {
  print_separator
  echo "[PUSH] Starting push sequence..."
  set_upstream
  perform_gitpush
  echo "[PUSH] Push complete."
  print_separator
}

function deploy() {
  print_separator
  echo "[DEPLOY] Doing full init + prep + push"
  init
  prepare_repo_before_push
  push
  echo "[DEPLOY] Done."
  print_separator
}

###############################################################################
# 5. Subtasks
###############################################################################

function sub_prep_repo() {
  do_composer_install
  update_files_on_blog_repo
  remove_ignored_files
}

function do_composer_install() {
  echo "[SUB] Running Composer install..."
  (
    safe_cd "${PATH_TO_BLOG_REPO}"
    composer update --no-dev --optimize-autoloader --prefer-dist --no-interaction --no-progress -vv
  )
}

function update_files_on_blog_repo() {
  echo "[SUB] Updating .gitignore with ${PATH_TO_GITIGNORE_WPE}"
  (
    safe_cd "${PATH_TO_TMP_FOLDER}"
    rm -f "${BLOG_REPO_NAME}/.gitignore"
    cp -f "${PATH_TO_GITIGNORE_WPE}" "${BLOG_REPO_NAME}/.gitignore"
    touch "${BLOG_REPO_NAME}/deploy-seed"
    echo "wpe-${APP_ENV}-${THIS_TIMESTAMP}" >> "${BLOG_REPO_NAME}/deploy-seed"
  )
}

function remove_ignored_files() {
  echo "[SUB] Removing unwanted files..."
  (
    safe_cd "${PATH_TO_BLOG_REPO}"
    if [[ ${#list_of_files_to_delete[@]} -eq 0 ]]; then
      echo "[Warning] Nothing to delete - list_of_files_to_delete is empty."
    else
      for item in "${list_of_files_to_delete[@]}"; do
        echo " - Removing: ${item}"
        rm -rf "${item}"
      done
    fi
  )
}

function set_upstream() {
  echo "[SUB] Setting WP Engine upstream: ${WPE_GIT_BRANCH} -> ${WPE_GIT}"
  (
    safe_cd "${PATH_TO_BLOG_REPO}"
    git remote remove "${WPE_GIT_BRANCH}" 2>/dev/null || true
    git remote add "${WPE_GIT_BRANCH}" "${WPE_GIT}"
    git remote -v
  )
}

function perform_gitpush() {
  echo "[SUB] Committing and pushing to WP Engine..."
  (
    safe_cd "${PATH_TO_BLOG_REPO}"
    git add -A
    git commit -m "deploy - wpe-${APP_ENV}-${THIS_TIMESTAMP}"
    git push "${WPE_GIT_BRANCH}" --force
  )
}

###############################################################################
# 6. GPG Decryption
###############################################################################

function decrypt_env_inside_deploy_folder() {
  echo "[SUB] Decrypting .env for environment: ${APP_ENV}"
  gpg --quiet --batch --yes --passphrase-file "${GPG_PARAPHRASE_PATH}" \
      --decrypt --output "${PATH_TO_BLOG_REPO}/${WP_ENV_PATH}" \
      "${PATH_TO_BLOG_REPO}/${WP_ENV_DIR}/env_${APP_ENV}.gpg"
  echo "   (Simulation) Decryption complete, check ${PATH_TO_BLOG_REPO}/${WP_ENV_PATH}"
}

###############################################################################
# 7. Task Dispatcher
###############################################################################
case "$TASK" in
  init)
    init
    ;;
  prep)
    prepare_repo_before_push
    ;;
  push)
    push
    ;;
  deploy)
    deploy
    ;;
  *)
    echo "[Error] Unknown task: $TASK"
    echo "Valid tasks: init, prep, push, deploy"
    exit 1
    ;;
esac
