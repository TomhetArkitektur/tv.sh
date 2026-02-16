# shellcheck shell=bash

get_clip_size() {
  local fname="$1"

  size=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$fname" 2>/dev/null | cut -d. -f1)
  echo "$size"
}

check_clip() {
  local fname="$1"

  if ! mpv --vo=null --ao=null "$fname" &>/dev/null; then
    echo 0
  else
    echo 1
  fi
}

index_clip() {
  local fname="$1"

  clip=$(basename "$fname")
  size=$(get_clip_size "$fname")

  echo "$clip;$size" >> "$CLIP_DIR/index"  
}

load_user_config() {
  local tvsh_user_conf="$HOME/.config/tvsh/config.sh"
  local mpv_user_conf="$HOME/.config/tvsh/mpv.conf"

  MPV_CONF="$DIR/conf/mpv.conf"

  # shellcheck disable=SC1090
  [ -f "$tvsh_user_conf" ] && source "$tvsh_user_conf"
  [ -f "$mpv_user_conf" ] && MPV_CONF="$mpv_user_conf"

  if [ "$SOURCE" == "http" ]; then
    MPV_OPTS="$MPV_OPTS $MPV_OPTS_HTTP"
  elif [ "$SOURCE" == "immich" ]; then
    MPV_OPTS="$MPV_OPTS $MPV_OPTS_IMMICH"
  fi
  set_osd

  read -r scripts < <(list_scripts "$DIR/scripts/*.lua")
  MPV_OPTS="$MPV_OPTS --include=$MPV_CONF --scripts=$scripts"
}

list_scripts () {
  local scripts_dir="$1"

  list=$(printf ":%s" "$scripts_dir")
  list=${list:1}
  echo "$list"
}

mkdirs() {
  if [ ! -d "$TMP_DIR" ]; then
    mkdir -p "$TMP_DIR"
  fi

  if [ ! -d "$CACHE_DIR" ]; then
    mkdir -p "$CACHE_DIR"
  fi
}

set_osd() {
  # shellcheck disable=SC2034
  OSD_TIME=$((WAIT_INT * 1000))
}

set_brightness() {
  local level="$1"

  if [ "$SET_BR" != "" ]; then
    if [ "$level" == "restore" ]; then
      level=$(cat "$TMP_DIR/brightness")
    else
      cur_br=$(eval "$BR_GET_CMD")
      echo "$cur_br" > "$TMP_DIR/brightness"
    fi

    $BR_SET_CMD "$level" >/dev/null
  fi
}

clean_cache() {
  local cutoff="$1"

  cd "$CACHE_DIR" || { echo "clean cache failed"; exit 1; }
  # shellcheck disable=SC2012
  ls -1tr | head -n -"$cutoff" | while IFS= read -r file; do
    [ -e "$file" ] && rm -f "$file"
  done
}

check_status() {
  if [ -f "$PID" ] && [ -f "/proc/$(cat "$PID")/status" ]; then
    return 0 # running
  else
    return 1 # not running
  fi
}

terminate() {
  [ -S "$MPV_SOCK" ] && echo '{"command": ["quit"]}' | socat - "$MPV_SOCK" >/dev/null 2>&1
  if [ -f "$PID" ]; then
    pid=$(cat "$PID")
    kill "$pid" >/dev/null 2>&1
  fi
}

reload() {
  rm -f "$TMP_DIR/reload"
  load_user_config
  [ -S "$MPV_SOCK" ] && echo '{"command": ["quit"]}' | socat - "$MPV_SOCK" >/dev/null

  for _ in {1..100}; do
    [ ! -f "/proc/$(cat "$MPV_PID")/status" ] && break
    sleep 0.05
  done
}

on_event() {
  local step="$1"

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
