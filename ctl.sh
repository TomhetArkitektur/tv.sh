#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/config.sh"
source "$DIR/lib/utils.sh"

load_user_config

if [ ! -d "$TMP_DIR" ]; then
  mkdir "$TMP_DIR"
fi

case "$1" in
  start)
    CUR_BR=$(sudo ddcutil -t --brief getvcp 10 | awk '{print $4}')
    echo "$CUR_BR" > "$TMP_DIR/brightness"
    sudo ddcutil setvcp 10 "$SET_BR"
    "$DIR/play.sh"
    ;;
  stop)
    pkill -f play.sh
    pkill -f mpv
    sudo ddcutil setvcp 10 "$(cat $TMP_DIR/brightness)"
    $ON_STOP_CMD >/dev/null
    ;;
  status)
    state=`pgrep -f "tv.sh/play.sh"`
    if [ $? == 1 ]; then
      echo "stopped"
    else
      echo "running"
    fi
    ;;
esac
