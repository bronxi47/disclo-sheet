#!/bin/bash

# Script name: disclo_sheet.sh

# Check necessary dependencies
dependencies=("wget" "libreoffice" "convert")
missing=()

for cmd in "${dependencies[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        missing+=("$cmd")
    fi
done

if [ ${#missing[@]} -ne 0 ]; then
    echo "Error: Missing dependencies: ${missing[*]}"
    echo "Please install these tools before running the script."
    echo "Installation instructions:"
    for dep in "${missing[@]}"; do
        case "$dep" in
            "wget")
                echo "  - Install wget: sudo apt install wget (Debian/Ubuntu) | sudo dnf install wget (Fedora) | sudo pacman -S wget (Arch)"
                ;;
            "libreoffice")
                echo "  - Install LibreOffice: sudo apt install libreoffice (Debian/Ubuntu) | sudo dnf install libreoffice (Fedora) | sudo pacman -S libreoffice (Arch)"
                ;;
            "convert")
                echo "  - Install ImageMagick (convert): sudo apt install imagemagick (Debian/Ubuntu) | sudo dnf install imagemagick (Fedora) | sudo pacman -S imagemagick (Arch)"
                ;;
        esac
    done
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 INPUT_FILE"
    exit 1
fi

# Input file
input_file="$1"

# Create directories for screenshots
screenshots_dir="screenshots"
mkdir -p "$screenshots_dir"

# Counters for statistics
total_filtered=0
total_downloaded=0

# Filter URLs and download files
declare -A url_map  # Map to associate files with their URLs
while IFS= read -r url; do
    # Filter URLs for spreadsheet file types
    if [[ "$url" =~ \.(xls|xlsx|csv|ods)$ ]]; then
        total_filtered=$((total_filtered + 1))
        echo "Processing: $url"
        
        # Get the file name and create a specific directory
        filename=$(basename "$url")
        file_dir="sheets/${filename%.*}"
        mkdir -p "$file_dir"

        # Download the file
        wget -q "$url" -O "$file_dir/$filename"

        # Check if the download was successful
        if [ $? -eq 0 ]; then
            total_downloaded=$((total_downloaded + 1))
            echo "Downloaded: $filename to $file_dir"

            # Save the URL associated with the file
            url_map["$file_dir/$filename"]="$url"

            # Open the file with LibreOffice and take a screenshot
            libreoffice --headless --nologo --norestore --nodefault --convert-to pdf "$file_dir/$filename" --outdir "$file_dir"
            pdf_file="$file_dir/${filename%.*}.pdf"

            if [ -f "$pdf_file" ]; then
                convert -density 150 "$pdf_file[0]" "$screenshots_dir/${filename%.*}.png"
                echo "Screenshot generated: ${filename%.*}.png"
            else
                echo "Failed to convert the file to PDF: $filename"
            fi
        else
            echo "Failed to download: $url"
        fi
    fi

done < "$input_file"

# Generate index.html
index_file="index.html"
echo "<html><head><title>disclo-sheet for fun & profit</title><style>
body { font-family: Arial, sans-serif; margin: 20px; }
img { border: 1px solid #ccc; margin: 10px; }
.container { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
.card { border: 1px solid #ddd; padding: 10px; background: #f9f9f9; }
.header { display: flex; justify-content: space-between; align-items: center; }
.footer { margin-top: 20px; text-align: center; font-size: smaller; color: #666; }
</style></head><body>" > "$index_file"
echo "<div class='header'><h1>disclo-sheet for fun & profit</h1><p style='font-size: smaller;'>by bronxi</p><p>Filtered files: $total_filtered | Downloaded: $total_downloaded</p></div>" >> "$index_file"
echo "<div class='container'>" >> "$index_file"

for screenshot in "$screenshots_dir"/*.png; do
    base_name=$(basename "$screenshot" .png)
    original_dir="sheets/$base_name"
    original_file="$original_dir/$(ls $original_dir | grep -E '\.(xls|xlsx|csv|ods)$')"
    original_url="${url_map["$original_file"]}"
    echo "<div class='card'>" >> "$index_file"
    echo "<h3>$base_name</h3>" >> "$index_file"
    echo "<a href='$original_file' target='_blank'>Open local file</a><br>" >> "$index_file"
    echo "<p>Original URL: <a href='$original_url' target='_blank'>$original_url</a></p>" >> "$index_file"
    echo "<img src='$screenshot' width='100%'><br>" >> "$index_file"
    echo "</div>" >> "$index_file"
done

echo "</div><div class='footer'>design with passion</div></body></html>" >> "$index_file"

# Done
echo "Process completed. Check index.html for results."
