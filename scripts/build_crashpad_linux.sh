#!/bin/bash
set -e

# Create third_party directory if it doesn't exist
mkdir -p third_party
cd third_party

# Check if crashpad directory already exists
if [ ! -d "crashpad" ]; then
  echo "Fetching Crashpad using depot_tools..."
  fetch crashpad
  cd crashpad
else
  echo "Crashpad already exists, updating..."
  cd crashpad
  git checkout main
  git pull
  gclient sync
fi

# Generate build files with GN for Debug configuration
echo "Generating Debug build files with GN..."
gn gen out/linux-debug --args="is_debug=true use_custom_libcxx=false"

# Generate build files with GN for Release configuration
echo "Generating Release build files with GN..."
gn gen out/linux-release --args="is_debug=false use_custom_libcxx=false"

# Build Debug
echo "Building Debug with Ninja..."
ninja -C out/linux-debug

# Build Release
echo "Building Release with Ninja..."
ninja -C out/linux-release

echo "Crashpad Debug and Release builds complete." 