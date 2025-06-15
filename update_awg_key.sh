#!/bin/sh

# Скрипт для автоматического обновления ключа AmneziaWG

# 1. Функции для запроса конфигурации WARP (скопированы из AWG_Genetal.sh)
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

# 2. Функция для обработки выполнения запроса (скопирована из AWG_Genetal.sh)
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
				configBase64=$(echo "$content" | jq -r '.configBase64')
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

# 3. Удаление старого ключа
INTERFACE_NAME="awg10"
uci del network.${INTERFACE_NAME}.private_key
uci commit network

# 4. Получение WARP-конфига (скопировано из AWG_Genetal.sh)
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

# 5. Настройка интерфейса AmneziaWG (скопировано из AWG_Genetal.sh)
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

# 6. Перезагрузка сети
/etc/init.d/network restart
service uhttpd restart
/etc/init.d/dnsmasq restart
/etc/init.d/odhcpd restart
service dnsmasq restart
service odhcpd restart
service podkop restart

echo "Successfully updated AmneziaWG key."

exit 0
