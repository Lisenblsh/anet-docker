#!/usr/bin/env bash

images=("anet-auth" "anet-server" "anet-server:local" "anet-keygen" "anet-genconf")

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
  set -x
  path="${1//:/.}"

  image_name="${1%%:*}"
  image_version="${1#*:}"

  if [ -z "$image_version" ]; then
    image_version="latest"
  fi

  if [[ "$1" == "all" ]]; then
    for item in "${images[@]}"; do
      build_image $item
    done
  elif [[ "$1" == "anet-genconf" ]]; then
    build_image "anet-keygen"
    docker build -t $1 -f "./$image_name/Dockerfile.$image_version" "./$image_name"
  else
    docker build -t $1 -f "./$image_name/Dockerfile.$image_version" "./$image_name"
  fi
}

clean_image() {
  if [[ "$1" == "all" ]]; then
    for item in "${images[@]}"; do
      clean_image $item
    done
  elif [[ "$1" == "anet-genconf" ]]; then
    clean_image "anet-keygen"
    docker rmi $1
  else
    docker rmi $1
  fi
}

create_config() {
  addclient_out=$(docker compose exec anet-auth /app/anet-auth -a $1 2>/dev/null)
  private_key=$(echo "$addclient_out" | awk -F'"' '
/private_key/ { print $2 }
')

  domain=$(cat .env | grep DOMAIN | awk -F '=' '/DOMAIN/ {print $2}')
  quic_port=$(cat .env | grep QUIC_PORT | awk -F '=' '/QUIC_PORT/ {print $2}')
  ssh_port=$(cat .env | grep SSH_PORT | awk -F '=' '/SSH_PORT/ {print $2}')
  vnc_port=$(cat .env | grep VNC_PORT | awk -F '=' '/VNC_PORT/ {print $2}')
  server_public_key=$(cat ./generated-keys/public_server_key)

  awk -v domain="$domain" \
    -v quic_port="$quic_port" \
    -v ssh_port="$ssh_port" \
    -v vnc_port="$vnc_port" \
    -v private_key="$private_key" \
    -v server_public_key="$server_public_key" '

/address =/ {
  print "address = \"" domain ":" quic_port "\""
  next
}

/mode =/ {
  print "mode = \"quic\""
  next
}

/private_key =/ {
  print "private_key = \"" private_key "\"" 
  next
}

/server_pub_key =/ {
  print "server_pub_key = \"" server_public_key "\""
  next
}

{ print }

' ./client_template.toml

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
  create_config $2
  ;;
-g | --genconf)
  if [[ "$2" == "source" ]]; then
    docker compose -f ./generate_source.yml run --rm --remove-orphans anet-genconf
  else
    docker compose -f ./generate.yml run --rm --remove-orphans anet-genconf
  fi
  docker rm anet-keygen
  ;;
-c | --clean)
  if check_image $2; then
    clean_image $2
  else
    echo "No image with name $2"
  fi
  ;;
-h | --help)
  echo "-b|--build <image name>         Build image with <image name>"
  echo "-a|--addclient <client name>    Create client with <client name> in anet-auth"
  echo "-g|--genconf                    Generate config file"
  echo "                                With 'source' option script will use Dockerfile instead registry image"
  echo "-c|--clean <image name>         Clean images from local registry"
  echo "-h|--help                       This help message"
  ;;
*)
  echo "Can't handle it check help -> -h|--help"
  ;;
esac
