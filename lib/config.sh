### player settings
# set brightness on start (empty to disable)
SET_BR="25"
# minimum duration of one clip (empty to disable)
MIN_DURA=""
# wait interval between clips
WAIT_INT=7
# mpv settings
MPV_OPTS="--video-zoom=0 --video-unscaled=no --panscan=1.0 --gpu-context=wayland --fs --input-vo-keyboard=no --stop-screensaver=no --no-window-dragging --no-input-cursor --loop=inf --osc=no"

# URI of domain with clips, assuming you have 'random' and 'duration' get parameters in it (see examples)
TVSH_URI="https://domain.com/tvsh/"
# exit player if command returns non-zero exit code, useful to check if display is active (empty to disable)
EXIT_CMD=""
# execute after start
ON_START_CMD=""
# execute after stop
ON_STOP_CMD=""

### scrapper settings
WEBSITE=""

### dirs and files
# tmp directory
TMP_DIR="/tmp/tvsh"
# clip cache directory
CACHE_DIR="$TMP_DIR/cache"
# mpv pid file
MPV_PID="$TMP_DIR/mpv.pid"
# mpv socket file
MPV_SOCK="$TMP_DIR/mpv.sock"

# clips directory
CLIP_DIR="$HOME/clips"
