#!/bin/bash
set -e

BUILD_DIR="$1"
PYTHON_DIR="$2"
REQUIREMENTS_FILE="$3"
SHARED_MODULES_PATH="$4"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$PYTHON_DIR"

# Install Python dependencies
if [ -f "$REQUIREMENTS_FILE" ]; then
  echo "Installing dependencies from $REQUIREMENTS_FILE..."
  pip install -r "$REQUIREMENTS_FILE" -t "$PYTHON_DIR" \
    --platform manylinux2014_x86_64 \
    --only-binary=:all: \
    --upgrade \
    --no-cache-dir
fi

# Copy shared modules if provided
if [ -n "$SHARED_MODULES_PATH" ] && [ -d "$SHARED_MODULES_PATH" ]; then
  echo "Copying shared modules from $SHARED_MODULES_PATH..."
  cp -r "$SHARED_MODULES_PATH"/* "$PYTHON_DIR"/
fi

echo "Layer build completed successfully"
