#!/bin/bash
# Usage: ./add_chapters.sh <folder_with_md_files>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <folder_with_md_files>"
    exit 1
fi

SOURCE_DIR="$1"
SUMMARY_FILE="src/SUMMARY.md"
DEST_DIR="src"

# Check source folder
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Folder '$SOURCE_DIR' does not exist."
    exit 1
fi

# Check SUMMARY.md
if [ ! -f "$SUMMARY_FILE" ]; then
    echo "Error: '$SUMMARY_FILE' not found. Run this script inside your mdBook project."
    exit 1
fi

# Remove default chapter_1.md if it exists
if [ -f "$DEST_DIR/chapter_1.md" ]; then
    echo "Removing default chapter_1.md..."
    rm "$DEST_DIR/chapter_1.md"
fi

# Backup SUMMARY.md
cp "$SUMMARY_FILE" "${SUMMARY_FILE}.bak"

# Copy Markdown files into src/
echo "Copying .md files from $SOURCE_DIR to $DEST_DIR..."
cp "$SOURCE_DIR"/*.md "$DEST_DIR"/

# Copy Attachments folder if it exists in the parent of SOURCE_DIR
PARENT_DIR="$(dirname "$SOURCE_DIR")"
if [ -d "$PARENT_DIR/Attachments" ]; then
    echo "Copying Attachments folder from parent directory..."
    cp -r "$PARENT_DIR/Attachments" "$DEST_DIR/"
fi

find "$DEST_DIR" -maxdepth 1 -type f -name "*.md" | while read md; do
    perl -i -pe '
    s{!\[\[([^\]]+)\]\]}{
        my $file=$1;
        my $alt=$file;
        my $path="Attachments/$file";
        $path=~s/ /%20/g;   # URL-encode spaces
        "![$alt]($path)"
    }ge
    ' "$md"
done


# Reset SUMMARY.md while preserving the heading
head -n 1 "$SUMMARY_FILE" > "${SUMMARY_FILE}.tmp"
echo "" >> "${SUMMARY_FILE}.tmp"

# Function to URL-encode filenames for safe Markdown links
urlencode() {
    local string="$1"
    local encoded=""
    local pos c o
    for ((pos=0; pos<${#string}; pos++)); do
        c=${string:$pos:1}
        case "$c" in
            [a-zA-Z0-9.~_-]) o="$c" ;;
            *) printf -v o '%%%02X' "'$c" ;;
        esac
        encoded+="$o"
    done
    echo "$encoded"
}

# Process each file from SOURCE_DIR
while IFS= read -r -d '' md_file; do
    filename=$(basename "$md_file")
    if [ "$filename" != "SUMMARY.md" ]; then
        section_name="${filename%.md}"
        dest_file="$DEST_DIR/$filename"

        # 1️⃣ Read file, replace \textdollar with \$, handle ====
        # 2️⃣ Prepend header with file name
        # 3️⃣ Convert ==== underlines to # headings
        tmp_file="$(mktemp)"
        {
            # Add top-level header
            echo "# $section_name"
            echo ""

            # Process original content
		# Process original content
awk '
    # Replace \textdollar with \$
    { gsub(/\\textdollar/, "\\\\$") }

    # Convert ==== underlines to yellow highlight
    NR>1 && $0 ~ /^=+$/ {
        print "<span style=\"background-color: yellow;\">" prev "</span>"
        next
    }

    { print }
    { prev=$0 }
' "$dest_file"
	                
        } > "$tmp_file"

        # Replace original file
        mv "$tmp_file" "$dest_file"

        # Add entry to SUMMARY.md
        encoded_filename=$(urlencode "$filename")
        echo "- [$section_name]($encoded_filename)" >> "${SUMMARY_FILE}.tmp"
    fi
done < <(find "$SOURCE_DIR" -maxdepth 1 -type f -name "*.md" -print0 | sort -z)

# Replace SUMMARY.md
mv "${SUMMARY_FILE}.tmp" "$SUMMARY_FILE"

echo "✅ Processed files: added headers, replaced \textdollar, converted ===="
echo "✅ SUMMARY.md updated."
echo "✅ Attachments copied (if present)."

