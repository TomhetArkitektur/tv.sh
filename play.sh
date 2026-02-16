#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/config.sh"
source "$DIR/lib/utils.sh"
source "$DIR/lib/sources.sh"

show_osd() {
  local text="$1"
  #local dura="$2"

  if [ "$SHOW_OSD" == "true" ] && [ "$text" != "" ]; then
    echo '{"command": ["script-message", "show-fade-text", "'"$text"'", "'"$OSD_TIME"'"]}' | socat - "$MPV_SOCK" >/dev/null
  fi
}

play() {
  fname="$1"

  # load new file if mpv is running
  if [ -f "$MPV_PID" ] && [ -f "/proc/$(cat "$MPV_PID")/status" ]; then
    echo '{ "command": ["loadfile", "'"$fname"'", "replace"] }' | socat - "$MPV_SOCK" >/dev/null
  # run mpv if not running
  else
    rm -f "$MPV_SOCK"
    # shellcheck disable=SC2086
    mpv $MPV_OPTS --input-ipc-server="$MPV_SOCK" "$fname" >/dev/null &
    echo $! > "$MPV_PID"

    # wait for socket creation
    for _ in {1..100}; do
      [ -S "$MPV_SOCK" ] && break
      sleep 0.05
    done
  fi
}


load_user_config
mkdirs
prepare_source

while true; do
  [ -f "$TMP_DIR/reload" ] && reload

  read -r name url fdura osd < <(get_random "$MIN_DURA" "$MAX_DURA")
  if [ -f "$CACHE_DIR/$name" ]; then
    fname="$CACHE_DIR/$name"
  else
    fname=$(get_file "$url")
  fi

  on_event play
  echo "playing $url ($fname) ($fdura sec)"
  play "$fname"
  show_osd "$osd" "$fdura"

  if [ "$fdura" -gt "$WAIT_INT" ]; then
    sleep "$fdura"
  else
    sleep "$WAIT_INT"
  fi

  clean_cache "$CACHE_SIZE"
done
