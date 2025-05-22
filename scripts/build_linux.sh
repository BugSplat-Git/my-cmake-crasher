#!/bin/bash
set -e

# Check if depot_tools is in PATH
if ! command -v fetch &> /dev/null; then
    echo "ERROR: depot_tools not found in PATH"
    echo "Please install depot_tools and add it to your PATH:"
    echo "https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html"
    exit 1
fi

# First build Crashpad
echo "Building Crashpad..."
./scripts/build_crashpad_linux.sh

# Create build directory if it doesn't exist
echo "Building MyCMakeCrasher..."
mkdir -p build
cd build

# Configure and build with Debug mode for better symbol generation
echo "Configuring with Debug symbols for better crash reporting..."
cmake .. -DCMAKE_BUILD_TYPE=Debug
make

echo "Build complete. Run the application with: ./Debug/MyCMakeCrasher"

# Extract debug symbols to separate .debug files for better symbol handling
echo "Extracting debug symbols..."

# Extract symbols for main executable
if [ -f "Debug/MyCMakeCrasher" ]; then
    objcopy --only-keep-debug Debug/MyCMakeCrasher Debug/MyCMakeCrasher.debug
    objcopy --strip-debug Debug/MyCMakeCrasher
    objcopy --add-gnu-debuglink=Debug/MyCMakeCrasher.debug Debug/MyCMakeCrasher
    echo "Debug symbols extracted: Debug/MyCMakeCrasher.debug"
fi

# Extract symbols for crash library
if [ -f "Debug/libcrash.so.2" ]; then
    objcopy --only-keep-debug Debug/libcrash.so.2 Debug/libcrash.so.2.debug
    objcopy --strip-debug Debug/libcrash.so.2
    objcopy --add-gnu-debuglink=Debug/libcrash.so.2.debug Debug/libcrash.so.2
    echo "Debug symbols extracted: Debug/libcrash.so.2.debug"
fi

echo "Symbol extraction complete."

# Return to root directory
cd .. 