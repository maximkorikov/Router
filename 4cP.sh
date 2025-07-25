#!/bin/sh

# 1. Установка Podkop v0.2.5
printf "\033[32;1mInstalling Podkop v0.2.5...\033[0m\n"
(echo "3"; echo "n"; echo "y") | sh <(wget -O - https://raw.githubusercontent.com/itdoginfo/podkop/a6a171ef47d0ea91d046a9d613570b2a7c952b0d/install.sh | sed 's|https://api.github.com/repos/itdoginfo/podkop/releases/latest|https://api.github.com/repos/itdoginfo/podkop/releases/tags/v0.2.5|g')

# 2. Получение конфигурации из 1.conf
printf "\033[32;1mGetting config from https://raw.githubusercontent.com/maximkorikov/Router/refs/heads/main/1.conf...\033[0m\n"
config_file=$(curl -s https://raw.githubusercontent.com/maximkorikov/Router/refs/heads/main/1.conf)

# Extracting variables from config file
PrivateKey=$(echo "$config_file" | grep "PrivateKey" | cut -d'=' -f2 | tr -d ' ')
S1=$(echo "$config_file" | grep "S1" | cut -d'=' -f2 | tr -d ' ')
S2=$(echo "$config_file" | grep "S2" | cut -d'=' -f2 | tr -d ' ')
Jc=$(echo "$config_file" | grep "Jc" | cut -d'=' -f2 | tr -d ' ')
Jmin=$(echo "$config_file" | grep "Jmin" | cut -d'=' -f2 | tr -d ' ')
Jmax=$(echo "$config_file" | grep "Jmax" | cut -d'=' -f2 | tr -d ' ')
H1=$(echo "$config_file" | grep "H1" | cut -d'=' -f2 | tr -d ' ')
H2=$(echo "$config_file" | grep "H2" | cut -d'=' -f2 | tr -d ' ')
H3=$(echo "$config_file" | grep "H3" | cut -d'=' -f2 | tr -d ' ')
H4=$(echo "$config_file" | grep "H4" | cut -d'=' -f2 | tr -d ' ')
MTU=$(echo "$config_file" | grep "MTU" | cut -d'=' -f2 | tr -d ' ')
Address=$(echo "$config_file" | grep "Address" | cut -d'=' -f2 | tr -d ' ')
DNS=$(echo "$config_file" | grep "DNS" | cut -d'=' -f2 | tr -d ' ')
PublicKey=$(echo "$config_file" | grep "PublicKey" | cut -d'=' -f2 | tr -d ' ')
AllowedIPs=$(echo "$config_file" | grep "AllowedIPs" | cut -d'=' -f2 | tr -d ' ')
Endpoint=$(echo "$config_file" | grep "Endpoint" | cut -d'=' -f2 | tr -d ' ')

#вытаскиваем нужные нам данные из распарсинного ответа
EndpointIP=$(echo "$Endpoint" | cut -d':' -f1)
EndpointPort=$(echo "$Endpoint" | cut -d':' -f2)

# 3. Настройка интерфейса AmneziaWG (адаптировано из AWG.txt)
printf "\033[32;1mCreate and configure tunnel AmneziaWG...\033[0m\n"

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
uci set network.${INTERFACE_NAME}.private_key=$PrivateKey
uci set network.${INTERFACE_NAME}.public_key=""
uci del network.${INTERFACE_NAME}.addresses
uci add_list network.${INTERFACE_NAME}.addresses=$Address
uci set network.${INTERFACE_NAME}.mtu=$MTU
uci set network.${INTERFACE_NAME}.awg_jc=$Jc
uci set network.${INTERFACE_NAME}.awg_jmin=$Jmin
uci set network.${INTERFACE_NAME}.awg_jmax=$Jmax
uci set network.${INTERFACE_NAME}.awg_s1=$S1
uci set network.${INTERFACE_NAME}.awg_s2=$S2
uci set network.${INTERFACE_NAME}.awg_h1=$H1
uci set network.${INTERFACE_NAME}.awg_h2=$H2
uci set network.${INTERFACE_NAME}.awg_h3=$H3
uci set network.${INTERFACE_NAME}.awg_h4=$H4
uci set network.${INTERFACE_NAME}.nohostroute='1'
uci set network.@${CONFIG_NAME}[-1].description="${INTERFACE_NAME}_peer"
uci set network.@${CONFIG_NAME}[-1].public_key=$PublicKey
uci set network.@${CONFIG_NAME}[-1].endpoint_host=$EndpointIP
uci set network.@${CONFIG_NAME}[-1].endpoint_port=$EndpointPort
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

printf  "\033[32;1mRestarting LuCI web server...\033[0m\n"
service uhttpd restart
/etc/init.d/dnsmasq restart
/etc/init.d/odhcpd restart
service dnsmasq restart
service odhcpd restart
service podkop restart

printf  "\033[32;1mConfigured completed...\033[0m\n"
