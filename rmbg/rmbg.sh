#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <input_image_path> <output_image_path> [<API_KEY>]"
    exit 1
fi

# Assign command-line arguments to variables
INPUT_IMAGE="$1"
OUTPUT_IMAGE="$2"
if [ "$#" -eq 3 ]; then
    API_KEY="$3"
else
    API_KEY="$REMOVE_BG_API_KEY"
fi

# Check if API key is set
if [ -z "$API_KEY" ]; then
    echo "Error: API key is not set. Provide it as an argument or set it in the environment."
    exit 1
fi

# Check if input file exists
if [ ! -f "$INPUT_IMAGE" ]; then
    echo "Error: Input file does not exist."
    exit 1
fi

# Make the API request to Remove.bg
curl -H "X-Api-Key: $API_KEY" \
     -F "image_file=@$INPUT_IMAGE" \
     -f "https://api.remove.bg/v1.0/removebg" \
     -o "$OUTPUT_IMAGE"

# Check if the output file is successfully created
if [ $? -eq 0 ]; then
    echo "Background removed successfully. Saved to $OUTPUT_IMAGE"
else
    echo "Failed to remove background. Please check your API key or input file."
    exit 1
fi
