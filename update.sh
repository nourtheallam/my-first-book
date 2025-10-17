#!/bin/bash

# Check if folder name is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <folder_name>"
    exit 1
fi

FOLDER_NAME="$1"
CHAPTER_NAME="$(basename "$FOLDER_NAME")"
SUMMARY_FILE="src/SUMMARY.md"

# Check if folder exists
if [ ! -d "$FOLDER_NAME" ]; then
    echo "Error: Folder '$FOLDER_NAME' does not exist."
    exit 1
fi

# Check if SUMMARY.md exists
if [ ! -f "$SUMMARY_FILE" ]; then
    echo "Error: '$SUMMARY_FILE' does not exist."
    exit 1
fi

# Create a backup of SUMMARY.md
cp "$SUMMARY_FILE" "${SUMMARY_FILE}.bak"

# Remove existing chapter (if any)
sed -i "/^# $CHAPTER_NAME$/,/^# / { /^# $CHAPTER_NAME$/!d }" "$SUMMARY_FILE"
sed -i "/^# $CHAPTER_NAME$/d" "$SUMMARY_FILE"

# Add updated chapter heading and subchapters to SUMMARY.md
echo -e "\n# $CHAPTER_NAME\n" >> "$SUMMARY_FILE"

for md_file in "$FOLDER_NAME"/*.md; do
    if [ -f "$md_file" ]; then
        filename=$(basename "$md_file")
        section_name="${filename%.md}"
        echo "- [$section_name]($FOLDER_NAME/$filename)" >> "$SUMMARY_FILE"
    fi
done

echo "Chapter '$CHAPTER_NAME' updated in $SUMMARY_FILE with all .md files as subchapters."

