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
  tvsh_user_conf="$HOME/.config/tvsh/config.sh"
  mpv_user_conf="$HOME/.config/tvsh/mpv.conf"
  MPV_CONF="$DIR/conf/mpv.conf"

  [ -f "$tvsh_user_conf" ] && source "$tvsh_user_conf"
  [ -f "$mpv_user_conf" ] && MPV_CONF="$mpv_user_conf"

  if [ "$SOURCE" == "http" ]; then
    MPV_OPTS="$MPV_OPTS $MPV_OPTS_HTTP"
  elif [ "$SOURCE" == "immich" ]; then
    MPV_OPTS="$MPV_OPTS $MPV_OPTS_IMMICH"
  fi
  set_osd
}

mkdirs() {
  if [ ! -d "$TMP_DIR" ]; then
    mkdir -p "$TMP_DIR"
  fi

  if [ ! -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR"
  fi
}

prepare() {
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

    while read -r album; do
      curl -sS -H "Accept: application/json" -H "x-api-key: $IMMICH_API_KEY" -L "$IMMICH_URL/albums/$album" | jq -r '.assets[] | select(.type != "VIDEO") | "\(.id);\(.exifInfo.city);\(.exifInfo.state);\(.exifInfo.country)"' >> "$TMP_DIR/immich_assets"
    done <<< "$albums"
  fi
}

set_osd() {
  OSD_TIME=$(($WAIT_INT * 1000))
}

set_brightness() {
  level="$1"

  if [ "$SET_BR" != "" ]; then
    if [ "$level" == "restore" ]; then
      level="$(cat $TMP_DIR/brightness)"
    else
      cur_br=$(eval "$BR_GET_CMD")
      echo "$cur_br" > "$TMP_DIR/brightness"
    fi

    $BR_SET_CMD $level >/dev/null
  fi
}

clean_cache() {
  cutoff="$1"

  cd "$CACHE_DIR"
  ls -1tr | head -n -"$cutoff" | while read -r file; do
    rm -f "$file"
  done
}

check_status() {
  if [ -f "$PID" ] && [ -f "/proc/$(cat $PID)/status" ]; then
    echo 1
  else
    echo 0
  fi
}

terminate() {
  [ -S "$MPV_SOCK" ] && echo '{"command": ["quit"]}' | socat - "$MPV_SOCK" >/dev/null
  if [ -f "$PID" ]; then
    pid=$(cat "$PID")
    kill "$pid"
  fi
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
