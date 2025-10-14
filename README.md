# TV.SH

A minimalist video screensaver that transforms your idle screen into a dynamic canvas (inspired by [archillect](https://archillect.com/tv)) using simple shell scripting.

## Use case

Screensaver-like functionality for smart home displays

## How it works

- prepare a directory with (typically) short media files (gifs/videos)
- `scrap.sh` can be used for scrapping media from websites (adapt to your needs)
- `index.sh` can be used for indexing media files
- set up a web server to serve media files to the player (see examples)
- launch `play.sh` to start playback
- use `ctl.sh` for playback & brightness control (specifically designed for raspberry pi setups)
- integrate with [swayidle](https://github.com/swaywm/swayidle) for automated screensaver behavior:

```bash
swayidle timeout 300 '~/tvsh/ctl.sh start' resume '~/tvsh/ctl.sh stop'
```

## Dependencies

- playing: mpv, socat, curl, jq, ddcutil (for brightness control)
- scraping/indexing: mpv, ffprobe (from ffmpeg)

## Configuration

Default config is located in lib/config.sh

User config should be places in `$HOME/.config/tvsh/config.sh`
