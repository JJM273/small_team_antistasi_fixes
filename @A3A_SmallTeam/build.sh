#!/usr/bin/env bash
# Build all PBOs and copy them into addons/ alongside sources.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

"${HEMTT:-hemtt}" build

cp .hemttout/build/addons/*.pbo addons/
