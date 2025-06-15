#!/bin/sh

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

#проверяем установлени ли библиотека https-dns-proxy
printf "\033[32;1mInstalling https-dns-proxy...\033[0m\n"
opkg update
checkPackageAndInstall()
{
    local name="$1"
    local isRequried="$2"
    #проверяем установлени ли библиотека $name
    if opkg list-installed | grep -q $name; then
        echo "$name already installed..."
    else
        echo "$name not installed. Installed $name..."
        opkg install $name
		res=$?
		if [ "$isRequried" = "1" ]; then
			if [ $res -eq 0 ]; then
				echo "$name insalled successfully"
			else
				echo "Error installing $name. Please, install $name manually and run the script again"
				exit 1
			fi
		fi
    fi
}
checkPackageAndInstall "coreutils-base64" "1"
checkPackageAndInstall "https-dns-proxy" "1"
checkPackageAndInstall "luci-app-https-dns-proxy" "0"
checkPackageAndInstall "luci-i18n-https-dns-proxy-ru" "0"

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

printf "\033[32;1mConfigure dhcp...\033[0m\n"
uci set dhcp.cfg01411c.strictorder='1'
uci set dhcp.cfg01411c.filter_aaaa='1'
uci add_list dhcp.cfg01411c.server='127.0.0.1#5053'
uci add_list dhcp.cfg01411c.server='127.0.0.1#5054'
uci add_list dhcp.cfg01411c.server='127.0.0.1#5055'
uci add_list dhcp.cfg01411c.server='127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.chatgpt.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.oaistatic.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.oaiusercontent.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.openai.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.microsoft.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.windowsupdate.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.bing.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.supercell.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.seeurlpcl.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.supercellid.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.supercellgames.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.clashroyale.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.brawlstars.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.clash.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.clashofclans.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.x.ai/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.grok.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.github.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.forzamotorsport.net/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.forzaracingchampionship.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.forzarc.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.gamepass.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.orithegame.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.renovacionxboxlive.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.tellmewhygame.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox.co/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox.eu/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox.org/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox360.co/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox360.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox360.eu/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbox360.org/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxab.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxgamepass.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxgamestudios.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxlive.cn/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxlive.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxone.co/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxone.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxone.eu/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxplayanywhere.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxservices.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xboxstudios.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.xbx.lv/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.sentry.io/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.usercentrics.eu/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.recaptcha.net/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.gstatic.com/127.0.0.1#5056'
uci add_list dhcp.cfg01411c.server='/*.brawlstarsgame.com/127.0.0.1#5056'
uci commit dhcp

printf "\033[32;1mAdd unblock ChatGPT...\033[0m\n"

checkAndAddDomainPermanentName()
{
  nameRule="option name '$1'"
  str=$(grep -i "$nameRule" /etc/config/dhcp)
  if [ -z "$str" ] 
  then 

    uci add dhcp domain
    uci set dhcp.@domain[-1].name="$1"
    uci set dhcp.@domain[-1].ip="$2"
    uci commit dhcp
  fi
}

checkAndAddDomainPermanentName "chatgpt.com" "83.220.169.155"
checkAndAddDomainPermanentName "openai.com" "83.220.169.155"
checkAndAddDomainPermanentName "webrtc.chatgpt.com" "83.220.169.155"
checkAndAddDomainPermanentName "ios.chat.openai.com" "83.220.169.155"
checkAndAddDomainPermanentName "searchgpt.com" "83.220.169.155"

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
  service firewall restart
fi

printf  "\033[32;1mRestart service dnsmasq, odhcpd...\033[0m\n"
service dnsmasq restart
service odhcpd restart

printf  "\033[32;1mRestart firewall...\033[0m\n"
service firewall restart

# Перезапуск всей сети
printf "\033[32;1mRestarting network services...\033[0m\n"
/etc/init.d/network restart

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

# Перезапуск всей сети
printf "\033[32;1mRestarting network services...\033[0m\n"
/etc/init.d/network restart

printf  "\033[32;1mRestarting LuCI web server...\033[0m\n"
service uhttpd restart

printf  "\033[32;1mRestart service podkop...\033[0m\n"
service podkop restart

manage_package() {
    local name="$1"
    local autostart="$2"
    local process="$3"

    # Проверка, установлен ли пакет
    if opkg list-installed | grep -q "^$name"; then
        
        # Проверка, включен ли автозапуск
        if /etc/init.d/$name enabled; then
            if [ "$autostart" = "disable" ]; then
                /etc/init.d/$name disable
            fi
        else
            if [ "$autostart" = "enable" ]; then
                /etc/init.d/$name enable
            fi
        fi

        # Проверка, запущен ли процесс
        if pidof $name > /dev/null; then
            if [ "$process" = "stop" ]; then
                /etc/init.d/$name stop
            fi
        else
            if [ "$process" = "start" ]; then
                /etc/init.d/$name start
            fi
        fi
    fi
}

manage_package "https-dns-proxy" "enable" "start"

printf  "\033[32;1mConfigured completed...\033[0m\n"

cat <<EOF >> /etc/config/https-dns-proxy
config main 'config'
	option canary_domains_icloud '1'
	option canary_domains_mozilla '1'
	option dnsmasq_config_update '*'
	option force_dns '1'
	list force_dns_port '53'
	list force_dns_port '853'
	option procd_trigger_wan6 '0'

config https-dns-proxy
	option resolver_url 'https://dns.adguard-dns.com/dns-query'
	option bootstrap_dns '94.140.14.14,94.140.15.15'
	option listen_addr '127.0.0.1'
	option listen_port '5053'

config https-dns-proxy
	option resolver_url 'https://dns.google/dns-query'
	option bootstrap_dns '8.8.8.8,8.8.4.4'
	option listen_addr '127.0.0.1'
	option listen_port '5054'

config https-dns-proxy
	option resolver_url 'https://cloudflare-dns.com/dns-query'
	option bootstrap_dns '1.1.1.1,1.0.0.1'
	option listen_addr '127.0.0.1'
	option listen_port '5055'

config https-dns-proxy
	option resolver_url 'https://router.comss.one/dns-query'
	option bootstrap_dns '195.133.25.16,212.109.195.93'
	option listen_addr '127.0.0.1'
	option listen_port '5056'
EOF

printf  "\033[32;1mRestart service https-dns-proxy...\033[0m\n"
service https-dns-proxy restart

printf  "\033[32;1mRestart service dnsmasq, odhcpd...\033[0m\n"
service dnsmasq restart
service odhcpd restart

printf  "\033[32;1mRestart firewall...\033[0m\n"
service firewall restart

# Перезапуск всей сети
printf "\033[32;1mRestarting network services...\033[0m\n"
/etc/init.d/network restart

printf  "\033[32;1mRestarting LuCI web server...\033[0m\n"
service uhttpd restart
