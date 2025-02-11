#!/usr/bin/env bash
#
# A script to extract audio from video file(s) with no quality loss.
# Usage:
#   ./extract_audio.sh /path/to/file
#   ./extract_audio.sh /path/to/directory

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to extract audio from a single file
extract_audio_from_file() {
    local input_file="$1"

    # Get the file name without path
    local filename=$(basename "$input_file")
    
    # Extract the file name (without extension) for the new audio file
    local base_name="${filename%.*}"

    # Choose an audio container that can handle most codecs—here we use `.mka`
    # (Matroska Audio). You can also choose `.m4a`, `.aac`, `.mp3`, etc.,
    # but `.mka` is generally more flexible when copying streams.
    local output_file="${base_name}.mka"

    echo "Extracting audio from: $filename -> $output_file"
    
    # ffmpeg command to copy the audio stream without re-encoding
    ffmpeg -i "$input_file" -vn -acodec copy "$output_file"
    
    echo "Done."
    echo
}

# Make sure an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/file/or/directory"
    exit 1
fi

# If it's a directory, loop through its contents and find valid video files
if [ -d "$1" ]; then
    # You can adjust the extensions below to match your needs
    for video_file in "$1"/*; do
        # Check if the file has a typical video extension
        case "${video_file,,}" in
            *.mp4|*.mov|*.mkv|*.avi|*.flv|*.wmv|*.mpeg|*.mpg)
                extract_audio_from_file "$video_file"
                ;;
            *)
                # Not a recognized video extension; skip
                continue
                ;;
        esac
    done

# If it's a file, just process that single file
elif [ -f "$1" ]; then
    extract_audio_from_file "$1"

# Otherwise, it’s neither a file nor a directory
else
    echo "Error: '$1' is not a valid file or directory."
    exit 1
fi
