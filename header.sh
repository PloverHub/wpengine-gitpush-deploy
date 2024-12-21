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
# Compute the absolute path of the current script's directory.
# Explanation:
#   1. BASH_SOURCE[0] is the path to this script (even if sourced).
#   2. dirname extracts the parent directory from that path.
#   3. cd changes into that directory (>/dev/null 2>&1 silences output/errors).
#   4. pwd returns the absolute path of the directory.
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"

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
