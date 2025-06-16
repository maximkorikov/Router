#!/bin/sh

# 1. Установка Podkop v0.2.5
printf "\033[32;1mInstalling Podkop v0.2.5...\033[0m\n"
(echo "3"; echo "n"; echo "y") | sh <(wget -O - https://raw.githubusercontent.com/itdoginfo/podkop/a6a171ef47d0ea91d046a9d613570b2a7c952b0d/install.sh | sed 's|https://api.github.com/repos/itdoginfo/podkop/releases/latest|https://api.github.com/repos/itdoginfo/podkop/releases/tags/v0.2.5|g')

# 2. Функция для загрузки конфигурации WARP из файла
get_warp_config() {
  warp_config=$(curl -s https://raw.githubusercontent.com/maximkorikov/Router/refs/heads/main/1.conf)
  echo "$warp_config"
}

# Функция для обработки конфигурации WARP
process_warp_config() {
  local warp_config="$1"

  # Разделяем конфигурацию на секции Interface и Peer
  interface_config=$(echo "$warp_config" | grep -A 8 "^[Interface]")
  peer_config=$(echo "$warp_config" | grep -A 4 "^[Peer]")

  # Парсим секцию Interface
  while IFS=' = ' read -r line; do
    if echo "$line" | grep -q "="; then
      key=$(echo "$line" | cut -d'=' -f1 | xargs)
      value=$(echo "$line" | cut -d'=' -f2- | xargs)
      eval "INTERFACE_$key=\"$value\""
    fi
  done < <(echo "$interface_config")

  # Парсим секцию Peer
  while IFS=' = ' read -r line; do
    if echo "$line" | grep -q "="; then
      key=$(echo "$line" | cut -d'=' -f1 | xargs)
      value=$(echo "$line" | cut -d'=' -f2- | xargs)
      eval "PEER_$key=\"$value\""
    fi
  done < <(echo "$peer_config")

  # Вытаскиваем нужные данные
  INTERFACE_Address=$(echo "$INTERFACE_Address" | cut -d',' -f1)
  INTERFACE_DNS=$(echo "$INTERFACE_DNS" | cut -d',' -f1)
  PEER_AllowedIPs=$(echo "$PEER_AllowedIPs" | cut -d',' -f1)
  PEER_Endpoint=$(echo "$PEER_Endpoint" | cut -d':' -f1)
  PEER_EndpointPort=$(echo "$PEER_Endpoint" | cut -d':' -f2)
}

# 3. Генерация ключа и настройка интерфейса AmneziaWG (адаптировано из AWG.txt)
printf "\033[32;1mGetting WARP config from file...\033[0m\n"
warp_config=$(get_warp_config)

if [ -z "$warp_config" ]
then
  printf "\033[32;1mFailed to get WARP config from file...\033[0m\n"
  exit 1
else
  process_warp_config "$warp_config"
fi

printf "\033[32;1mCreate and configure tunnel AmneziaWG WARP...\033[0m\n"

#задаём имя интерфейса
INTERFACE_NAME="awg10"
CONFIG_NAME="amneziawg_awg10"
PROTO="amneziawg"
ZONE_NAME="awg"

uci set network.${INTERFACE_NAME}=interface
uci set network.${INTERFACE_NAME}.proto=$PROTO
if ! uci show network | grep -q ${CONFIG_NAME}; then
  uci add network ${CONFIG_NAME}
fi
uci set network.${INTERFACE_NAME}.private_key=$INTERFACE_PrivateKey
uci del network.${INTERFACE_NAME}.addresses
uci add_list network.${INTERFACE_NAME}.addresses=$INTERFACE_Address
uci set network.${INTERFACE_NAME}.mtu=$INTERFACE_MTU
uci set network.${INTERFACE_NAME}.awg_jc=$INTERFACE_Jc
uci set network.${INTERFACE_NAME}.awg_jmin=$INTERFACE_Jmin
uci set network.${INTERFACE_NAME}.awg_jmax=$INTERFACE_Jmax
uci set network.${INTERFACE_NAME}.awg_s1=$INTERFACE_S1
uci set network.${INTERFACE_NAME}.awg_s2=$INTERFACE_S2
uci set network.${INTERFACE_NAME}.awg_h1=$INTERFACE_H1
uci set network.${INTERFACE_NAME}.awg_h2=$INTERFACE_H2
uci set network.${INTERFACE_NAME}.awg_h3=$INTERFACE_H3
uci set network.${INTERFACE_NAME}.awg_h4=$INTERFACE_H4
uci set network.${INTERFACE_NAME}.nohostroute='1'
uci set network.@${CONFIG_NAME}[-1].description="${INTERFACE_NAME}_peer"
uci set network.@${CONFIG_NAME}[-1].public_key=$PEER_PublicKey
uci set network.@${CONFIG_NAME}[-1].endpoint_host=$PEER_Endpoint
uci set network.@${CONFIG_NAME}[-1].endpoint_port=$PEER_EndpointPort
uci set network.@${CONFIG_NAME}[-1].persistent_keepalive='25'
uci set network.@${CONFIG_NAME}[-1].allowed_ips='0.0.0.0/0'
uci set network.@${CONFIG_NAME}[-1].route_allowed_ips='0'
uci commit network

# Загрузка модуля ядра AmneziaWG (если не загружен)
modprobe amneziawg

# Перезапуск службы netifd для применения изменений
service netifd restart

# Проверка статуса интерфейса awg10
printf "\033[32;1mChecking status of awg10 interface...\033[0m\n"
ip link show awg10 || echo "Interface awg10 not found or not active."

if ! uci show firewall | grep -q "@zone.*name='${ZONE_NAME}'"; then
  printf "\033[32;1mZone Create\033[0m\n"
  uci add firewall zone
  uci set firewall.@zone[-1].name=$ZONE_NAME
  uci set firewall.@zone[-1].network=$INTERFACE_NAME
  uci set firewall.@zone[-1].forward='REJECT'
  uci set firewall.@zone[-1].output='ACCEPT'
  uci set firewall.@zone[-1].input='REJECT'
  uci set firewall.@zone[-1].masq='1'
  uci set firewall.@zone[-1].mtu_fix='1'
  uci set firewall.@zone[-1].family='ipv4'
  uci commit firewall
fi

if ! uci show firewall | grep -q "@forwarding.*name='${ZONE_NAME}'"; then
  printf "\033[32;1mConfigured forwarding\033[0m\n"
  uci add firewall forwarding
  uci set firewall.@forwarding[-1]=forwarding
  uci set firewall.@forwarding[-1].name="${ZONE_NAME}"
  uci set firewall.@forwarding[-1].dest=${ZONE_NAME}
  uci set firewall.@forwarding[-1].src='lan'
  uci set firewall.@forwarding[-1].family='ipv4'
  uci commit firewall
fi

# Получаем список всех зон
ZONES=$(uci show firewall | grep "zone$" | cut -d'=' -f1)
#echo $ZONES
# Циклически проходим по всем зонам
for zone in $ZONES; do
  # Получаем имя зоны
  CURR_ZONE_NAME=$(uci get $zone.name)
  #echo $CURR_ZONE_NAME
  # Проверяем, является ли это зона с именем "$ZONE_NAME"
  if [ "$CURR_ZONE_NAME" = "$ZONE_NAME" ]; then
    # Проверяем, существует ли интерфейс в зоне
    if ! uci get $zone.network | grep -q "$INTERFACE_NAME"; then
      # Добавляем интерфейс в зону
      uci add_list $zone.network="$INTERFACE_NAME"
      uci commit firewall
      #echo "Интерфейс '$INTERFACE_NAME' добавлен в зону '$ZONE_NAME'"
    fi
  fi
done

nameRule="option name 'Block_UDP_443'"
str=$(grep -i "$nameRule" /etc/config/firewall)
if [ -z "$str" ]
then
  echo "Add block QUIC..."

  uci add firewall rule # =cfg2492bd
  uci set firewall.@rule[-1].name='Block_UDP_80'
  uci add_list firewall.@rule[-1].proto='udp'
  uci set firewall.@rule[-1].src='lan'
  uci set firewall.@rule[-1].dest='wan'
  uci set firewall.@rule[-1].dest_port='80'
  uci set firewall.@rule[-1].target='REJECT'
  uci add firewall rule # =cfg2592bd
  uci set firewall.@rule[-1].name='Block_UDP_443'
  uci add_list firewall.@rule[-1].proto='udp'
  uci set firewall.@rule[-1].src='lan'
  uci set firewall.@rule[-1].dest='wan'
  uci set firewall.@rule[-1].dest_port='443'
  uci set firewall.@rule[-1].target='REJECT'
  uci commit firewall
fi

printf  "\033[32;1mRestart service dnsmasq, odhcpd...\033[0m\n"
service dnsmasq restart
service odhcpd restart

printf  "\033[32;1mRestart firewall...\033[0m\n"
service firewall restart

# Установка и настройка Stubby
printf "\033[32;1mInstalling and configuring Stubby...\033[0m\n"
opkg update && opkg install stubby
uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].filter_aaaa="1"
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#5453"
uci commit dhcp
service dnsmasq restart
echo -e "ntpd -q -p ptbtime1.ptb.de\nsleep 5\n/etc/init.d/stubby restart\nexit 0" > /etc/rc.local && chmod +x /etc/rc.local && /etc/init.d/stubby restart

# Перезапуск всей сети
printf "\033[32;1mRestarting network services...\033[0m\n"
/etc/init.d/network restart

printf  "\033[32;1mConfigured completed...\033[0m\n"
