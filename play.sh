#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/config.sh"
source "$DIR/lib/utils.sh"
source "$DIR/lib/sources.sh"

show_osd() {
  if [ "$SHOW_OSD" == "true" ]; then
    text="$1"
    echo '{"command": ["show-text", "'"$text"'", "'"$OSD_TIME"'"]}' | socat - "$MPV_SOCK" >/dev/null
  fi
}

get_random() {
  dura="$1"

  if [ "$SOURCE" == "http" ]; then
    read -r name url fdura osd < <(get_random_http "$dura")
  elif [ "$SOURCE" == "immich" ]; then
    read -r name url fdura osd < <(get_random_immich)
  fi
  echo "$name" "$url" "$fdura" "$osd"
}

get_file() {
  url="$1"

  if [ "$SOURCE" == "http" ]; then
    fname=$(get_file_http "$url")
  elif [ "$SOURCE" == "immich" ]; then
    fname=$(get_file_immich "$url")
  fi
  echo "$fname"
}

play() {
  fname="$1"

  if [ -f "$MPV_PID" ] && [ -f "/proc/$(cat $MPV_PID)/status" ]; then
    echo '{ "command": ["loadfile", "'"$fname"'", "replace"] }' | socat - "$MPV_SOCK" >/dev/null
  else
    rm -f "$MPV_SOCK"
    mpv $MPV_OPTS --include="$MPV_CONF" --input-ipc-server="$MPV_SOCK" "$fname" >/dev/null &
    echo $! > "$MPV_PID"

    for i in {1..100}; do
      [ -S "$MPV_SOCK" ] && break
      sleep 0.05
    done
  fi
}


load_user_config
mkdirs
prepare

while true; do
  [ -f "$TMP_DIR/reload" ] && reload

  read -r name url fdura osd < <(get_random "$MIN_DURA")
  if [ -f "$CACHE_DIR/$name" ]; then
    fname="$CACHE_DIR/$name"
  else
    fname=$(get_file "$url")
  fi

  on_event play
  echo "playing $url ($fname) ($fdura sec)"
  play "$fname"
  show_osd "$osd"

  if [ "$fdura" -gt "$WAIT_INT" ]; then
    sleep "$fdura"
  else
    sleep "$WAIT_INT"
  fi

  clean_cache "$CACHE_SIZE"
done
