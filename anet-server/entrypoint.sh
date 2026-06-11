#!/bin/sh
set -e

EXT_IF=eth0

# Создаём свои цепочки (если уже есть — просто очищаем)
iptables -N VPN_RULES 2>/dev/null || true
iptables -F VPN_RULES

iptables -t nat -N VPN_NAT 2>/dev/null || true
iptables -t nat -F VPN_NAT

# Подключаем свои цепочки только если ещё не подключены
iptables -C INPUT -j VPN_RULES 2>/dev/null ||
  iptables -I INPUT -j VPN_RULES

iptables -C FORWARD -j VPN_RULES 2>/dev/null ||
  iptables -I FORWARD -j VPN_RULES

iptables -t nat -C POSTROUTING -j VPN_NAT 2>/dev/null ||
  iptables -t nat -I POSTROUTING -j VPN_NAT

# Разрешаем входящий VPN
iptables -A VPN_RULES \
  -p udp --dport "$QUIC_PORT" \
  -j ACCEPT

iptables -A VPN_RULES \
  -p tcp --dport "$SSH_PORT" \
  -j ACCEPT

iptables -A VPN_RULES \
  -p tcp --dport "$VNC_PORT" \
  -j ACCEPT

# FORWARD VPN-туннель <-> внешний интерфейс
iptables -A VPN_RULES \
  -i "$EXT_IF" \
  -o "$ANET_TUN" \
  -j ACCEPT

iptables -A VPN_RULES \
  -i "$ANET_TUN" \
  -o "$EXT_IF" \
  -j ACCEPT

# NAT только для VPN-трафика
iptables -t nat -A VPN_NAT \
  -o "$EXT_IF" \
  -j MASQUERADE

# запуск сервера
exec "$@"
