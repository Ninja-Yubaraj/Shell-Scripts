#!/bin/bash

# Usage: ./upload_to_google_drive.sh <file_path> [access_token] [folder_id]

# Get Google Drive API access token from argument or environment
ACCESS_TOKEN=${2:-$OAUTH_ACCESS_2_0_TOKEN}

if [ -z "$ACCESS_TOKEN" ]; then
  echo "Error: Access token not found. Provide as second argument or set OAUTH_ACCESS_2_0_TOKEN environment variable."
  exit 1
fi

# Verify if the provided access token is valid
TOKEN_VALID=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $ACCESS_TOKEN" "https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=$ACCESS_TOKEN")
if [ "$TOKEN_VALID" -ne 200 ]; then
  echo "Error: Invalid access token. Please provide a valid access token."
  exit 1
fi

# File to upload
FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
  echo "Usage: $0 <file_path> [access_token] [folder_id]"
  exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File '$FILE_PATH' not found!"
  exit 1
fi

# Folder ID (optional)
FOLDER_ID="$3"

# Validate the provided folder ID if present
if [ -n "$FOLDER_ID" ]; then
  FOLDER_VALID=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $ACCESS_TOKEN" "https://www.googleapis.com/drive/v3/files/$FOLDER_ID?fields=id")
  if [ "$FOLDER_VALID" -ne 200 ]; then
    echo "Error: Invalid folder ID. Please provide a valid Google Drive folder ID."
    exit 1
  fi
fi

# File metadata
FILE_NAME=$(basename "$FILE_PATH")
METADATA="{name : '$FILE_NAME'"
if [ -n "$FOLDER_ID" ]; then
  METADATA+=" , parents: ['$FOLDER_ID']"
fi
METADATA+="}"

# Upload the file
RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "metadata=$METADATA;type=application/json;charset=UTF-8" \
  -F "file=@$FILE_PATH" \
  "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart")

# Extract the file ID from the response
FILE_ID=$(echo "$RESPONSE" | grep -oP '"id":\s*"\K[^"]+')

if [ -n "$FILE_ID" ]; then
  # Generate the download link
  DOWNLOAD_LINK="https://drive.google.com/uc?id=$FILE_ID&export=download"
  echo "$DOWNLOAD_LINK"
else
  echo "Error: File upload failed. Response: $RESPONSE"
fi
