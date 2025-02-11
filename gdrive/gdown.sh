#!/bin/bash

# Check if Google Drive link is provided as an argument
if [[ -z "$1" ]]; then
  echo "Usage: $0 <google_drive_link>"
  exit 1
fi

# Extract file ID from Google Drive link
LINK="$1"
FILE_ID=$(echo "$LINK" | grep -o '[-_0-9a-zA-Z]\{25,\}')

# Check if file ID extraction was successful
if [[ -z "$FILE_ID" ]]; then
  echo "Error: Could not extract file ID from the provided link."
  exit 1
fi

# Fetch original file name
FILE_NAME=$(curl -sc /tmp/gdrive_cookie "https://drive.google.com/uc?export=download&id=${FILE_ID}" | grep -o 'filename=".*"' | sed 's/filename="//;s/"$//')

# Fallback to timestamped file name if extraction fails
if [[ -z "$FILE_NAME" ]]; then
  TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")
  FILE_NAME="file_${TIMESTAMP}"
fi

# Attempt to get the download confirmation code for large files
echo "Fetching confirmation code..."
CODE="$(awk '/_warning_/ {print $NF}' /tmp/gdrive_cookie)"

# Download file with or without confirmation code
if [[ -z "$CODE" ]]; then
  # Small file, no confirmation code required
  echo "Downloading small file..."
  curl -L -o "${FILE_NAME}" "https://drive.google.com/uc?export=download&id=${FILE_ID}"
else
  # Large file, confirmation code required
  echo "Downloading large file..."
  curl -Lb /tmp/gdrive_cookie "https://drive.google.com/uc?export=download&confirm=${CODE}&id=${FILE_ID}" -o "${FILE_NAME}"
fi

# Clean up
rm -f /tmp/gdrive_cookie
echo "Download completed: ${FILE_NAME}"
