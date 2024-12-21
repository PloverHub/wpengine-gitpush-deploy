#!/usr/bin/env bash
#
# deploy.sh - A Bash adaptation of the Python Fabric script
#             for deploying a WordPress blog to WP Engine.
#
# Usage:
#   ./deploy.sh <environment> <task>
#
# Environments: dev, stag, prod
#
# Tasks:
#   readme  - Prints overview
#   init    - Sets up the tmp folder, clones the blog repo from $BLOG_GIT_REPO,
#             optionally decrypts .env
#   push    - Prepares the local repo (branch, composer, file cleanup) and
#             pushes to WP Engine
#   deploy  - A convenience task combining 'init' + 'push' in one go
#
# Examples:
#   ./deploy.sh dev readme
#   ./deploy.sh dev init
#   ./deploy.sh dev push
#   ./deploy.sh dev deploy
#
# Note: The GitHub repo is NOT passed as an argument. Instead, it is
#       taken from BLOG_GIT_REPO set in env.sh.
#
# Author:  Wasseem Khayrattee
# GitHub:  https://github.com/wkhayrattee
#------------------------------------------------------------------------------

###############################################################################
# 1. Maximum portability: detect shell, define SCRIPT_DIR, source header.sh
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
# 2. Parse arguments: <environment> <task>
###############################################################################
ENVIRONMENT="${1:-}"
TASK="${2:-}"

if [[ -z "$ENVIRONMENT" || -z "$TASK" ]]; then
  echo "[Error] Not enough arguments!"
  echo "Usage: $0 <environment> <task>"
  echo "Where <environment> is one of: dev, stag, prod"
  echo "      <task> is one of: readme, init, push, deploy"
  exit 1
fi

###############################################################################
# 3. Configure environment (dev, stag, prod)
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
# 4. Define Functions ("tasks")
###############################################################################

#------------------------------------------------------------------------------
# 4.1 readme() - Prints an overview including all tasks
#------------------------------------------------------------------------------
function readme() {
  echo "--------------------------------------------------------------------------------"
  echo "TASKS AVAILABLE:"
  echo "   1) readme"
  echo "   2) init"
  echo "   3) push"
  echo "   4) deploy (runs init + push in one shot)"
  echo
  echo "Usage examples:"
  echo "  ./deploy.sh dev readme"
  echo "  ./deploy.sh dev init"
  echo "  ./deploy.sh dev push"
  echo "  ./deploy.sh dev deploy"
  echo
  echo "NOTE: The Git repo is set in env.sh as BLOG_GIT_REPO. It is not passed as an argument."
  echo
  echo "LONG INTRO: The sequence for a deploy is typically as follows:"
  echo "  1) Clone the blog repo into a tmp folder (via 'init')"
  echo "  2) Create a branch with a timestamp, run composer, remove unwanted files (via 'push')"
  echo "  3) Add WP Engine remote + commit + push"
  echo
  echo "If you want to do everything in one shot, just run 'deploy' for a quick command."
  echo "--------------------------------------------------------------------------------"
}

#------------------------------------------------------------------------------
# 4.2 init() - Prepares tmp folder, clones blog repo from $BLOG_GIT_REPO,
#              optionally decrypts .env if RUN_GPG_DECRYPT=true
#------------------------------------------------------------------------------
function init() {
  # Ensure BLOG_GIT_REPO is defined in env.sh
  if [[ -z "${BLOG_GIT_REPO}" ]]; then
    echo "[Error] BLOG_GIT_REPO not defined in env.sh"
    exit 1
  fi

  echo "--------------------------------------------------------------------------------"
  echo "[INIT] Removing any previous '${TMP_FOLDER_NAME}' folder..."
  rm -rf "${TMP_FOLDER_NAME}"

  echo "[INIT] Creating '${TMP_FOLDER_NAME}' folder..."
  mkdir -p "${TMP_FOLDER_NAME}"

  echo "[INIT] Cloning blog repo from: ${BLOG_GIT_REPO}"
  (
    cd "${TMP_FOLDER_NAME}" || exit 1
    rm -rf "${BLOG_REPO_NAME}"
    git clone "${BLOG_GIT_REPO}" "${BLOG_REPO_NAME}"
  )

  # Conditionally decrypt .env
  if [[ "${RUN_GPG_DECRYPT}" == "true" ]]; then
    echo "[INIT] RUN_GPG_DECRYPT=true; proceeding to decrypt .env..."
    decrypt_env_inside_deploy_folder
    echo "[INIT] Done decrypting .env!"
  else
    echo "[INIT] RUN_GPG_DECRYPT=false; skipping .env decryption..."
  fi

  # Check existence of .env
  local env_file="${PATH_TO_BLOG_REPO}/${WP_ENV_PATH}"
  if [[ -f "$env_file" ]]; then
    echo "[INIT] Found .env: $env_file"
  else
    echo "[Warning] .env file not found at $env_file"
  fi

  echo "[INIT] init() completed."
  echo "--------------------------------------------------------------------------------"
}

#------------------------------------------------------------------------------
# 4.3 push() - Prepares the local repo (branch, composer, file cleanup) + push
#------------------------------------------------------------------------------
function push() {
  echo "--------------------------------------------------------------------------------"
  echo "[PUSH] Checking out new branch wpe-${APP_ENV}-${THIS_TIMESTAMP}..."
  (
    cd "${PATH_TO_BLOG_REPO}" || exit 1
    git branch "wpe-${APP_ENV}-${THIS_TIMESTAMP}"
    git checkout "wpe-${APP_ENV}-${THIS_TIMESTAMP}"
  )

  sub_prep_repo
  set_upstream
  perform_gitpush

  echo "[PUSH] Done!"
  echo "--------------------------------------------------------------------------------"
}

#------------------------------------------------------------------------------
# 4.4 deploy() - A one-step command that calls init + push
#------------------------------------------------------------------------------
function deploy() {
  echo "--------------------------------------------------------------------------------"
  echo "[DEPLOY] Doing full init + push"
  init
  push
  echo "[DEPLOY] Done."
  echo "--------------------------------------------------------------------------------"
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
    cd "${PATH_TO_BLOG_REPO}" || exit 1
    sudo composer update --no-dev --optimize-autoloader --prefer-dist -vv
  )
}

function update_files_on_blog_repo() {
  echo "[SUB] Updating .gitignore with ${PATH_TO_GITIGNORE_WPE}"
  (
    cd "${PATH_TO_TMP_FOLDER}" || exit 1
    rm -f "${BLOG_REPO_NAME}/.gitignore"
    cp -f "${PATH_TO_GITIGNORE_WPE}" "${BLOG_REPO_NAME}/.gitignore"
    echo "[SUB] Creating/updating deploy-seed file"
    touch "${BLOG_REPO_NAME}/deploy-seed"
    echo "wpe-${APP_ENV}-${THIS_TIMESTAMP}" >> "${BLOG_REPO_NAME}/deploy-seed"
  )
}

function remove_ignored_files() {
  echo "[SUB] Removing unwanted files..."
  (
    cd "${PATH_TO_BLOG_REPO}" || exit 1
    for item in "${list_of_files_to_delete[@]}"; do
      echo " - Removing: ${item}"
      sudo rm -rf "${item}"
    done
  )
}

function set_upstream() {
  echo "[SUB] Setting WP Engine upstream: ${WPE_GIT_BRANCH} -> ${WPE_GIT}"
  (
    cd "${PATH_TO_BLOG_REPO}" || exit 1
    git remote remove "${WPE_GIT_BRANCH}" 2>/dev/null || true
    git remote add "${WPE_GIT_BRANCH}" "${WPE_GIT}"
    git remote -v
  )
}

function perform_gitpush() {
  echo "[SUB] Committing and pushing to WP Engine..."
  (
    cd "${PATH_TO_BLOG_REPO}" || exit 1
    git add -A
    git commit -m "deploy - wpe-${APP_ENV}-${THIS_TIMESTAMP}"
    git push "${WPE_GIT_BRANCH}" --force
  )
}

###############################################################################
# 6. GPG Decryption - Conditionally Called in init()
###############################################################################
function decrypt_env_inside_deploy_folder() {
  echo "[SUB] Decrypting .env for environment: ${APP_ENV}"
  # Example placeholder command; update as needed:
  # gpg --quiet --batch --yes --passphrase-file "${GPG_PARAPHRASE_PATH}" \
  #     --decrypt --output "${PATH_TO_BLOG_REPO}/${WP_ENV_PATH}" \
  #     "${PATH_TO_BLOG_REPO}/${WP_ENV_DIR}/env_${APP_ENV}.gpg"
  echo "   (Simulation) Decryption complete, check ${PATH_TO_BLOG_REPO}/${WP_ENV_PATH}"
}

###############################################################################
# 7. Run the requested task
###############################################################################
case "$TASK" in
  readme)
    readme
    ;;
  init)
    init
    ;;
  push)
    push
    ;;
  deploy)
    deploy
    ;;
  *)
    echo "[Error] Unknown task: $TASK"
    echo "Valid tasks: readme, init, push, deploy"
    exit 1
    ;;
esac
