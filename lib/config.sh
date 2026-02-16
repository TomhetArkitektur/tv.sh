### Player settings
# set brightness on start (empty to disable)
SET_BR=""
# set brightness command
BR_SET_CMD="sudo ddcutil setvcp 10"
# get brightness command
BR_GET_CMD="sudo ddcutil -t --brief getvcp 10 | awk '{print \$4}'"
# minimum duration of one clip (0 to disable)
MIN_DURA=0
# maximum duration (0 to disable)
MAX_DURA=20
# wait interval between clips
WAIT_INT=7
# files to keep in cache
CACHE_SIZE=10
# show OSD with custom text from source (see lib/sources.sh)
SHOW_OSD="true"
# general mpv settings for all sources
MPV_OPTS="--video-zoom=0 --video-unscaled=no --panscan=1.0 --fs --input-vo-keyboard=no --stop-screensaver=no --no-window-dragging --no-input-cursor --loop=inf --osc=no"
# mpv settings for http source
MPV_OPTS_HTTP=""
# mpv settings for immich source (example: '--vo=wlshm' for wayland on raspberry pi)
MPV_OPTS_IMMICH=""
# Source of clips, can be dinamically switched via 'ctl.sh source [SOURCE]'
SOURCE="http"

### Source settings
# URI of domain with clips, assuming you have 'random' and 'duration' get parameters in it (see examples)
HTTP_URI="https://domain.com/tvsh/"
# immich API URL
IMMICH_URL="https://immich.domain.com/api"
# immich API key
IMMICH_API_KEY=""
# albums type: shared, owned, manual
IMMICH_ALBUMS_TYPE="shared"
# if IMMICH_ALBUMS_TYPE is set to 'manual' - provide specific albums UUIDs in array
IMMICH_ALBUMS=()

### Hooks
# exit player if command returns non-zero exit code, useful to check if display is active (empty to disable)
EXIT_CMD=""
# execute after start
ON_START_CMD=""
# execute after stop
ON_STOP_CMD=""

### Dirs and files
# tmp directory
TMP_DIR="/tmp/tvsh"
# clip cache directory
CACHE_DIR="$TMP_DIR/cache"
# tv.sh pid file
PID="$TMP_DIR/tvsh.pid"
# mpv pid file
MPV_PID="$TMP_DIR/mpv.pid"
# mpv socket file
MPV_SOCK="$TMP_DIR/mpv.sock"
# clips directory
CLIP_DIR="$HOME/clips"

### Scrapper settings
WEBSITE=""
