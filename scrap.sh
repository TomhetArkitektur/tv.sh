#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/config.sh"
source "$DIR/lib/utils.sh"

load_user_config

cd "$CLIP_DIR" || { echo "could not find $CLIP_DIR"; exit 1; }

while true; do
  url=$(curl -s "$WEBSITE" | grep -oE 'https://[^"]*\.(gif|mp4|webm)' | head -1)

  if [[ -n "$url" ]]; then
    filename=$(basename "$url")

    if [[ -f "$filename" ]]; then
      echo "file $filename exists"
    else
      echo "downloading $url"
      curl -s -O "$url"

      if [[ $(check_clip "$CLIP_DIR/$filename") == 0 ]]; then
        echo "incorrect file $filename"
        rm "$CLIP_DIR/$filename"
      else
        index_clip "$filename"
      fi
    fi

    sleep 5
  fi
done
