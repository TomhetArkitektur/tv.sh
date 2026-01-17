#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/config.sh"
source "$DIR/lib/utils.sh"

get_random() {
  dura="$1"

  if [ "$dura" == "" ]; then
    json=$(curl -s "$TVSH_URI/?random" | head -1)
  else
    json=$(curl -s "$TVSH_URI/?random&duration=$dura" | head -1)
  fi

  url=$(echo "$json" | jq -r '.url')
  fdura=$(echo "$json" | jq -r '.duration')
  echo "$url" "$fdura"
}

get_file() {
  url="$1"

  fname=$(basename "$url")
  curl -s -o "$CACHE_DIR/$fname" "$url"
  echo "$CACHE_DIR/$fname"
}

play() {
  fname="$1"
  if [ -f "$MPV_PID" ] && [ -f "/proc/$(cat $MPV_PID)/status" ]; then
    echo '{ "command": ["loadfile", "'"$fname"'", "replace"] }' | socat - "$MPV_SOCK" >/dev/null
  else
    mpv $MPV_OPTS --input-ipc-server="$MPV_SOCK" "$fname" >/dev/null &
    echo $! > "$MPV_PID"
  fi
}


load_user_config
on_event start

if [ ! -d "$CACHE_DIR" ]; then
  mkdir -p "$CACHE_DIR"
else
  find "$CACHE_DIR" -mindepth 1 -delete
fi

old_fname=""
while true; do
  on_event play

  read -r url fdura < <(get_random "$MIN_DURA")
  fname=$(get_file "$url")

  echo "playing $url ($fname) ($fdura sec)"
  play "$fname"

  if [ "$fdura" -gt "$WAIT_INT" ]; then
    sleep "$fdura"
  else
    sleep "$WAIT_INT"
  fi

  if [ "$old_fname" != "" ]; then
    rm "$old_fname"
  fi
  old_fname="$fname"
done
