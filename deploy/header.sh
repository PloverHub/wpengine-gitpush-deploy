#!/usr/bin/env bash
#
#------------------------------------------------------------------------------
# header.sh
#
# Shared bootstrap logic for deployment scripts.
#------------------------------------------------------------------------------

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Determine the directory of this script (i.e., deploy/)
if [ -n "$BASH_VERSION" ]; then
  SCRIPT_SOURCE="${BASH_SOURCE[0]}"
elif [ -n "$ZSH_VERSION" ]; then
  SCRIPT_SOURCE="$0"
else
  SCRIPT_SOURCE="$0"
fi

SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"

# Source env.sh from config/
if [[ -f "${PROJECT_ROOT}/config/env.sh" ]]; then
  source "${PROJECT_ROOT}/config/env.sh"
else
  echo "[Error] Missing config/env.sh. Please copy config/example.env.sh and customize it." >&2
  exit 1
fi

# Optional: cd into deploy directory for consistency (optional — can remove if not needed)
cd "${SCRIPT_DIR}"

# Safe directory change
function safe_cd() {
  cd "$1" || { echo "[Error] Cannot change directory to $1"; exit 1; }
}

# Output separator
function print_separator() {
  echo "--------------------------------------------------------------------------------"
}
