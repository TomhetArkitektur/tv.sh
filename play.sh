#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/config.sh"
source "$DIR/lib/utils.sh"

show_osd() {
  if [ "$SHOW_OSD" == "true" ]; then
    text="$1"
    echo '{"command": ["show-text", "'"$text"'", "'"$OSD_TIME"'"]}' | socat - "$MPV_SOCK" >/dev/null
  fi
}

get_random_tvsh() {
  dura="$1"

  uri="$TVSH_URI/?random"
  if [ "$dura" != "" ]; then
    uri="$uri&duration=$dura"
  fi
  json=$(curl -s "$uri" | head -1)

  url=$(echo "$json" | jq -r '.url')
  fdura=$(echo "$json" | jq -r '.duration')
  echo "$url" "$fdura" ""
}

get_random_immich() {
  rand_line=$(shuf -n 1 "$TMP_DIR/immich_assets")
  asset=`echo "$rand_line" | awk -F';' '{print $1}'`
  city=`echo "$rand_line" | awk -F';' '{print $2}'`
  state=`echo "$rand_line" | awk -F';' '{print $3}'`
  if [ "$city" == "null" ]; then
    city=""
  fi
  if [[ "$state" == "null" || "$state" == "$city" ]]; then
    state=""
  fi
  location="$city $state"

  echo "$IMMICH_URL/assets/$asset/original" 0 "$location"
}

get_random() {
  dura="$1"

  if [ "$SOURCE" == "tvsh" ]; then
    read -r url fdura osd < <(get_random_tvsh "$dura")
  elif [ "$SOURCE" == "immich" ]; then
    read -r url fdura osd < <(get_random_immich)
  fi
  echo "$url" "$fdura" "$osd"
}

get_file_tvsh() {
  url="$1"

  fname=$(basename "$url")
  curl -s -o "$CACHE_DIR/$fname" "$url"
  echo "$CACHE_DIR/$fname"
}

get_file_immich() {
  url="$1"

  fname=$(basename $(dirname "$url"))
  curl -s -o "$CACHE_DIR/$fname" -H "Accept: application/json" -H "x-api-key: $IMMICH_API_KEY" -L "$url"
  echo "$CACHE_DIR/$fname"
}

get_file() {
  url="$1"

  if [ "$SOURCE" == "tvsh" ]; then
    fname=$(get_file_tvsh "$url")
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
on_event start
prepare

old_fname=""
while true; do
  on_event play

  read -r url fdura osd < <(get_random "$MIN_DURA")
  fname=$(get_file "$url")

  echo "playing $url ($fname) ($fdura sec)"
  play "$fname"
  show_osd "$osd"

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
