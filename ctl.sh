#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/lib/config.sh"
source "$DIR/lib/utils.sh"

load_user_config
mkdirs

case "$1" in
  start)
    if [ "$(check_status)" -eq 0 ]; then
      set_brightness "$SET_BR"
      "$DIR/play.sh" >/dev/null &
      echo $! > "$PID"
      on_event start
    else
      echo "already running"
    fi
    ;;
  stop)
    if [ "$(check_status)" -eq 1 ]; then
      terminate
      on_event stop
      set_brightness "restore"
    else
      echo "not running"
    fi
    ;;
  status)
    if [ "$(check_status)" -eq 0 ]; then
      echo "stopped"
      exit 1
    else
      echo "running"
      exit 0
    fi
    ;;
  source)
    if [[ "$2" == "tvsh" || "$2" == "immich" ]]; then
      echo "set source: $2"
      sed -i "s|SOURCE=.*|SOURCE=\"$2\"|g" "$HOME/.config/tvsh/config.sh"
    else
      echo "unknown source: $2"
    fi
    ;;
esac
