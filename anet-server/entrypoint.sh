#!/bin/sh
set -e

EXT_IF=eth0
VPN_IF=anet-server

# чистим (чтобы не дублировать при рестарте)
iptables -F
iptables -t nat -F

# Разрешаем входящий VPN
iptables -I INPUT -p udp --dport $QUIC_PORT -j ACCEPT
iptables -I INPUT -p tcp --dport $SSH_PORT -j ACCEPT

# FORWARD туда-обратно
iptables -I FORWARD -i $EXT_IF -o $ANET_TUN -j ACCEPT
iptables -I FORWARD -i $ANET_TUN -o $EXT_IF -j ACCEPT

# NAT
iptables -t nat -A POSTROUTING -o $EXT_IF -j MASQUERADE

# запуск твоего сервера
exec "$@"
