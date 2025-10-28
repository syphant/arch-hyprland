#!/usr/bin/env bash
# Bash script to re-encode or copy MKV files using ffmpeg + NVENC

# Usage Examples:

# Re-encode video and audio (default):
# ./encode_mkv.sh

# Copy video, re-encode audio:
# ./encode_mkv.sh --video copy --audio aac

# Re-encode video, copy audio:
# ./encode_mkv.sh --video hevc --audio copy

# Copy both (no re-encode, just remux):
# ./encode_mkv.sh --video copy --audio copy

# Change bitrate and output folder:
# ./encode_mkv.sh --bitrate 1500k --output output_dir

set -e

# Default parameters
VIDEO_MODE="hevc"
AUDIO_MODE="aac"
BITRATE="1000k"
OUTPUT_DIR="mux"

# --- Parse arguments ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --video)
            VIDEO_MODE="$2"
            shift 2
            ;;
        --audio)
            AUDIO_MODE="$2"
            shift 2
            ;;
        --bitrate)
            BITRATE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--video copy|hevc] [--audio copy|aac] [--bitrate 1000k] [--output mux]"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# --- Check ffmpeg availability ---
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "Error: ffmpeg not found. Please install ffmpeg and ensure it’s in your PATH." >&2
    exit 1
fi
echo "✅ Found ffmpeg"

# --- Prepare output directory ---
mkdir -p "$OUTPUT_DIR"
echo "📂 Output directory: $OUTPUT_DIR"

# --- Find MKV files ---
shopt -s nullglob
MKV_FILES=(*.mkv)
if [[ ${#MKV_FILES[@]} -eq 0 ]]; then
    echo "⚠️  No MKV files found in current directory."
    exit 0
fi

echo "🎬 Found ${#MKV_FILES[@]} MKV file(s) to process:"
for f in "${MKV_FILES[@]}"; do
    echo "   - $f"
done

# --- Process files ---
TOTAL=${#MKV_FILES[@]}
COUNT=0

for f in "${MKV_FILES[@]}"; do
    COUNT=$((COUNT + 1))
    BASENAME="${f%.*}"
    OUTFILE="$OUTPUT_DIR/${BASENAME}.mkv"

    echo -e "\n[$COUNT/$TOTAL] Processing: $f"
    echo "→ Output: $OUTFILE"

    if [[ -f "$OUTFILE" ]]; then
        echo "⚠️  Output file already exists, skipping..."
        continue
    fi

    # Build ffmpeg args
    if [[ "$VIDEO_MODE" == "copy" ]]; then
        V_OPTS=(-c:v copy)
    else
        V_OPTS=(-c:v hevc_nvenc -b:v "$BITRATE")
    fi

    if [[ "$AUDIO_MODE" == "copy" ]]; then
        A_OPTS=(-c:a copy)
    else
        A_OPTS=(-c:a aac -b:a 128k -ac 2)
    fi

    CMD=(ffmpeg -hide_banner -loglevel error -stats
        -i "$f"
        "${V_OPTS[@]}"
        "${A_OPTS[@]}"
        -c:s copy
        -map 0
        -y "$OUTFILE"
    )

    echo "▶️  Running ffmpeg..."
    START_TIME=$(date +%s)

    if "${CMD[@]}"; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        printf "✅ Successfully encoded %s in %02d:%02d\n" "$f" $((DURATION/60)) $((DURATION%60))

        # File size comparison
        IN_SIZE=$(du -m "$f" | awk '{print $1}')
        OUT_SIZE=$(du -m "$OUTFILE" | awk '{print $1}')
        SAVINGS=$(( (IN_SIZE - OUT_SIZE) * 100 / IN_SIZE ))
        echo "📏 Size: ${IN_SIZE}MB → ${OUT_SIZE}MB (${SAVINGS}%% reduction)"
    else
        echo "❌ Failed to encode $f"
    fi
done

# --- Summary ---
OUT_COUNT=$(find "$OUTPUT_DIR" -type f -name "*.mkv" | wc -l)
TOTAL_SIZE=$(du -ch "$OUTPUT_DIR"/*.mkv | grep total | awk '{print $1}')
echo -e "\n✅ Processing complete!"
echo "📦 Encoded files: $OUT_COUNT"
echo "📁 Output folder: $OUTPUT_DIR"
echo "💾 Total size: $TOTAL_SIZE"
