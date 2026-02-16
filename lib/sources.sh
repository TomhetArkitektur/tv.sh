prepare_source() {
  if [ "$SOURCE" == "immich" ]; then
    prepare_source_immich
  fi
}

prepare_source_immich() {
  rm -f "$TMP_DIR/immich_assets"

  uri="$IMMICH_URL/albums"
  if [ "$IMMICH_ALBUMS_TYPE" == "shared" ]; then
    uri="$uri?shared=true"
  fi

  if [ "$IMMICH_ALBUMS_TYPE" == "manual" ]; then
    albums=$(printf "%s\n" "${IMMICH_ALBUMS[@]}")
  else
    albums=$(curl -sS -H "Accept: application/json" -H "x-api-key: $IMMICH_API_KEY" -L "$uri" | jq '.[]["id"]' | tr -d '"')
  fi

  while read -r album; do
    curl -sS -H "Accept: application/json" -H "x-api-key: $IMMICH_API_KEY" -L "$IMMICH_URL/albums/$album" | jq -r --arg max "$MAX_DURA" --arg min "$MIN_DURA" '.assets[] |
      (.duration | split(":") | (.[0]|tonumber)*3600 + (.[1]|tonumber)*60 + (.[2]|tonumber) | floor) as $dura |
      select(
        .type == "IMAGE" or
        (.type == "VIDEO" and
          ($max == "0" or $dura <= ($max|tonumber)) and
          ($min == "0" or $dura >= ($min|tonumber))
        )
      ) | "\(.id);\(.exifInfo.city);\(.exifInfo.state);\(.exifInfo.country);\($dura)"' >> "$TMP_DIR/immich_assets"
  done <<< "$albums"
}

get_random() {
  min_dura="$1"
  max_dura="$2"

  if [ "$SOURCE" == "http" ]; then
    read -r name url fdura osd < <(get_random_http "$min_dura" "$max_dura")
  elif [ "$SOURCE" == "immich" ]; then
    read -r name url fdura osd < <(get_random_immich)
  fi
  echo "$name" "$url" "$fdura" "$osd"
}

get_file() {
  url="$1"

  if [ "$SOURCE" == "http" ]; then
    fname=$(get_file_http "$url")
  elif [ "$SOURCE" == "immich" ]; then
    fname=$(get_file_immich "$url")
  fi
  echo "$fname"
}

get_file_http() {
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

get_random_http() {
  min_dura="$1"
  max_dura="$2"

  uri="$TVSH_URI/?random"
  [ "$min_dura" != "0" ] && uri="$uri&min_duration=$min_dura"
  [ "$max_dura" != "0" ] && uri="$uri&max_duration=$max_dura"
  
  json=$(curl -s "$uri" | head -1)

  url=$(echo "$json" | jq -r '.url')
  fdura=$(echo "$json" | jq -r '.duration')
  name=$(basename "$url")

  echo "$name" "$url" "$fdura" ""
}

get_random_immich() {
  rand_line=$(shuf -n 1 "$TMP_DIR/immich_assets")

  asset=`echo "$rand_line" | awk -F';' '{print $1}'`
  city=`echo "$rand_line" | awk -F';' '{print $2}'`
  state=`echo "$rand_line" | awk -F';' '{print $3}'`
  fdura=`echo "$rand_line" | awk -F';' '{print $5}'`

  [ "$city" == "null" ] && city=""
  [[ "$state" == "null" || "$state" == "$city" ]] && state=""
  location="$city $state"

  echo "$asset" "$IMMICH_URL/assets/$asset/original" "$fdura" "$location"
}
