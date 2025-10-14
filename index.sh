#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/config.sh"
source "$DIR/lib/utils.sh"

load_user_config

for file in `ls "$CLIP_DIR"`; do
  echo "process $file"
  index_clip "$CLIP_DIR/$file"
done
