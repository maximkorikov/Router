#!/bin/sh

# Загрузка и запуск скрипта для удаления предыдущей установки (если есть)
printf "\033[32;1mDownloading and running uninstallation script (if it exists)...\033[0m\n"
wget -q -O /tmp/uninstall_podkop_awg.sh https://raw.githubusercontent.com/maximkorikov/Router/refs/heads/main/uninstall_podkop_awg.sh && chmod +x /tmp/uninstall_podkop_awg.sh && sh /tmp/uninstall_podkop_awg.sh || echo "Uninstallation script not found or failed."

# 1. Установка Podkop v0.2.5
printf "\033[32;1mInstalling Podkop v0.2.5...\033[0m\n"
(echo "3"; echo "n"; echo "y") | sh <(wget -O - https://raw.githubusercontent.com/itdoginfo/podkop/a6a171ef47d0ea91d046a9d613570b2a7c952b0d/install.sh | sed 's|https://api.github.com/repos/itdoginfo/podkop/releases/latest|https://api.github.com/repos/itdoginfo/podkop/releases/tags/v0.2.5|g')

# 2. Функции для запроса конфигурации WARP (скопированы из AWG.txt)
requestConfWARP1()
{
	#запрос конфигурации WARP
	local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://warp.llimonix.pw/api/warp' \
	  -H 'Accept: */*' \
	  -H 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' \
	  -H 'Connection: keep-alive' \
	  -H 'Content-Type: application/json' \
	  -H 'Origin: https://warp.llimonix.pw' \
	  -H 'Referer: https://warp.llimonix.pw/' \
	  -H 'Sec-Fetch-Dest: empty' \
	  -H 'Sec-Fetch-Mode: cors' \
	  -H 'Sec-Fetch-Site: same-origin' \
	  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
	  -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133")' \
	  -H 'sec-ch-ua-mobile: ?0' \
	  -H 'sec-ch-ua-platform: "Windows"' \
	  --data-raw '{"selectedServices":[],"siteMode":"all","deviceType":"computer"}')
	echo "$result"
}

requestConfWARP2()
{
	#запрос конфигурации WARP
	local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://topor-warp.vercel.app/generate' \
	  -H 'Accept: */*' \
	  -H 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' \
	  -H 'Connection: keep-alive' \
	  -H 'Content-Type: application/json' \
	  -H 'Origin: https://topor-warp.vercel.app' \
	  -H 'Referer: https://topor-warp.vercel.app/' \
	  -H 'Sec-Fetch-Dest: empty' \
	  -H 'Sec-Fetch-Mode: cors' \
	  -H 'Sec-Fetch-Site: same-origin' \
	  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
	  -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
	  -H 'sec-ch-ua-mobile: ?0' \
	  -H 'sec-ch-ua-platform: "Windows"' \
	  --data-raw '{"platform":"all"}')
	echo "$result"
}

requestConfWARP3()
{
	#запрос конфигурации WARP
	local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://warp-gen.vercel.app/generate-config' \
		-H 'Accept: */*' \
		-H 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' \
		-H 'Connection: keep-alive' \
		-H 'Referer: https://warp-gen.vercel.app/' \
		-H 'Sec-Fetch-Dest: empty' \
		-H 'Sec-Fetch-Mode: cors' \
		-H 'Sec-Fetch-Site: same-origin' \
		-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
		-H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
		-H 'sec-ch-ua-mobile: ?0' \
		-H 'sec-ch-ua-platform: "Windows"')
	echo "$result"
}

requestConfWARP4()
{
	#запрос конфигурации WARP
	local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://config-generator-warp.vercel.app/warp' \
	  -H 'Accept: */*' \
	  -H 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' \
	  -H 'Connection: keep-alive' \
	  -H 'Referer: https://config-generator-warp.vercel.app/' \
	  -H 'Sec-Fetch-Dest: empty' \
	  -H 'Sec-Fetch-Mode: cors' \
	  -H 'Sec-Fetch-Site: same-origin' \
	  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36' \
	  -H 'sec-ch-ua: "Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"' \
	  -H 'sec-ch-ua-mobile: ?0' \
	  -H 'sec-ch-ua-platform: "Windows"')
	echo "$result"
}

# Функция для обработки выполнения запроса
check_request() {
    local response="$1"
	local choice="$2"
	
    # Извлекаем код состояния
    response_code="${response: -3}"  # Последние 3 символа - это код состояния
    response_body="${response%???}"    # Все, кроме последних 3 символов - это тело ответа
    #echo $response_body
	#echo $response_code
    # Проверяем код состояния
    if [ "$response_code" -eq 200 ]; then
		case $choice in
		1)
			status=$(echo $response_body | jq '.success')
			#echo "$status"
			if [ "$status" = "true" ]
			then
				content=$(echo $response_body | jq '.content')
				configBase64=$(echo $content | jq -r '.configBase64')
				warpGen=$(echo "$configBase64" | base64 -d)
				echo "$warpGen";
			else
				echo "Error"
			fi
            ;;
		2)
			echo "$response_body"
            ;;
		3)
			content=$(echo $response_body | jq -r '.config')
			#content=$(echo "$content" | sed 's/\\n/\012/g')
			echo "$content"
            ;;
		4)
			content=$(echo $response_body | jq -r '.content')  
            warp_config=$(echo "$content" | base64 -d)
            echo "$warp_config"
            ;;
		*)
			echo "Error"
		esac
	else
		echo "Error"
	fi
}

# 3. Генерация ключа и настройка интерфейса AmneziaWG (адаптировано из AWG.txt)
# 3. Генерация ключа и настройка интерфейса AmneziaWG (адаптировано из AWG.txt)
# Автоматическая генерация WARP-конфига
warp_config="Error"
printf "\033[32;1mRequest WARP config... Attempt #1\033[0m\n"
result=$(requestConfWARP1)
warpGen=$(check_request "$result" 1)
if [ "$warpGen" = "Error" ]
then
	printf "\033[32;1mRequest WARP config... Attempt #2\033[0m\n"
	result=$(requestConfWARP2)
	warpGen=$(check_request "$result" 2)
	if [ "$warpGen" = "Error" ]
	then
		printf "\033[32;1mRequest WARP config... Attempt #3\033[0m\n"
		result=$(requestConfWARP3)
		warpGen=$(check_request "$result" 3)
		if [ "$warpGen" = "Error" ]
		then
			printf "\033[32;1mRequest WARP config... Attempt #4\033[0m\n"
			result=$(requestConfWARP4)
			warpGen=$(check_request "$result" 4)
			if [ "$warpGen" = "Error" ]
			then
				warp_config="Error"
			else
				warp_config=$warpGen
			fi
		else
			warp_config=$warpGen
		fi
	else
		warp_config=$warpGen
	fi

else
	warp_config=$warpGen
fi

if [ "$warp_config" = "Error" ]
then
	printf "\033[32;1mGenerate config AWG WARP failed...Try again later...\033[0m\n"
	exit 1
else
	while IFS=' = ' read -r line; do
	if echo "$line" | grep -q "="; then
		# Разделяем строку по первому вхождению "="
		key=$(echo "$line" | cut -d'=' -f1 | xargs)  # Убираем пробелы
		value=$(echo "$line" | cut -d'=' -f2- | xargs)  # Убираем пробелы
		#echo "key = $key, value = $value"
		eval "$key=\"$value\""
	fi
	done < <(echo "$warp_config")

	#вытаскиваем нужные нам данные из распарсинного ответа
	Address=$(echo "$Address" | cut -d',' -f1)
	DNS=$(echo "$DNS" | cut -d',' -f1)
	AllowedIPs=$(echo "$AllowedIPs" | cut -d',' -f1)
	EndpointIP=$(echo "$Endpoint" | cut -d':' -f1)
	EndpointPort=$(echo "$Endpoint" | cut -d':' -f2)
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
uci set network.${INTERFACE_NAME}.private_key=$PrivateKey
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

# Настройка cron-задачи для обновления ключа AmneziaWG
printf "\033[32;1mSetting up cron job to update AmneziaWG key daily at 04:00...\033[0m\n"
wget -O /root/update_awg_key.sh https://raw.githubusercontent.com/maximkorikov/Router/refs/heads/main/update_awg_key.sh
chmod +x /root/update_awg_key.sh
( crontab -l | grep -v "update_awg_key.sh" ; echo "0 4 * * * /root/update_awg_key.sh" ) | crontab -

printf  "\033[32;1mConfigured completed...\033[0m\n"
