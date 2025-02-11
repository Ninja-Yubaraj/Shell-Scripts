#!/bin/bash

get_code_from_clipboard() {
  if command -v xclip > /dev/null; then
    xclip -selection clipboard -o
  elif command -v xsel > /dev/null; then
    xsel --clipboard --output
  elif command -v wl-paste > /dev/null; then
    wl-paste
  elif command -v pbpaste > /dev/null; then
    pbpaste
  else
    echo "No clipboard utility found. Please provide a code or install xclip/xsel/wl-paste/pbpaste."
    exit 1
  fi
}

if [ -z "$1" ]; then
  code=$(get_code_from_clipboard)
else
  code=$1
fi

if [[ ! $code =~ ^[0-9]+$ ]]; then
  echo "Invalid code. Please provide a valid number."
  exit 1
fi

url="https://nhentai.net/g/$code"
echo "Opening $url"
xdg-open "$url" 2>/dev/null || open "$url"
