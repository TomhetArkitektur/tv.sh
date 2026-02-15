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
  if [ "$city" == "null" ]; then
    city=""
  fi
  if [[ "$state" == "null" || "$state" == "$city" ]]; then
    state=""
  fi
  location="$city $state"

  echo "$asset" "$IMMICH_URL/assets/$asset/original" 0 "$location"
}
