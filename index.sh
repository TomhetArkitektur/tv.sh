#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/config.sh"
source "$DIR/lib/utils.sh"

load_user_config

for file in "$CLIP_DIR"/*; do
  [ -e "$file" ] || continue
    
  filename=$(basename "$file")
    
  echo "process $filename"
  index_clip "$file"
done
