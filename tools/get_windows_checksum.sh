#!/bin/bash

# Script to obtain Windows MoonBit checksum
# This script attempts to download the Windows version of MoonBit
# and compute its SHA256 checksum for the checksum registry

set -e

echo "🔍 Attempting to obtain Windows MoonBit checksum..."

# Windows download URL
WINDOWS_URL="https://cli.moonbitlang.com/binaries/0.6.33/moonbit-windows-x86_64.zip"
TEMP_FILE="moonbit-windows-x86_64.zip"

# Try to download with timeout
echo "📥 Downloading Windows MoonBit..."
if command -v curl &> /dev/null; then
    curl -L -o "$TEMP_FILE" "$WINDOWS_URL" --max-time 30 || {
        echo "❌ Download failed or timed out"
        rm -f "$TEMP_FILE"
        exit 1
    }
elif command -v wget &> /dev/null; then
    wget -O "$TEMP_FILE" "$WINDOWS_URL" --timeout=30 || {
        echo "❌ Download failed or timed out"
        rm -f "$TEMP_FILE"
        exit 1
    }
else
    echo "❌ Neither curl nor wget available"
    exit 1
fi

# Compute checksum
echo "🔐 Computing SHA256 checksum..."
if command -v shasum &> /dev/null; then
    CHECKSUM=$(shasum -a 256 "$TEMP_FILE" | cut -d' ' -f1)
elif command -v sha256sum &> /dev/null; then
    CHECKSUM=$(sha256sum "$TEMP_FILE" | cut -d' ' -f1)
else
    echo "❌ Neither shasum nor sha256sum available"
    rm -f "$TEMP_FILE"
    exit 1
fi

echo "✅ Windows MoonBit checksum: $CHECKSUM"

# Clean up
rm -f "$TEMP_FILE"

# Show how to update the checksum registry
echo ""
echo "📝 To update the checksum registry:"
echo "1. Edit moonbit/checksums/moonbit.json"
echo "2. Find the 'windows_amd64' platform section"
echo "3. Replace 'TODO' with the checksum: $CHECKSUM"
echo "4. Save the file"

# Also show the exact JSON to update
echo ""
echo "📋 JSON to update:"
echo '  "windows_amd64": {'
echo '    "sha256": "'"$CHECKSUM"'",'
echo '    "url_suffix": "moonbit-windows-x86_64.zip",'
echo '    "binaries": ["moon.exe"]'
echo '  }'