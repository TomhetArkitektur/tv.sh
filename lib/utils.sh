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
      $EXIT_CMD >/dev/null || { echo "'${EXIT_CMD}' returns non-zero exit code, exiting"; exit 1; }
      ;;
  esac
}
