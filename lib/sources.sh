prepare_source() {
  if [ "$SOURCE" == "immich" ]; then
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
      curl -sS -H "Accept: application/json" -H "x-api-key: $IMMICH_API_KEY" -L "$IMMICH_URL/albums/$album" | jq -r --arg max "$MAX_DURA" '.assets[] |
        (.duration | split(":") | (.[0]|tonumber)*3600 + (.[1]|tonumber)*60 + (.[2]|tonumber) | floor) as $dura |
        select(
          .type == "IMAGE" or (.type == "VIDEO" and $dura <= ($max|tonumber))
        ) | "\(.id);\(.exifInfo.city);\(.exifInfo.state);\(.exifInfo.country);\($dura)"' >> "$TMP_DIR/immich_assets"
    done <<< "$albums"
  fi
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
  dura="$1"

  uri="$TVSH_URI/?random"
  if [ "$dura" != "" ]; then
    uri="$uri&duration=$dura"
  fi
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

  if [ "$city" == "null" ]; then
    city=""
  fi
  if [[ "$state" == "null" || "$state" == "$city" ]]; then
    state=""
  fi
  location="$city $state"

  echo "$asset" "$IMMICH_URL/assets/$asset/original" "$fdura" "$location"
}
