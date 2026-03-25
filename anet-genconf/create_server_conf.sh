#! /usr/bin/env bash

#set -x
keygen_out=$(/app/anet-keygen server)

eval $(echo "$keygen_out" | awk -F'"' '
/server_signing_key/ { print "server_key=" $2 }
/^Public Key/ { getline; print "public_key=" $0 }
')

auth_token=$AUTH_BACKEND_KEY

openssl req -x509 -newkey ed25519 \
  -keyout key.pem \
  -out cert.pem \
  -days 365 \
  -nodes \
  -subj "/CN=alco" \
  -addext "subjectAltName = DNS:alco" \
  -addext "basicConstraints=critical,CA:FALSE" \
  -addext "keyUsage=digitalSignature,keyEncipherment"

auth_servers='["http://anet-auth:3000/api/v1"]'

awk '
BEGIN {
  cert = ""
  while ((getline line < "cert.pem") > 0) cert = cert line "\n"

  key = ""
  while ((getline line < "key.pem") > 0) key = key line "\n"
}

/quic_cert = """/ {
  print "quic_cert = \"\"\""
  printf "%s", cert
  print "\"\"\""
  skip=1
  next
}

/quic_key = """/ {
  print "quic_key = \"\"\""
  printf "%s", key
  print "\"\"\""
  skip=2
  next
}

skip && /"""/ {
  skip=0
  next
}

!skip { print }
' server_template.toml >server_temp.toml

awk -v signing_key="$server_key" \
  -v auth_token="$auth_token" \
  -v auth_servers="$auth_servers" \
  -v if_name="$ANET_TUN" \
  -v SSH_PORT="$SSH_PORT" \
  -v QUIC_PORT="$QUIC_PORT" '

/server_signing_key =/ {
  print "server_signing_key = \"" signing_key "\""
  next
}

/auth_server_token =/ {
  print "auth_server_token = \"" auth_token "\""
  next
}

/auth_servers =/ {
  print "auth_servers = " auth_servers
  next
}

/if_name =/ {
  print "if_name = \"" if_name "\""
  next
}

/quicbind_to =/ {
  print "quicbind_to = \"0.0.0.0:" QUIC_PORT "\""
  next
}

/ssh_bind_to =/ {
  print "ssh_bind_to = \"0.0.0.0:" SSH_PORT "\""
  next
}

{ print }

' server_temp.toml >./config/server.toml

rm server_temp.toml

echo $server_key >server_signing_key
echo $public_key >public_server_key

mv ./public_server_key ./server_signing_key ./cert.pem ./key.pem ./keys

echo "Add server.toml to docker-compose.yml for anet-server"
echo "Save cert.pem, key.pem, server_signing_key and public_key files securely"
