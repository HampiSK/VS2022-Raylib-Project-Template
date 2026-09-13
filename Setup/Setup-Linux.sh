#!/bin/bash

# Resolve the directory of this script
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." >/dev/null 2>&1 && pwd)"

PREMAKE="$ROOT_DIR/Premake/Linux/premake5"
"$PREMAKE" --cc=clang --file="$ROOT_DIR/Build.lua" gmake2
