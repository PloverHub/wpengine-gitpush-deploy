#!/usr/bin/env bash
#
#------------------------------------------------------------------------------
# header.sh
#
# Sets up a common environment for scripts in this repository by:
#   - Defining a non-interactive environment (for Debian/Ubuntu systems).
#   - Computing the script's directory path (SCRIPT_DIR).
#   - Optionally sourcing additional environment variables from env.sh if present.
#   - Changing into the script's directory to keep paths predictable.
#
# This will ensure a consistent environment (variables, script location, etc.).
#
# Author:  Wasseem Khayrattee
# GitHub:  https://github.com/wkhayrattee
#
#------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Enable strict mode for safer scripting:
#   - 'set -e'       : Exit immediately if a command exits with a non-zero status
#   - 'set -u'       : Treat unset variables as an error and exit immediately
#   - 'set -o pipefail': The return value of a pipeline is the status of the
#                        first command to fail (rather than the last command)
# ------------------------------------------------------------------------------
set -euo pipefail

# For Debian-based systems, prevent apt-get and similar tools from prompting for input
export DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------------------
# Detect whether we are in Bash or Zsh to handle $BASH_SOURCE vs. $0
# ------------------------------------------------------------------------------
if [ -n "$BASH_VERSION" ]; then
  # In Bash, we can rely on BASH_SOURCE
  SCRIPT_SOURCE="${BASH_SOURCE[0]}"
elif [ -n "$ZSH_VERSION" ]; then
  # In Zsh, $BASH_SOURCE isn't set, so we fallback to $0
  SCRIPT_SOURCE="$0"
else
  # Fallback for other shells (sh, dash, etc.) — $0 is often the script name
  SCRIPT_SOURCE="$0"
fi

# ------------------------------------------------------------------------------
# Compute the absolute path of the current script's directory.
# Explanation:
#   1. dirname extracts the parent directory from that path.
#   2. cd changes into that directory (>/dev/null 2>&1 silences output/errors).
#   3. pwd returns the absolute path of the directory.
#   4. use -P to resolve symlinks
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd -P)"

# ------------------------------------------------------------------------------
# Source additional environment variables from env.sh
# ------------------------------------------------------------------------------
if [[ -f "${SCRIPT_DIR}/env.sh" ]]; then
    source "${SCRIPT_DIR}/env.sh"
else
    echo "[Error] env.sh file not found!" >&2
    exit 1
fi

# ------------------------------------------------------------------------------
# Change directory to the location of this script to ensure all relative paths
# are evaluated from this location.
# ------------------------------------------------------------------------------
cd "${SCRIPT_DIR}"
