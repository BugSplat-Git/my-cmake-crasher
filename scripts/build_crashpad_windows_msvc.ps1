# Create third_party directory if it doesn't exist
if (-not (Test-Path "third_party")) {
    New-Item -ItemType Directory -Path "third_party" | Out-Null
}
Set-Location -Path "third_party"

# Check if crashpad directory already exists
if (-not (Test-Path "crashpad")) {
    Write-Host "Fetching Crashpad using depot_tools..."
    fetch crashpad
    Set-Location -Path "crashpad"
} else {
    Write-Host "Crashpad already exists, updating..."
    Set-Location -Path "crashpad"
    git checkout main
    git pull
    gclient sync
}

# Generate build files with GN
Write-Host "Generating build files with GN..."
gn gen out/win --args="extra_cflags=\`"/MDd\`" is_debug=true" 

# Build
Write-Host "Building with Ninja..."
ninja -C out/win

Write-Host "Crashpad build complete."

# Return to the original directory
Set-Location -Path "../../" 