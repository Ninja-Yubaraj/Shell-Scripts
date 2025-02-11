#!/bin/bash

# Usage: ./upload_to_google_drive.sh <file_path> [access_token]

# Get Google Drive API access token from environment or argument
ACCESS_TOKEN=${OAUTH_ACCESS_2_0_TOKEN:-$2}

if [ -z "$ACCESS_TOKEN" ]; then
  echo "Error: Access token not found. Set OAUTH_ACCESS_2_0_TOKEN environment variable or provide as second argument."
  exit 1
fi

# File to upload
FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
  echo "Usage: $0 <file_path> [access_token]"
  exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File '$FILE_PATH' not found!"
  exit 1
fi

# File metadata
FILE_NAME=$(basename "$FILE_PATH")

# Upload the file
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "metadata={name : '$FILE_NAME'};type=application/json;charset=UTF-8" \
  -F "file=@$FILE_PATH" \
  "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart")

# Display the response
echo "Upload response: $RESPONSE"
