# TV.SH

A minimalist video screensaver that transforms your idle screen into a dynamic canvas (inspired by [archillect](https://archillect.com/tv)) using simple shell scripting.

## Use case

Screensaver-like functionality for smart home displays (with [immich](https://github.com/immich-app/immich) support)

## How it works

### Wth API

- prepare a directory with (typically) short media files (gifs/videos)
- `scrap.sh` can be used for scrapping media from websites (adapt to your needs)
- `index.sh` can be used for indexing media files
- set up a web server to serve media files to the player (see examples)

### With IMMICH

- get API key and prepare some albums (owned or shared)

### Run!

- launch `play.sh` to start playback
- use `ctl.sh` for playback control:

```bash
~/tv.sh/ctl.sh start 
~/tv.sh/ctl.sh stop
~/tv.sh/ctl.sh status
~/tv.sh/ctl.sh source [tvsh|immich] # set source
```
  
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
