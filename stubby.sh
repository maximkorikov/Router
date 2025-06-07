#!/bin/bash

set -e

echo "Устанавливаем stubby..."
sudo apt update
sudo apt install -y stubby

echo "Создаем резервную копию конфигурации stubby..."
sudo cp /etc/stubby/stubby.yml /etc/stubby/stubby.yml.bak

echo "Записываем конфигурацию для Comss.one..."

sudo tee /etc/stubby/stubby.yml > /dev/null <<EOF
resolution_type: GETDNS_RESOLUTION_STUB
dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
tls_query_padding_blocksize: 128
edns_client_subnet_private: 1
idle_timeout: 10000
round_robin_upstreams: 1
upstream_recursive_servers:
  - address_data: 195.133.25.16
    tls_auth_name: "dns.comss.one"
    tls_pubkey_pinset:
      - digest: "sha256"
        value: "L7vbd4mv54UEzB3R9d1gi7W7QazRv+PZmn4v71JoXqg4="
    port: 853
  - address_data: 195.133.25.16
    tls_auth_name: "dns.comss.one"
    port: 853
EOF

echo "Перезапускаем stubby..."
sudo systemctl restart stubby

echo "Настраиваем systemd-resolved использовать локальный stubby..."

sudo tee /etc/systemd/resolved.conf > /dev/null <<EOL
[Resolve]
DNS=127.0.0.1
DNSOverTLS=yes
FallbackDNS=1.1.1.1 8.8.8.8
EOL

echo "Перезапускаем systemd-resolved..."
sudo systemctl restart systemd-resolved

echo "Проверяем статус..."
resolvectl status | grep 'DNS Servers' -A2

echo "Готово! Теперь DNS-запросы идут через Comss.one DNS-over-TLS."
