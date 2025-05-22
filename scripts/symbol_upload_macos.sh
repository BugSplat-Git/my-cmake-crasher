#!/bin/bash
# Script to upload symbols to BugSplat for macOS

# Command line arguments
database="$1"
appName="$2"
version="$3"
symbolsDir="$4"
clientId="$5"
clientSecret="$6"

# Set up paths
rootPath="$(cd "$(dirname "$0")/.." && pwd)"
toolsDir="${rootPath}/tools/macos"
symbolUploader="${toolsDir}/symbol-upload-macos"

# Create tools directory if it doesn't exist
mkdir -p "${toolsDir}"

# Download the symbol uploader if it doesn't exist
if [ ! -f "${symbolUploader}" ]; then
    echo "Downloading symbol-upload-macos..."
    curl -sL "https://app.bugsplat.com/download/symbol-upload-macos" -o "${symbolUploader}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download symbol-upload-macos"
        exit 1
    fi
    chmod +x "${symbolUploader}"
    echo "Successfully downloaded symbol-upload-macos"
fi

# Upload symbols using glob pattern
echo "Uploading symbols from ${symbolsDir}"

"${symbolUploader}" -b "${database}" -a "${appName}" -v "${version}" -d "${symbolsDir}" -f "**/*.dSYM" -i "${clientId}" -s "${clientSecret}" -m

if [ $? -ne 0 ]; then
    echo "Error: Symbol upload failed with exit code $?"
    exit $?
fi

echo "Symbol upload completed successfully" 