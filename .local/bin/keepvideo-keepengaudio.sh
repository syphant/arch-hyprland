#!/usr/bin/env bash
# ================================================
# MKV Batch Script (Bash version, fixed)
# Keeps:   All video tracks + English audio only
# Removes: All other audio, subtitles, attachments, tags, chapters
# Requires: mkvmerge (from mkvtoolnix) and jq
# ================================================

# Path to mkvmerge (adjust if needed)
mkvmerge_bin="mkvmerge"

# Output directory
output_dir="./mux"
mkdir -p "$output_dir"

# Gather all MKV files in current directory
shopt -s nullglob
files=( *.mkv )
total_files=${#files[@]}
current_index=0

if (( total_files == 0 )); then
    echo "No MKV files found in the current directory."
    exit 1
fi

for file in "${files[@]}"; do
    ((current_index++))
    input_file="$file"
    output_file="$output_dir/$file"

    echo
    echo "Processing file [$current_index/$total_files]: $file ..."

    # Identify tracks with mkvmerge (JSON output)
    json="$("$mkvmerge_bin" --identification-format json --identify "$input_file")"
    if [[ $? -ne 0 || -z "$json" ]]; then
        echo "❌ Failed to identify tracks for: $file"
        continue
    fi

    # --- Detect Video Tracks ---
    video_tracks=$(echo "$json" | jq -r '.tracks[] | select(.type=="video") | .id' | paste -sd "," -)
    if [[ -z "$video_tracks" ]]; then
        echo "⚠️  No video tracks found in: $file. Skipping..."
        continue
    fi

    # --- Detect English Audio Tracks ---
    english_audio_tracks=$(echo "$json" | jq -r '.tracks[] | select(.type=="audio" and .properties.language=="eng") | .id' | paste -sd "," -)
    if [[ -z "$english_audio_tracks" ]]; then
        echo "⚠️  No English audio tracks found in: $file. Skipping..."
        continue
    fi

    # --- Build mkvmerge command ---
    echo "Merging video ($video_tracks) + English audio ($english_audio_tracks)..."
    "$mkvmerge_bin" \
        -o "$output_file" \
        --video-tracks "$video_tracks" \
        --audio-tracks "$english_audio_tracks" \
        --no-subtitles \
        --no-attachments \
        --no-global-tags \
        --no-chapters \
        --quiet \
        "$input_file"

    if [[ $? -eq 0 ]]; then
        echo "✅ Completed: $file"
    else
        echo "❌ Failed to process: $file"
    fi

    # --- Show progress ---
    progress=$(awk "BEGIN {printf \"%.2f\", ($current_index/$total_files)*100}")
    echo "Overall progress: ${progress}%"
done

echo
echo "🎬 All files processed, output saved in '$output_dir'"
