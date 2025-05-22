#!/bin/bash
# Script to upload symbols to BugSplat for Linux

# Command line arguments
database="$1"
appName="$2"
version="$3"
symbolsDir="$4"
clientId="$5"
clientSecret="$6"

# Set up paths
rootPath="$(cd "$(dirname "$0")/.." && pwd)"
toolsDir="${rootPath}/tools/linux"
symbolUploader="${toolsDir}/symbol-upload-linux"

# Create tools directory if it doesn't exist
mkdir -p "${toolsDir}"

# Download the symbol uploader if it doesn't exist
if [ ! -f "${symbolUploader}" ]; then
    echo "Downloading symbol-upload-linux..."
    curl -sL "https://app.bugsplat.com/download/symbol-upload-linux" -o "${symbolUploader}"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download symbol-upload-linux"
        exit 1
    fi
    chmod +x "${symbolUploader}"
    echo "Successfully downloaded symbol-upload-linux"
fi

# Upload symbols using glob pattern
echo "Uploading symbols from ${symbolsDir}"

"${symbolUploader}" -b "${database}" -a "${appName}" -v "${version}" -d "${symbolsDir}" -f "**/*.debug" -i "${clientId}" -s "${clientSecret}" -m

if [ $? -ne 0 ]; then
    echo "Error: Symbol upload failed with exit code $?"
    exit $?
fi

echo "Symbol upload completed successfully" 