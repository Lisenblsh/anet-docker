#!/usr/bin/env bash

images=("anet-auth" "anet-server" "anet-keygen" "anet-genconf")

check_image() {
  local value="$1"
  if [[ "all" == "$value" ]]; then
    return 0
  fi

  for item in "${images[@]}"; do
    if [[ "$item" == "$value" ]]; then
      return 0
    fi
  done

  return 1
}

build_image() {
  if [[ "$1" == "all" ]]; then
    for item in "${images[@]}"; do
      build_image $item
    done
  elif [[ "$1" == "anet-genconf" ]]; then
    build_image "anet-keygen"
    docker build -t $1 "./$1"
  else
    docker build -t $1 "./$1"
  fi
}

case $1 in
-b | --build)
  if check_image $2; then
    build_image $2
  else
    echo "No image with name $2"
  fi
  ;;
-a | --addclient)
  docker compose exec anet-auth /app/anet-auth -a $2
  ;;
-g | --genconf)
  docker compose -f ./generate.yml run --rm --remove-orphans anet-genconf
  ;;
-h | --help)
  echo "This is help"
  ;;
*)
  echo "Can't handle it check help -> -h|--help"
  ;;
esac
