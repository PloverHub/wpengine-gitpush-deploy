#!/usr/bin/env bash
#
# deploy.sh
#
# Demonstration of maximum portability and reliability when sourcing header.sh.
# Works on Bash and Zsh, whether symlinked or invoked from a different directory.
#

# ------------------------------------------------------------------------------
# Try to detect whether we are in Bash or Zsh to handle $BASH_SOURCE vs. $0
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
# Compute the absolute, physical path to the directory containing this script.
#   1. dirname "$SCRIPT_SOURCE"  -> relative dir of the script file
#   2. cd ... && pwd -P          -> change to that dir and get the physical path
#                                   (-P avoids symlinks)
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd -P)"

# ------------------------------------------------------------------------------
# Source our header.sh from that absolute directory
# ------------------------------------------------------------------------------
source "${SCRIPT_DIR}/header.sh"

# ------------------------------------------------------------------------------
# Verify Environment Argument (dev, stag, prod), as an example
# ------------------------------------------------------------------------------
ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
  echo "[Error] No environment specified!"
  echo "Usage: $0 <environment>"
  echo "where <environment> is one of: dev, stag, prod"
  exit 1
fi

case "$ENVIRONMENT" in
  dev|stag|prod)
    echo "Deploying to '$ENVIRONMENT' environment..."
    ;;
  *)
    echo "[Error] Invalid environment: $ENVIRONMENT"
    echo "Use one of: dev, stag, prod"
    exit 1
    ;;
esac

# ------------------------------------------------------------------------------
# Deployment Logic (Placeholder)
# ------------------------------------------------------------------------------
# E.g., fetch code, remove files, push to WP Engine, etc.

echo "Deployment script for '$ENVIRONMENT' completed!"
