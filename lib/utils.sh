get_clip_size() {
  fname="$1"
  size=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$fname" 2>/dev/null | cut -d. -f1)
  echo "$size"
}

check_clip() {
  fname="$1"
  if ! mpv --vo=null --ao=null "$fname" &>/dev/null; then
    echo 0
  else
    echo 1
  fi
}

index_clip() {
  fname="$1"
  clip=$(basename "$fname")
  size=$(get_clip_size "$fname")

  echo "$clip;$size" >> "$CLIP_DIR/index"  
}

load_user_config() {
  fname="$HOME/.config/tvsh/config.sh"
  if [ -f "$fname" ]; then
    source "$fname"
  fi

  if [ "$SOURCE" == "immich" ]; then
    MPV_OPTS="$MPV_OPTS $MPV_OPTS_IMMICH"
  elif [ "$SOURCE" == "tvsh" ]; then
    MPV_OPTS="$MPV_OPTS $MPV_OPTS_TVSH"
  fi
}

prepare() {
  if [ ! -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR"
  else
    find "$CACHE_DIR" -mindepth 1 -delete
  fi

  if [ "$SOURCE" == "immich" ]; then
    rm -f "$TMP_DIR/immich_assets"

    uri="$IMMICH_URL/albums"
    if [ "$IMMICH_ALBUMS_TYPE" == "shared" ]; then
      uri="$uri?shared=true"
    fi

    if [ "$IMMICH_ALBUMS_TYPE" == "manual" ]; then
      albums=$(printf "%s\n" "${IMMICH_ALBUMS[@]}")
    else
      albums=$(curl -sS -H "Accept: application/json" -H "x-api-key: $IMMICH_API_KEY" -L "$uri" | jq '.[]["id"]' | tr -d '"')
    fi
    echo "${albums[@]}"

    while read -r album; do
      curl -sS -H "Accept: application/json" -H "x-api-key: $IMMICH_API_KEY" -L "$IMMICH_URL/albums/$album" | jq -r '.assets[] | select(.type != "VIDEO") | .id' >> "$TMP_DIR/immich_assets"
    done <<< "$albums"
  fi
}

terminate() {
  pkill -f mpv
  pkill -f play.sh
}

on_event() {
  step="$1"
  case "$step" in
    start)
      $ON_START_CMD >/dev/null
      ;;
    stop)
      $ON_STOP_CMD >/dev/null
      ;;
    play)
      $EXIT_CMD >/dev/null || { echo "'${EXIT_CMD}' returns non-zero exit code, exiting"; terminate; exit 1; }
      ;;
  esac
}
