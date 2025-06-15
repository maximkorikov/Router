#!/bin/sh

# Модифицированный URL для установки Podkop
REPO="https://api.github.com/repos/itdoginfo/podkop/releases/tags/v0.2.5"

IS_SHOULD_RESTART_NETWORK=
DOWNLOAD_DIR="/tmp/podkop"
mkdir -p "$DOWNLOAD_DIR"

# Функции для генерации конфигурации AWG WARP (скопированы из awg generate.sh)
requestConfWARP1()
{
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

check_request() {
    local response="$1"
	local choice="$2"
	
    response_code="${response: -3}"
    response_body="${response%???}"
    if [ "$response_code" -eq 200 ]; then
		case $choice in
		1)
			status=$(echo "$response_body" | jq '.success')
			if [ "$status" = "true" ]
			then
				content=$(echo "$response_body" | jq '.content')
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
			content=$(echo "$response_body" | jq -r '.config')
			echo "$content"
            ;;
		4)
			content=$(echo "$response_body" | jq -r '.content')  
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

main() {
    check_system

    # Установка curl и jq, необходимых для генерации WARP конфига
    opkg update
    opkg install curl
    opkg install jq

    wget -qO- "$REPO" | grep -o 'https://[^"]*\.ipk' | while read -r url; do
        filename=$(basename "$url")
        echo "Download $filename..."
        wget -q -O "$DOWNLOAD_DIR/$filename" "$url"
    done

    echo "opkg update"
    opkg update

    if opkg list-installed | grep -q dnsmasq-full; then
        echo "dnsmasq-full already installed"
    else
        echo "Installed dnsmasq-full"
        cd /tmp/ && opkg download dnsmasq-full
        opkg remove dnsmasq && opkg install dnsmasq-full --cache /tmp/

        [ -f /etc/config/dhcp-opkg ] && cp /etc/config/dhcp /etc/config/dhcp-old && mv /etc/config/dhcp-opkg /etc/config/dhcp
    fi

    openwrt_release=$(cat /etc/openwrt_release | grep -Eo [0-9]{2}[.][0-9]{2}[.][0-9]* | cut -d '.' -f 1 | tail -n 1)
    if [ $openwrt_release -ge 24 ]; then
        if uci get dhcp.@dnsmasq[0].confdir | grep -q /tmp/dnsmasq.d; then
            echo "confdir alreadt set"
        else
            printf "Setting confdir"
            uci set dhcp.@dnsmasq[0].confdir='/tmp/dnsmasq.d'
            uci commit dhcp
        fi
    fi
    
    if [ -f "/etc/init.d/podkop" ]; then
        printf "\033[32;1mPodkop is already installed. Just upgrade it? (y/n)\033[0m\n"
        printf "\033[32;1my - Only upgrade podkop\033[0m\n"
        printf "\033[32;1mn - Upgrade and install proxy or tunnels\033[0m\n"

        # Автоматический выбор "n" для установки прокси или туннелей
        UPDATE="n"
        echo "$UPDATE" # Эмулируем ввод пользователя
        case $UPDATE in
        y)
            echo "Upgraded podkop..."
            break
            ;;

        n)
            add_tunnel
            break
            ;;

        *)
            echo "Please enter y or n"
            ;;
        esac
    else
        echo "Installed podkop..."
        add_tunnel
    fi

    opkg install $DOWNLOAD_DIR/podkop*.ipk
    opkg install $DOWNLOAD_DIR/luci-app-podkop*.ipk

    echo "Русский язык интерфейса ставим? y/n (Need a Russian translation?)"
    # Автоматический выбор "y" для русского языка
    RUS="y"
    echo "$RUS" # Эмулируем ввод пользователя
    while true; do
        case $RUS in
        y)
            opkg install $DOWNLOAD_DIR/luci-i18n-podkop-ru*.ipk
            break
            ;;

        n)
            break
            ;;

        *)
            echo "Please enter y or n"
            ;;
        esac
    done

    rm -f $DOWNLOAD_DIR/podkop*.ipk $DOWNLOAD_DIR/luci-app-podkop*.ipk $DOWNLOAD_DIR/luci-i18n-podkop-ru*.ipk

    if [ "$IS_SHOULD_RESTART_NETWORK" ]; then
        printf "\033[32;1mRestart network\033[0m\n"
        /etc/init.d/network restart
    fi
}

add_tunnel() {
    echo "What type of VPN or proxy will be used? We also can automatically configure Wireguard and Amnezia WireGuard."
    echo "1) VLESS, Shadowsocks (A sing-box will be installed)"
    echo "2) Wireguard"
    echo "3) AmneziaWG"
    echo "4) OpenVPN"
    echo "5) OpenConnect"
    echo "6) Skip this step"

    # Автоматический выбор "3) AmneziaWG"
    TUNNEL="3"
    echo "$TUNNEL" # Эмулируем ввод пользователя
    while true; do
        case $TUNNEL in

        1)
            # Удалена установка sing-box
            break
            ;;

        2)
            opkg install wireguard-tools luci-proto-wireguard luci-app-wireguard

            printf "\033[32;1mDo you want to configure the wireguard interface? (y/n): \033[0m\n"
            read IS_SHOULD_CONFIGURE_WG_INTERFACE

            if [ "$IS_SHOULD_CONFIGURE_WG_INTERFACE" = "y" ] || [ "$IS_SHOULD_CONFIGURE_WG_INTERFACE" = "Y" ]; then
                wg_awg_setup Wireguard
            else
            printf "\e[1;32mUse these instructions to manual configure https://itdog.info/nastrojka-klienta-wireguard-na-openwrt/\e[0m\n"
            fi

            break
            ;;

        3)
            install_awg_packages

            printf "\033[32;1mThere are no instructions for manual configure yet. Do you want to configure the amneziawg interface? (y/n): \033[0m\n"
            # Автоматический выбор "y" для настройки AmneziaWG
            IS_SHOULD_CONFIGURE_WG_INTERFACE="y"
            echo "$IS_SHOULD_CONFIGURE_WG_INTERFACE" # Эмулируем ввод пользователя

            if [ "$IS_SHOULD_CONFIGURE_WG_INTERFACE" = "y" ] || [ "$IS_SHOULD_CONFIGURE_WG_INTERFACE" = "Y" ]; then
                wg_awg_setup AmneziaWG
            fi

            break
            ;;

        4)
            opkg install opkg install openvpn-openssl luci-app-openvpn
            printf "\e[1;32mUse these instructions to configure https://itdog.info/nastrojka-klienta-openvpn-na-openwrt/\e[0m\n"
            break
            ;;

        5)
            opkg install opkg install openconnect luci-proto-openconnect
            printf "\e[1;32mUse these instructions to configure https://itdog.info/nastrojka-klienta-openconnect-na-openwrt/\e[0m\n"
            break
            ;;

        6)
            echo "Skip. Use this if you're installing an upgrade."
            break
            ;;

        *)
            echo "Choose from the following options"
            ;;
        esac
    done
}

handler_network_restart() {
    IS_SHOULD_RESTART_NETWORK=true
}

install_awg_packages() {
    # Получение pkgarch с наибольшим приоритетом
    PKGARCH=$(opkg print-architecture | awk 'BEGIN {max=0} {if ($3 > max) {max = $3; arch = $2}} END {print arch}')

    TARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 1)
    SUBTARGET=$(ubus call system board | jsonfilter -e '@.release.target' | cut -d '/' -f 2)
    VERSION=$(ubus call system board | jsonfilter -e '@.release.version')
    PKGPOSTFIX="_v${VERSION}_${PKGARCH}_${TARGET}_${SUBTARGET}.ipk"
    BASE_URL="https://github.com/Slava-Shchipunov/awg-openwrt/releases/download/"

    AWG_DIR="/tmp/amneziawg"
    mkdir -p "$AWG_DIR"
    
    if opkg list-installed | grep -q kmod-amneziawg; then
        echo "kmod-amneziawg already installed"
    else
        KMOD_AMNEZIAWG_FILENAME="kmod-amneziawg${PKGPOSTFIX}"
        DOWNLOAD_URL="${BASE_URL}v${VERSION}/${KMOD_AMNEZIAWG_FILENAME}"
        wget -O "$AWG_DIR/$KMOD_AMNEZIAWG_FILENAME" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "kmod-amneziawg file downloaded successfully"
        else
            echo "Error downloading kmod-amneziawg. Please, install kmod-amneziawg manually and run the script again"
            exit 1
        fi
        
        opkg install "$AWG_DIR/$KMOD_AMNEZIAWG_FILENAME"

        if [ $? -eq 0 ]; then
            echo "kmod-amneziawg file downloaded successfully"
        else
            echo "Error installing kmod-amneziawg. Please, install kmod-amneziawg manually and run the script again"
            exit 1
        fi
    fi

    if opkg list-installed | grep -q amneziawg-tools; then
        echo "amneziawg-tools already installed"
    else
        AMNEZIAWG_TOOLS_FILENAME="amneziawg-tools${PKGPOSTFIX}"
        DOWNLOAD_URL="${BASE_URL}v${VERSION}/${AMNEZIAWG_TOOLS_FILENAME}"
        wget -O "$AWG_DIR/$AMNEZIAWG_TOOLS_FILENAME" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "amneziawg-tools file downloaded successfully"
        else
            echo "Error downloading amneziawg-tools. Please, install amneziawg-tools manually and run the script again"
            exit 1
        fi

        opkg install "$AWG_DIR/$AMNEZIAWG_TOOLS_FILENAME"

        if [ $? -eq 0 ]; then
            echo "amneziawg-tools file downloaded successfully"
        else
            echo "Error installing amneziawg-tools. Please, install amneziawg-tools manually and run the script again"
            exit 1
        fi
    fi
    
    if opkg list-installed | grep -q luci-app-amneziawg; then
        echo "luci-app-amneziawg already installed"
    else
        LUCI_APP_AMNEZIAWG_FILENAME="luci-app-amneziawg${PKGPOSTFIX}"
        DOWNLOAD_URL="${BASE_URL}v${VERSION}/${LUCI_APP_AMNEZIAWG_FILENAME}"
        wget -O "$AWG_DIR/$LUCI_APP_AMNEZIAWG_FILENAME" "$DOWNLOAD_URL"

        if [ $? -eq 0 ]; then
            echo "luci-app-amneziawg file downloaded successfully"
        else
            echo "Error downloading luci-app-amneziawg. Please, install luci-app-amneziawg manually and run the script again"
            exit 1
        fi

        opkg install "$AWG_DIR/$LUCI_APP_AMNEZIAWG_FILENAME"

        if [ $? -eq 0 ]; then
            echo "luci-app-amneziawg file downloaded successfully"
        else
            echo "Error installing luci-app-amneziawg. Please, install luci-app-amneziawg manually and run the script again"
            exit 1
        fi
    fi

    rm -rf "$AWG_DIR"
}

wg_awg_setup() {
    PROTOCOL_NAME=$1
    printf "\033[32;1mConfigure ${PROTOCOL_NAME}\033[0m\n"
    if [ "$PROTOCOL_NAME" = 'Wireguard' ]; then
        INTERFACE_NAME="wg0"
        CONFIG_NAME="wireguard_wg0"
        PROTO="wireguard"
        ZONE_NAME="wg"
    fi

    if [ "$PROTOCOL_NAME" = 'AmneziaWG' ]; then
        INTERFACE_NAME="awg0"
        CONFIG_NAME="amneziawg_awg0"
        PROTO="amneziawg"
        ZONE_NAME="awg"
        
        echo "Do you want to use AmneziaWG config or basic Wireguard config + automatic obfuscation?"
        echo "1) AmneziaWG"
        echo "2) Wireguard + automatic obfuscation"
        # Автоматический выбор "1) AmneziaWG"
        CONFIG_TYPE="1"
        echo "$CONFIG_TYPE" # Эмулируем ввод пользователя
    fi

    # Автоматическая генерация WARP конфига (скопирована из awg generate.sh)
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
        printf "\033[32;1mGenerate config AWG WARP failed...Exiting...\033[0m\n"
        exit 1
    else
        while IFS=' = ' read -r line; do
        if echo "$line" | grep -q "="; then
            key=$(echo "$line" | cut -d'=' -f1 | xargs)
            value=$(echo "$line" | cut -d'=' -f2- | xargs)
            eval "$key=\"$value\""
        fi
        done < <(echo "$warp_config")

        Address=$(echo "$Address" | cut -d',' -f1)
        DNS=$(echo "$DNS" | cut -d',' -f1)
        AllowedIPs=$(echo "$AllowedIPs" | cut -d',' -f1)
        EndpointIP=$(echo "$Endpoint" | cut -d':' -f1)
        EndpointPort=$(echo "$Endpoint" | cut -d':' -f2)
    fi

    WG_PRIVATE_KEY_INT=$PrivateKey
    WG_IP=$Address
    WG_PUBLIC_KEY_INT=$PublicKey
    WG_PRESHARED_KEY_INT="" # PresharedKey не используется в WARP конфиге
    WG_ENDPOINT_INT=$EndpointIP
    WG_ENDPOINT_PORT_INT=$EndpointPort
    MTU=1280 # Устанавливаем MTU по умолчанию

    if [ "$PROTOCOL_NAME" = 'AmneziaWG' ]; then
        if [ "$CONFIG_TYPE" = '1' ]; then
            AWG_JC=$Jc
            AWG_JMIN=$Jmin
            AWG_JMAX=$Jmax
            AWG_S1=$S1
            AWG_S2=$S2
            AWG_H1=$H1
            AWG_H2=$H2
            AWG_H3=$H3
            AWG_H4=$H4
        elif [ "$CONFIG_TYPE" = '2' ]; then
            #Default values to wg automatic obfuscation
            AWG_JC=4
            AWG_JMIN=40
            AWG_JMAX=70
            AWG_S1=0
            AWG_S2=0
            AWG_H1=1
            AWG_H2=2
            AWG_H3=3
            AWG_H4=4
        fi
    fi
    
    uci set network.${INTERFACE_NAME}=interface
    uci set network.${INTERFACE_NAME}.proto=$PROTO
    uci set network.${INTERFACE_NAME}.private_key=$WG_PRIVATE_KEY_INT
    uci set network.${INTERFACE_NAME}.listen_port='51821'
    uci del network.${INTERFACE_NAME}.addresses
    uci add_list network.${INTERFACE_NAME}.addresses=$WG_IP
    uci set network.${INTERFACE_NAME}.mtu=$MTU
    uci set network.${INTERFACE_NAME}.nohostroute='1'
    uci commit network # Коммитим изменения после настройки интерфейса

    if [ "$PROTOCOL_NAME" = 'AmneziaWG' ]; then
        uci set network.${INTERFACE_NAME}.awg_jc=$AWG_JC
        uci set network.${INTERFACE_NAME}.awg_jmin=$AWG_JMIN
        uci set network.${INTERFACE_NAME}.awg_jmax=$AWG_JMAX
        uci set network.${INTERFACE_NAME}.awg_s1=$AWG_S1
        uci set network.${INTERFACE_NAME}.awg_s2=$AWG_S2
        uci set network.${INTERFACE_NAME}.awg_h1=$AWG_H1
        uci set network.${INTERFACE_NAME}.awg_h2=$AWG_H2
        uci set network.${INTERFACE_NAME}.awg_h3=$AWG_H3
        uci set network.${INTERFACE_NAME}.awg_h4=$AWG_H4
    fi

    if ! uci show network | grep -q ${CONFIG_NAME}; then
        uci add network ${CONFIG_NAME}
    fi

    uci set network.@${CONFIG_NAME}[-1]=$CONFIG_NAME
    uci set network.@${CONFIG_NAME}[-1].name="${INTERFACE_NAME}_client"
    uci set network.@${CONFIG_NAME}[-1].public_key=$WG_PUBLIC_KEY_INT
    uci set network.@${CONFIG_NAME}[-1].preshared_key=$WG_PRESHARED_KEY_INT
    uci set network.@${CONFIG_NAME}[-1].route_allowed_ips='0'
    uci set network.@${CONFIG_NAME}[-1].persistent_keepalive='25'
    uci set network.@${CONFIG_NAME}[-1].endpoint_host=$WG_ENDPOINT_INT
    uci set network.@${CONFIG_NAME}[-1].allowed_ips='0.0.0.0/0'
    uci set network.@${CONFIG_NAME}[-1].endpoint_port=$WG_ENDPOINT_PORT_INT
    uci commit network # Коммитим изменения после настройки peer-секции

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
        uci set firewall.@forwarding[-1].name="${ZONE_NAME}-lan"
        uci set firewall.@forwarding[-1].dest=${ZONE_NAME}
        uci set firewall.@forwarding[-1].src='lan'
        uci set firewall.@forwarding[-1].family='ipv4'
        uci commit firewall
    fi

    # Перезапуск интерфейса и фаервола для применения изменений
    ifdown $INTERFACE_NAME
    sleep 2 # Даем время на отключение
    ifup $INTERFACE_NAME
    service firewall restart
    # handler_network_restart # Эта функция больше не нужна здесь, так как перезапуск происходит явно
}

check_system() {
    # Get router model
    MODEL=$(cat /tmp/sysinfo/model)
    echo "Router model: $MODEL"

    # Check available space
    AVAILABLE_SPACE=$(df /tmp | awk 'NR==2 {print $4}')
    # Change after switch sing-box
    REQUIRED_SPACE=1024 # 20MB in KB

    echo "Available space: $((AVAILABLE_SPACE/1024))MB"
    echo "Required space: $((REQUIRED_SPACE/1024))MB"

    if [ "$AVAILABLE_SPACE" -lt "$REQUIRED_SPACE" ]; then
        echo "Error: Insufficient space in /tmp"
        echo "Available: $((AVAILABLE_SPACE/1024))MB"
        echo "Required: $((REQUIRED_SPACE/1024))MB"
        exit 1
    fi
}

main
