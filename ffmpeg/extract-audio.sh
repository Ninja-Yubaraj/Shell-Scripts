#!/usr/bin/env bash
#
# extract_audio.sh
#
# A script to extract the audio stream from a video file with no quality loss.
# Usage: ./extract_audio.sh /path/to/video.mp4
#

###################
# INITIAL CHECKS  #
###################

if [ -z "$1" ]; then
  echo "Usage: $0 <video_file>"
  exit 1
fi

VIDEO_FILE="$1"

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
  echo "Error: ffmpeg is not installed or not in PATH."
  echo "Please install it (e.g., sudo apt-get install ffmpeg) and try again."
  exit 1
fi

# Check if ffprobe is installed (used to detect audio codec)
if ! command -v ffprobe &> /dev/null; then
  echo "Error: ffprobe is not installed or not in PATH."
  echo "Please install it (e.g., sudo apt-get install ffmpeg) and try again."
  exit 1
fi

###################
# MAIN LOGIC      #
###################

# Extract just the filename without path
BASENAME="$(basename "$VIDEO_FILE")"
# Strip the extension from the filename
NAME="${BASENAME%.*}"

# Use ffprobe to detect the primary audio codec name
AUDIO_CODEC="$( \
  ffprobe -v error \
          -select_streams a:0 \
          -show_entries stream=codec_name \
          -of csv=p=0 \
          "$VIDEO_FILE" \
)"

# Decide on a suitable file extension based on the codec
case "$AUDIO_CODEC" in
  aac)
    EXTENSION="m4a"
    ;;
  mp3)
    EXTENSION="mp3"
    ;;
  opus)
    EXTENSION="opus"
    ;;
  vorbis)
    EXTENSION="ogg"
    ;;
  flac)
    EXTENSION="flac"
    ;;
  ac3)
    EXTENSION="ac3"
    ;;
  pcm_s16le | pcm_s24le | pcm_s32le | wav)
    # Common uncompressed PCM audio in a WAV container
    EXTENSION="wav"
    ;;
  *)
    # Fallback to Matroska audio container if we don't recognize the codec
    EXTENSION="mka"
    ;;
esac

OUTPUT_FILE="${NAME}.${EXTENSION}"

# Extract the audio with no re-encoding (-c:a copy)
# -vn : ignore video
# -c:a copy : do not re-encode the audio
ffmpeg -i "$VIDEO_FILE" -vn -c:a copy "$OUTPUT_FILE"

echo "Audio extracted successfully!"
echo "Output file: $OUTPUT_FILE"
